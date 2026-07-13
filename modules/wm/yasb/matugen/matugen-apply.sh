#!/usr/bin/env bash
# =========================================================================
# matugen-apply — 壁紙から matugen でパレットを抽出し、各アプリへ展開する
# =========================================================================
# 呼び出し:
#   matugen-apply <壁紙パス (win/wsl)>  YASB の wallpapers ウィジェット run_after から
#   matugen-apply --reapply             sync-win から (前回の壁紙でフル再生成)
#
# 全体の流れ (docs/matugen-palette.md も参照):
#   1. matugen がテンプレート palette.css から yasb-palette.css を生成する
#   2. 本スクリプトがそこからパレットを一度だけ抽出し、色相回転の派生色
#      (complement/triad) を計算する
#   3. 各アプリ向けセクションが順に配色を展開する
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$PATH"

CACHE="$HOME/.cache/matugen/yasb-palette.css"

# -------------------------------------------------------------------------
# 1. 壁紙の決定と matugen 実行
# -------------------------------------------------------------------------
if [[ "${1:-}" != "--reapply" ]]; then
    img="${1:?usage: matugen-apply <image path (win or wsl)> | --reapply}"
    # Windowsパス (C:\...) で渡されたら WSL パスへ変換
    if [[ "$img" == *\\* || "$img" == [A-Za-z]:* ]]; then
        img="$(wslpath "$img")"
    fi
else
    # --reapply: 記録済みの壁紙があればそこから完全再生成 (テンプレート更新を反映するため)
    img=""
    [[ -f "$HOME/.cache/matugen/last-wallpaper" ]] && img="$(cat "$HOME/.cache/matugen/last-wallpaper")"
    [[ -f "$img" ]] || img=""
fi

if [[ -n "${img:-}" ]]; then
    # --source-color-index 0: 候補色の対話選択を回避し最有力色を自動採用 (非TTYで必須)
    matugen image "$img" -m dark --source-color-index 0 \
        -c "$HOME/.config/yasb/matugen/config.toml"
    printf '%s\n' "$img" > "$HOME/.cache/matugen/last-wallpaper"
fi

# -------------------------------------------------------------------------
# 2. パレット抽出 (ここで一度だけ。名前は docs/matugen-palette.md と対応)
# -------------------------------------------------------------------------
pal() { grep -m1 -- "--$1:" "$CACHE" 2>/dev/null | grep -oE '#[0-9a-fA-F]{6}' || true; }

# accent の色相を回した派生色。彩度は matugen トーンに合わせて 0.75 倍に抑える
rotate_hue() { # rotate_hue <hex> <回転量 0..1>
    python3 -c '
import sys, colorsys
h = sys.argv[1].lstrip("#")
r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
hh, l, s = colorsys.rgb_to_hls(r, g, b)
r, g, b = colorsys.hls_to_rgb((hh + float(sys.argv[2])) % 1.0, l, s * 0.75)
print("#%02x%02x%02x" % (round(r*255), round(g*255), round(b*255)))
' "$1" "$2" 2>/dev/null || true
}

HAS_PALETTE=0
if [[ -f "$CACHE" ]]; then
    accent="$(pal highlight)"
    tertiary="$(pal accent-sub)"
    secondary="$(pal secondary)"
    text="$(pal text)"
    muted="$(pal subtext1)"
    surface="$(pal surface2)"
    on_accent="$(pal base)"
    error="$(pal red)"
    outline="$(pal subtext0)"
    if [[ -n "$accent" && -n "$tertiary" && -n "$secondary" && -n "$text" \
          && -n "$muted" && -n "$surface" && -n "$on_accent" ]]; then
        HAS_PALETTE=1
        complement="$(rotate_hue "$accent" 0.5)"       # 180° 補色
        triad="$(rotate_hue "$accent" 0.3333333)"      # 120° トライアド
        # accent を白側に 40% 寄せた控えめな装飾色 (starship/nvim の装飾ブロック用)
        accent_pale="$(python3 -c '
import sys
h = sys.argv[1].lstrip("#")
r, g, b = (int(h[i:i+2], 16) for i in (0, 2, 4))
print("#%02x%02x%02x" % tuple(round(v + (255 - v) * 0.4) for v in (r, g, b)))
' "$accent" 2>/dev/null)"
        [[ -n "$accent_pale" ]] || accent_pale="#f0dbb5"
        [[ -n "$complement" ]] || complement="#7fb4ca"
        [[ -n "$triad" ]] || triad="#c8e69a"
        [[ -n "$error" ]] || error="#e46876"
        [[ -n "$outline" ]] || outline="#4f4f4f"
    fi
fi

