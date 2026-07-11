#!/usr/bin/env bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces name
IFS=$'\n'

# === ICON-PREVIEW SELECTION WITH ROFI, SORTED BY NEWEST ===
SELECTED_WALL=$(for a in $(ls -t *.jpg *.png *.gif *.jpeg 2>/dev/null); do echo -en "$a\0icon\x1f$a\n"; done | rofi -dmenu -p "")
[ -z "$SELECTED_WALL" ] && exit 1
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === SET WALLPAPER ===
matugen image --source-color-index 0 "$SELECTED_PATH"

# === ADD complement COLOR (WSL の yasb-theme.sh と同じ計算) ===
# matugen テンプレートでは色相回転ができないため、生成後の colors.lua に
# accent の色相を 180° 回した補色 (complement) を追記する
COLORS_LUA="$HOME/.cache/matugen/colors.lua"
if [[ -f "$COLORS_LUA" ]] && ! grep -q 'complement' "$COLORS_LUA"; then
    hl="$(grep -m1 '^  accent = ' "$COLORS_LUA" | grep -oE '#[0-9a-fA-F]{6}')"
    vis="$(python3 -c '
import sys, colorsys
h = sys.argv[1].lstrip("#")
r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
hh, l, s = colorsys.rgb_to_hls(r, g, b)
r, g, b = colorsys.hls_to_rgb((hh + 0.5) % 1.0, l, s)
print("#%02x%02x%02x" % (round(r*255), round(g*255), round(b*255)))
' "$hl" 2>/dev/null)"
    if [[ -n "$vis" ]]; then
        sed -i "s|^\(  tertiary = .*\)$|\1\n  complement = \"$vis\",|" "$COLORS_LUA"
    fi
fi

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

