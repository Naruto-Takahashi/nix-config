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
    matugen image "$img" -m dark -c "$HOME/.config/yasb/matugen/config.toml"
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
