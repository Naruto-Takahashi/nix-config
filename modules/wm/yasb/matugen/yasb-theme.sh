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
    # --source-color-index 0: 候補色の対話選択を回避し最有力色を自動採用 (非TTYで必須)
    matugen image "$img" -m dark --source-color-index 0 \
        -c "$HOME/.config/yasb/matugen/config.toml"
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

# cava の波形色 (config.yaml 側) も抽出色に追従させる
if [[ -f "$CACHE" ]]; then
    pri="$(grep -m1 -- '--yellow:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    sec="$(grep -m1 -- '--green:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    ter="$(grep -m1 -- '--teal:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    cfg="/mnt/c/Users/tnaru/.config/yasb/config.yaml"
    if [[ -n "$pri" && -n "$sec" && -n "$ter" && -f "$cfg" ]]; then
        sed -i -E \
            -e "s/(foreground: \")#[0-9a-fA-F]{6}/\1${ter}/" \
            -e "s/(gradient_color_1: ')#[0-9a-fA-F]{6}/\1${pri}/" \
            -e "s/(gradient_color_2: ')#[0-9a-fA-F]{6}/\1${sec}/" \
            -e "s/(gradient_color_3: ')#[0-9a-fA-F]{6}/\1${ter}/" "$cfg"
    fi
fi

# komorebi のフォーカス枠 (single/floating) もハイライト色に追従させる
if [[ -f "$CACHE" ]]; then
    hl="$(grep -m1 -- '--highlight:' "$CACHE" | grep -oE '#[0-9a-fA-F]{6}')"
    if [[ -n "$hl" ]]; then
        for f in "/mnt/c/Users/tnaru/.config/komorebi/komorebi.json" "/mnt/c/Users/tnaru/komorebi.json"; do
            [[ -f "$f" ]] && sed -i -E \
                -e "s/(\"single\": *\")#[0-9a-fA-F]{6}/\1${hl}/" \
                -e "s/(\"floating\": *\")#[0-9a-fA-F]{6}/\1${hl}/" "$f"
        done
        "/mnt/c/Program Files/komorebi/bin/komorebic.exe" reload-configuration 2>/dev/null || true
    fi
fi