# -------------------------------------------------------------------------
# 3. YASB styles.css (MATUGEN マーカー間をパレットに差し替えて Windows へ配置)
# -------------------------------------------------------------------------
SRC="$HOME/.config/yasb/styles.css"
DEST="/mnt/c/Users/tnaru/.config/yasb/styles.css"
if [[ -f "$CACHE" ]]; then
    awk -v pal="$CACHE" '
        /\/\* MATUGEN:START \*\// { print; while ((getline line < pal) > 0) print line; skip=1; next }
        /\/\* MATUGEN:END \*\//   { skip=0 }
        !skip
    ' "$SRC" > "$DEST"
else
    cp -L "$SRC" "$DEST"
fi

# 以降のセクションはパレットが揃っているときのみ実行する
if [[ "$HAS_PALETTE" == 1 ]]; then

# -------------------------------------------------------------------------
# 4. cava (YASB config.yaml 内の波形色): tertiary 基調 + accent へのグラデーション
# -------------------------------------------------------------------------
cfg="/mnt/c/Users/tnaru/.config/yasb/config.yaml"
if [[ -f "$cfg" ]]; then
    # 先に旧 cava を殺しておく (sed 後の自動リロードが新色で再起動する。
    # sed 後に kill すると再起動済みの新 cava を殺してしまう)
    "/mnt/c/Windows/System32/taskkill.exe" /IM cava.exe /F >/dev/null 2>&1 || true
    # sed -i は rename 置換で inode が変わり YASB の watch_config が
    # 外れるため、tmp に生成して同一 inode へ上書きする (truncate+write)
    cfg_tmp="$(mktemp)"
    sed -E \
        -e "s/(foreground: \")#[0-9a-fA-F]{6}/\1${tertiary}/" \
        -e "s/(gradient_color_1: ')#[0-9a-fA-F]{6}/\1${tertiary}/" \
        -e "s/(gradient_color_2: ')#[0-9a-fA-F]{6}/\1${tertiary}/" \
        -e "s/(gradient_color_3: ')#[0-9a-fA-F]{6}/\1${accent}/" "$cfg" > "$cfg_tmp"
    cat "$cfg_tmp" > "$cfg"
    rm -f "$cfg_tmp"
fi

# -------------------------------------------------------------------------
# 5. starship (palettes.matugen ブロックの差し替え + Windows 用変種)
# -------------------------------------------------------------------------
STARSHIP_SRC="$HOME/.config/starship.toml"
STARSHIP_OUT="$HOME/.cache/matugen/starship.toml"
if [[ -f "$STARSHIP_SRC" ]]; then
    awk -v hl="$accent" -v ter="$tertiary" -v sec="$secondary" \
        -v mut="$muted" -v drk="$surface" -v bas="$on_accent" -v pale="$accent_pale" '
        /# MATUGEN:START/ {
            print
            print "[palettes.matugen]"
            print "accent = \"" hl "\""
            print "tertiary = \"" ter "\""
            print "secondary = \"" sec "\""
            print "muted = \"" mut "\""
            print "dark = \"" drk "\""
            print "on_accent = \"" bas "\""
            print "accent_pale = \"" pale "\""
            skip=1; next
        }
        /# MATUGEN:END/ { skip=0 }
        !skip
    ' "$STARSHIP_SRC" > "$STARSHIP_OUT.tmp" && mv "$STARSHIP_OUT.tmp" "$STARSHIP_OUT"

    # Windows (PowerShell) 向け変種: custom.os_logo は POSIX sh 依存で
    # Windows では動かない (プロンプト遅延の原因) ため、静的な PS
    # セグメントに置き換えて配置する
    WIN_STARSHIP="/mnt/c/Users/tnaru/.config/starship.toml"
    awk '
        /^\$\{custom\.os_logo\}\\$/ {
            print "[ PS ](fg:on_accent bg:secondary bold)[\xee\x82\xb0](fg:secondary bg:accent)\\"
            next
        }
        /^\[custom\.os_logo\]/ { skip=1 }
        skip && /^\[username\]/ { skip=0 }
        !skip
    ' "$STARSHIP_OUT" > "${WIN_STARSHIP}.tmp" 2>/dev/null \
        && rm -f "$WIN_STARSHIP" \
        && mv "${WIN_STARSHIP}.tmp" "$WIN_STARSHIP" || true
fi

