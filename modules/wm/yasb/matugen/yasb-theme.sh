#!/usr/bin/env bash
# 壁紙から matugen で色を抽出し、YASB の styles.css に流し込んで Windows 側へ配置する。
# YASB の wallpapers ウィジェット run_after から `yasb-theme "{image}"` として呼ばれる。
# `yasb-theme --reapply` でキャッシュ済みパレットの再適用のみ行う (sync-win 用)。
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$PATH"

CACHE="$HOME/.cache/matugen/yasb-palette.css"
SRC="$HOME/.config/yasb/styles.css"
DEST="/mnt/c/Users/tnaru/.config/yasb/styles.css"

if [[ "${1:-}" != "--reapply" ]]; then
    img="${1:?usage: yasb-theme <image path (win or wsl)> | --reapply}"
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

if [[ -f "$CACHE" ]]; then
    # styles.css の MATUGEN マーカー間を生成パレットに差し替えて配置
    awk -v pal="$CACHE" '
        /\/\* MATUGEN:START \*\// { print; while ((getline line < pal) > 0) print line; skip=1; next }
        /\/\* MATUGEN:END \*\//   { skip=0 }
        !skip
    ' "$SRC" > "$DEST"
else
    cp -L "$SRC" "$DEST"
fi

# cava の波形色 (config.yaml 側): サブアクセント基調 + ハイライトへのグラデーション
if [[ -f "$CACHE" ]]; then
    sub="$(grep -m1 -- '--accent-sub:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    hl="$(grep -m1 -- '--highlight:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    cfg="/mnt/c/Users/tnaru/.config/yasb/config.yaml"
    if [[ -n "$sub" && -n "$hl" && -f "$cfg" ]]; then
        # 先に旧 cava を殺しておく (sed 後の自動リロードが新色で再起動する。
        # sed 後に kill すると再起動済みの新 cava を殺してしまう)
        "/mnt/c/Windows/System32/taskkill.exe" /IM cava.exe /F >/dev/null 2>&1 || true
        # sed -i は rename 置換で inode が変わり YASB の watch_config が
        # 外れるため、tmp に生成して同一 inode へ上書きする (truncate+write)
        cfg_tmp="$(mktemp)"
        sed -E \
            -e "s/(foreground: \")#[0-9a-fA-F]{6}/\1${sub}/" \
            -e "s/(gradient_color_1: ')#[0-9a-fA-F]{6}/\1${sub}/" \
            -e "s/(gradient_color_2: ')#[0-9a-fA-F]{6}/\1${sub}/" \
            -e "s/(gradient_color_3: ')#[0-9a-fA-F]{6}/\1${hl}/" "$cfg" > "$cfg_tmp"
        cat "$cfg_tmp" > "$cfg"
        rm -f "$cfg_tmp"
    fi
fi

# starship プロンプトの配色 (palettes.matugen ブロック) を差し替えて生成
STARSHIP_SRC="$HOME/.config/starship.toml"
STARSHIP_OUT="$HOME/.cache/matugen/starship.toml"
if [[ -f "$CACHE" && -f "$STARSHIP_SRC" ]]; then
    hl="$(grep -m1 -- '--highlight:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sub="$(grep -m1 -- '--accent-sub:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sec="$(grep -m1 -- '--secondary:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    mut="$(grep -m1 -- '--subtext1:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    drk="$(grep -m1 -- '--surface2:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    bas="$(grep -m1 -- '--base:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    if [[ -n "$hl" && -n "$sub" && -n "$sec" && -n "$mut" && -n "$drk" && -n "$bas" ]]; then
        awk -v hl="$hl" -v sb="$sub" -v sec="$sec" -v mut="$mut" -v drk="$drk" -v bas="$bas" '
            /# MATUGEN:START/ {
                print
                print "[palettes.matugen]"
                print "accent = \"" hl "\""
                print "accent_sub = \"" sb "\""
                print "secondary = \"" sec "\""
                print "muted = \"" mut "\""
                print "dark = \"" drk "\""
                print "on_accent = \"" bas "\""
                skip=1; next
            }
            /# MATUGEN:END/ { skip=0 }
            !skip
        ' "$STARSHIP_SRC" > "$STARSHIP_OUT.tmp" && mv "$STARSHIP_OUT.tmp" "$STARSHIP_OUT"

        # Windows (PowerShell) 向け変種: custom.os_logo は POSIX sh 依存で
        # Windows では動かない (プロンプト遅延の原因) ため、静的な Windows
        # ロゴセグメントに置き換えて配置する
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
fi

# WezTerm の配色 (matugen-colors.lua) を生成し、WSL側とWindows側の両方へ配置
if [[ -f "$CACHE" ]]; then
    hl="$(grep -m1 -- '--highlight:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sb="$(grep -m1 -- '--accent-sub:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sec="$(grep -m1 -- '--secondary:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    txt="$(grep -m1 -- '--text:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    mut="$(grep -m1 -- '--subtext1:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    srf="$(grep -m1 -- '--surface2:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    bas="$(grep -m1 -- '--base:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    if [[ -n "$hl" && -n "$sb" && -n "$sec" && -n "$txt" && -n "$mut" && -n "$srf" && -n "$bas" ]]; then
        wz_tmp="$(mktemp)"
        cat > "$wz_tmp" <<LUA
-- Generated by yasb-theme (matugen) — do not edit
return {
  accent = "${hl}",
  accent_sub = "${sb}",
  secondary = "${sec}",
  text = "${txt}",
  muted = "${mut}",
  surface = "${srf}",
  on_accent = "${bas}",
}
LUA
        command cp -f "$wz_tmp" "$HOME/.config/wezterm/matugen-colors.lua"
        command cp -f "$wz_tmp" "/mnt/c/Users/tnaru/.config/wezterm/matugen-colors.lua" 2>/dev/null || true
        # nvim / yazi など汎用の Lua 配色ファイルとしても配置
        command cp -f "$wz_tmp" "$HOME/.cache/matugen/colors.lua"
        rm -f "$wz_tmp"

        # lazygit 完全設定ファイル: オーバーレイ合成を使わず単一ファイルで渡す
        # (2ファイルを LG_CONFIG_FILE で繋ぐとディープマージが崩れるため)
        cat > "$HOME/.cache/matugen/lazygit-config.yml.tmp" <<YML
# Generated by yasb-theme (matugen) — do not edit
customCommands:
  - key: "<c-g>"
    description: "Generate commit message via Gemini and Edit"
    context: "global"
    command: "/home/nalt/.local/bin/lazygit-gemini-commit"
    output: "terminal"
gui:
  theme:
    activeBorderColor:
      - "${hl}"
      - bold
    inactiveBorderColor:
      - "#a89984"
    searchingActiveBorderColor:
      - "${sb}"
    optionsTextColor:
      - "#7e9cd8"
    selectedLineBgColor:
      - "#2d4f67"
    cherryPickedCommitBgColor:
      - "#2d4f67"
    cherryPickedCommitFgColor:
      - "#7e9cd8"
    unstagedChangesColor:
      - "#c4746e"
    defaultFgColor:
      - "#c5c9c5"
YML
        mv "$HOME/.cache/matugen/lazygit-config.yml.tmp" "$HOME/.cache/matugen/lazygit-config.yml"
    fi
fi

# fzf (Ctrl+G の ghq ジャンプ等) のハイライト配色を生成
if [[ -f "$CACHE" ]]; then
    hl="$(grep -m1 -- '--highlight:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sb="$(grep -m1 -- '--accent-sub:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    if [[ -n "$hl" && -n "$sb" ]]; then
        cat > "$HOME/.cache/matugen/fzf-colors.sh.tmp" <<SH
# Generated by yasb-theme (matugen) — do not edit
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=pointer:${hl},marker:${hl},prompt:${hl},info:${sb},hl:${sb},hl+:${sb}'
SH
        mv "$HOME/.cache/matugen/fzf-colors.sh.tmp" "$HOME/.cache/matugen/fzf-colors.sh"
    fi
fi

# komorebi のフォーカス枠 (single/floating) はハイライト色、
# monocle (ALT+F) はサブハイライト色に追従させる
if [[ -f "$CACHE" ]]; then
    hl="$(grep -m1 -- '--highlight:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sub="$(grep -m1 -- '--accent-sub:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    if [[ -n "$hl" && -n "$sub" ]]; then
        for f in "/mnt/c/Users/tnaru/.config/komorebi/komorebi.json" "/mnt/c/Users/tnaru/komorebi.json"; do
            [[ -f "$f" ]] && sed -i -E \
                -e "s/(\"single\": *\")#[0-9a-fA-F]{6}/\1${hl}/" \
                -e "s/(\"floating\": *\")#[0-9a-fA-F]{6}/\1${hl}/" \
                -e "s/(\"monocle\": *\")#[0-9a-fA-F]{6}/\1${sub}/" "$f"
        done
        # 設定リロードはバックグラウンドで (ラグ軽減)
        "/mnt/c/Program Files/komorebi/bin/komorebic.exe" reload-configuration 2>/dev/null &
    fi
fi
