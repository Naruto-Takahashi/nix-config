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

# === ADD complement / triad COLORS (WSL の matugen-apply.sh と同じ計算) ===
# matugen テンプレートでは色相回転ができないため、生成後の colors.lua に
# accent の色相を回した派生色 (complement=180°, triad=120°) を追記する
COLORS_LUA="$HOME/.cache/matugen/colors.lua"
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
if [[ -f "$COLORS_LUA" ]]; then
    hl="$(grep -m1 '^  accent = ' "$COLORS_LUA" | grep -oE '#[0-9a-fA-F]{6}')"
    if [[ -n "$hl" ]]; then
        if ! grep -q 'complement' "$COLORS_LUA"; then
            complement="$(rotate_hue "$hl" 0.5)"
            [[ -n "$complement" ]] && sed -i "s|^\(  tertiary = .*\)$|\1\n  complement = \"$complement\",|" "$COLORS_LUA"
        fi
        if ! grep -q 'triad' "$COLORS_LUA"; then
            triad="$(rotate_hue "$hl" 0.3333333)"
            [[ -n "$triad" ]] && sed -i "s|^\(  tertiary = .*\)$|\1\n  triad = \"$triad\",|" "$COLORS_LUA"
        fi
    fi
fi

pal() { grep -m1 "^  $1 = " "$COLORS_LUA" | grep -oE '#[0-9a-fA-F]{6}'; }

# === GENERATE yazi theme.toml (WSL の matugen-apply.sh と同じ後処理) ===
# theme-template.toml の @@プレースホルダ@@ を colors.lua の値で置換する。
# matugen のテンプレート機能だけでは処理できない (colors.lua 自体が
# 上の色相回転で完成する2段階構成のため)
YAZI_TPL="$HOME/.config/yazi/theme-template.toml"
if [[ -f "$YAZI_TPL" && -f "$COLORS_LUA" ]]; then
    secondary="$(pal secondary)"
    tertiary="$(pal tertiary)"
    complement="$(pal complement)"
    triad="$(pal triad)"
    error="$(pal error)"
    if [[ -n "$secondary" && -n "$tertiary" && -n "$complement" && -n "$triad" && -n "$error" ]]; then
        sed -e "s/@@SECONDARY@@/${secondary}/g" \
            -e "s/@@TERTIARY@@/${tertiary}/g" \
            -e "s/@@COMPLEMENT@@/${complement}/g" \
            -e "s/@@TRIAD@@/${triad}/g" \
            -e "s/@@ERROR@@/${error}/g" \
            "$YAZI_TPL" > "$HOME/.config/yazi/theme.toml.tmp" \
            && mv "$HOME/.config/yazi/theme.toml.tmp" "$HOME/.config/yazi/theme.toml"
    fi
fi

# === GENERATE lazygit config (WSL の matugen-apply.sh と同じ後処理) ===
# cherryPickedCommitFgColor が色相回転色 (complement) を使うため、
# matugen 単体のテンプレート機能では出力できない。
LAZYGIT_TPL="$HOME/.config/matugen/templates/lazygit-config.yml"
if [[ -f "$LAZYGIT_TPL" && -f "$COLORS_LUA" ]]; then
    accent="$(pal accent)"
    muted="$(pal muted)"
    tertiary="$(pal tertiary)"
    surface="$(pal surface)"
    complement="$(pal complement)"
    error="$(pal error)"
    text="$(pal text)"
    if [[ -n "$accent" && -n "$muted" && -n "$tertiary" && -n "$surface" \
          && -n "$complement" && -n "$error" && -n "$text" ]]; then
        sed -e "s/@@ACCENT@@/${accent}/g" \
            -e "s/@@MUTED@@/${muted}/g" \
            -e "s/@@TERTIARY@@/${tertiary}/g" \
            -e "s/@@SURFACE@@/${surface}/g" \
            -e "s/@@COMPLEMENT@@/${complement}/g" \
            -e "s/@@ERROR@@/${error}/g" \
            -e "s/@@TEXT@@/${text}/g" \
            "$LAZYGIT_TPL" > "$HOME/.cache/matugen/lazygit-config.yml.tmp" \
            && mv "$HOME/.cache/matugen/lazygit-config.yml.tmp" "$HOME/.cache/matugen/lazygit-config.yml"
    fi
fi

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