# -------------------------------------------------------------------------
# 6. 共通 Lua パレット colors.lua (nvim / yazi / WezTerm が読む)
# -------------------------------------------------------------------------
lua_tmp="$(mktemp)"
cat > "$lua_tmp" <<LUA
-- Generated by matugen-apply (matugen) — do not edit
return {
  accent = "${accent}",
  tertiary = "${tertiary}",
  secondary = "${secondary}",
  complement = "${complement}",
  triad = "${triad}",
  text = "${text}",
  muted = "${muted}",
  surface = "${surface}",
  on_accent = "${on_accent}",
  accent_pale = "${accent_pale}",
  error = "${error}",
}
LUA
command cp -f "$lua_tmp" "$HOME/.config/wezterm/matugen-colors.lua"
command cp -f "$lua_tmp" "/mnt/c/Users/tnaru/.config/wezterm/matugen-colors.lua" 2>/dev/null || true
command cp -f "$lua_tmp" "$HOME/.cache/matugen/colors.lua"
rm -f "$lua_tmp"

# -------------------------------------------------------------------------
# 7. lazygit (完全設定ファイル: オーバーレイ合成を使わず単一ファイルで渡す。
#    2ファイルを LG_CONFIG_FILE で繋ぐとディープマージが崩れるため)
# -------------------------------------------------------------------------
cat > "$HOME/.cache/matugen/lazygit-config.yml.tmp" <<YML
# Generated by matugen-apply (matugen) — do not edit
customCommands:
  - key: "<c-g>"
    description: "Generate commit message via Gemini and Edit"
    context: "global"
    command: "/home/nalt/.local/bin/lazygit-gemini-commit"
    output: "terminal"
gui:
  theme:
    activeBorderColor:
      - "${accent}"
      - bold
    inactiveBorderColor:
      - "${muted}"
    searchingActiveBorderColor:
      - "${tertiary}"
    optionsTextColor:
      - "${tertiary}"
    selectedLineBgColor:
      - "${surface}"
    cherryPickedCommitBgColor:
      - "${surface}"
    cherryPickedCommitFgColor:
      - "${complement}"
    unstagedChangesColor:
      - "${error}"
    defaultFgColor:
      - "${text}"
YML
mv "$HOME/.cache/matugen/lazygit-config.yml.tmp" "$HOME/.cache/matugen/lazygit-config.yml"

# -------------------------------------------------------------------------
# 8. yazi (theme-template.toml の @@プレースホルダ@@ を置換して theme.toml を生成)
# -------------------------------------------------------------------------
YAZI_TPL="$HOME/.config/yazi/theme-template.toml"
if [[ -f "$YAZI_TPL" ]]; then
    sed -e "s/@@SECONDARY@@/${secondary}/g" \
        -e "s/@@ACCENT_PALE@@/${accent_pale}/g" \
        -e "s/@@TRIAD@@/${triad}/g" \
        -e "s/@@TERTIARY@@/${tertiary}/g" \
        -e "s/@@COMPLEMENT@@/${complement}/g" \
        -e "s/@@ERROR@@/${error}/g" \
        "$YAZI_TPL" > "$HOME/.config/yazi/theme.toml.tmp" \
        && rm -f "$HOME/.config/yazi/theme.toml" \
        && mv "$HOME/.config/yazi/theme.toml.tmp" "$HOME/.config/yazi/theme.toml"
fi

# -------------------------------------------------------------------------
# 9. fzf (Ctrl+G の ghq ジャンプ等のハイライト配色)
# -------------------------------------------------------------------------
cat > "$HOME/.cache/matugen/fzf-colors.sh.tmp" <<SH
# Generated by matugen-apply (matugen) — do not edit
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=pointer:${accent},marker:${accent},prompt:${accent},info:${tertiary},hl:${tertiary},hl+:${tertiary}'
SH
mv "$HOME/.cache/matugen/fzf-colors.sh.tmp" "$HOME/.cache/matugen/fzf-colors.sh"

# -------------------------------------------------------------------------
# 10. komorebi の枠色 (single/floating = accent, monocle = tertiary, unfocused = outline)
# -------------------------------------------------------------------------
for f in "/mnt/c/Users/tnaru/.config/komorebi/komorebi.json" "/mnt/c/Users/tnaru/komorebi.json"; do
    [[ -f "$f" ]] && sed -i -E \
        -e "s/(\"single\": *\")#[0-9a-fA-F]{6}/\1${accent}/" \
        -e "s/(\"floating\": *\")#[0-9a-fA-F]{6}/\1${accent}/" \
        -e "s/(\"monocle\": *\")#[0-9a-fA-F]{6}/\1${tertiary}/" \
        -e "s/(\"unfocused\": *\")#[0-9a-fA-F]{6}/\1${outline}/" "$f"
done
# 設定リロードはバックグラウンドで (ラグ軽減)
"/mnt/c/Program Files/komorebi/bin/komorebic.exe" reload-configuration 2>/dev/null &

fi  # HAS_PALETTE
