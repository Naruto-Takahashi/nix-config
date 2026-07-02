#!/usr/bin/env bash

# Get active window address
ADDR=$(hyprctl activewindow | head -n 1 | awk '{print $2}')

if [ -z "$ADDR" ] || [ "$ADDR" = "Invalid" ] || [ "$ADDR" = "0x0" ]; then
    # No window focused, toggle the minimized special workspace
    hyprctl dispatch togglespecialworkspace minimized
    exit 0
fi

# Check if the active window is already minimized
if hyprctl activewindow | grep -q "special:minimized"; then
    # Get current active workspace
    CURRENT_WS=$(hyprctl activeworkspace | head -n 1 | awk '{print $4}' | tr -d '()')
    hyprctl dispatch movetoworkspace "$CURRENT_WS,address:0x$ADDR"
else
    # Minimize the focused window silently
    hyprctl dispatch movetoworkspacesilent "special:minimized,address:0x$ADDR"
fi
