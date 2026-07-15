#!/usr/bin/env bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces name
IFS=$'\n'

# === ICON-PREVIEW SELECTION WITH ROFI, SORTED BY NEWEST ===
SELECTED_WALL=$(ls -t -- *.jpg *.png *.gif *.jpeg 2>/dev/null | while IFS= read -r a; do echo -en "$a\0icon\x1f$a\n"; done | rofi -dmenu -p "")
[ -z "$SELECTED_WALL" ] && exit 1
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === SET WALLPAPER ===
matugen image --source-color-index 0 "$SELECTED_PATH"

# === DERIVE + RENDER (WSL/NixOS 共通ロジック, modules/theming/matugen) ===
# matugen テンプレートでは色相回転ができないため、生成後の colors.lua に
# 派生色 (complement/triad) を追記し、@@プレースホルダ@@ テンプレートを
# レンダリングする。詳細は docs/matugen-palette.md を参照。
COLORS_LUA="$HOME/.cache/matugen/colors.lua"
LIB="$HOME/.config/matugen-common/lib"
TPL="$HOME/.config/matugen-common/templates"
if [[ -f "$COLORS_LUA" ]]; then
    python3 "$LIB/derive-colors.py" "$COLORS_LUA"
    "$LIB/render-template.sh" "$HOME/.config/yazi/theme-template.toml" \
        "$HOME/.config/yazi/theme.toml" "$COLORS_LUA"
    "$LIB/render-template.sh" "$TPL/lazygit-config.yml" \
        "$HOME/.cache/matugen/lazygit-config.yml" "$COLORS_LUA"
    "$LIB/render-template.sh" "$TPL/starship.toml" \
        "$HOME/.cache/matugen/starship.toml" "$COLORS_LUA"
    # wezterm は colors.lua と同一内容 (11キー) をそのまま使う
    cp -f "$COLORS_LUA" "$HOME/.config/wezterm/matugen-colors.lua"
fi

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

