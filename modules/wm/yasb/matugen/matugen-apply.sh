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
#   2. 本スクリプトがそこからパレットを一度だけ抽出し、NixOS と共通の
#      modules/theming/matugen/lib/ (derive-colors.py / render-template.sh)
#      で派生色 (complement/triad/accent_pale) の計算とテンプレート
#      レンダリング (lazygit/yazi) を行う
#   3. 各アプリ向けセクションが順に配色を展開する
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$PATH"

# 多重起動ガード: 壁紙を素早く切り替えると run_after が並走し、
# 古いパレットのプロセスが後から生成物を上書きして世代が混ざるため直列化する
exec 9>"$HOME/.cache/matugen/.apply.lock"
flock 9

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

# complement/triad/accent_pale の色相回転・白ブレンド計算は NixOS と共通
# (modules/theming/matugen/lib/derive-colors.py)。WSL のパレット抽出元
# (yasb-palette.css の CSS変数) は colors.lua と形式が違うため、抽出後に
# 一時 colors.lua を組み立てて渡す。
LIB="$HOME/.config/matugen-common/lib"

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
        base_lua="$(mktemp)"
        cat > "$base_lua" <<EOF
return {
  accent = "${accent}",
  tertiary = "${tertiary}",
  secondary = "${secondary}",
  text = "${text}",
  muted = "${muted}",
  surface = "${surface}",
  on_accent = "${on_accent}",
  error = "${error}",
}
EOF
        python3 "$LIB/derive-colors.py" "$base_lua"
        pal_lua() { grep -m1 "^\s*$1\s*=" "$base_lua" | grep -oE '#[0-9a-fA-F]{6}'; }
        complement="$(pal_lua complement)"
        triad="$(pal_lua triad)"
        accent_pale="$(pal_lua accent_pale)"
        rm -f "$base_lua"
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

# -------------------------------------------------------------------------
# 7. lazygit / 8. yazi theme.toml (NixOS と共通の render-template.sh で
#    @@プレースホルダ@@ テンプレートをレンダリング。$lua_tmp を再利用する)
# -------------------------------------------------------------------------
TPL="$HOME/.config/matugen-common/templates"
"$LIB/render-template.sh" "$TPL/lazygit-config.yml" \
    "$HOME/.cache/matugen/lazygit-config.yml" "$lua_tmp"
"$LIB/render-template.sh" "$HOME/.config/yazi/theme-template.toml" \
    "$HOME/.config/yazi/theme.toml" "$lua_tmp"
rm -f "$lua_tmp"

# -------------------------------------------------------------------------
# 9. fzf (Ctrl+G の ghq ジャンプ等のハイライト配色。Material role のみで
#    完結するため NixOS 側も matugen ネイティブテンプレートのまま)
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
