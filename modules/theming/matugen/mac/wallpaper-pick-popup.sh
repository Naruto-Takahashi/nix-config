#!/usr/bin/env bash
# =========================================================================
# wallpaper-pick-popup (mac) — Raycast のサムネイルグリッド拡張機能を呼び出し、
# 壁紙を選んで即座にデスクトップと matugen 配色へ反映する。
# =========================================================================
set -euo pipefail

export PATH="/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:/opt/homebrew/bin:$PATH"

# Raycast deeplink でピッカーを直接起動 (一瞬でフロートグリッドが開く)
if open "raycast://extensions/nalt/wallpaper-picker/pick-wallpaper" 2>/dev/null; then
    exit 0
fi

# フォールバック: Raycast 拡張が未登録などの場合は従来の Python+ブラウザ版を起動
GUI_PY="$HOME/.config/matugen-mac/wallpaper-pick-gui.py"
LOG="$(mktemp)"
nohup python3 "$GUI_PY" >"$LOG" 2>/dev/null &
disown

port=""
for _ in $(seq 1 50); do
    port="$(head -n1 "$LOG" 2>/dev/null || true)"
    [[ -n "$port" ]] && break
    sleep 0.1
done
rm -f "$LOG"

if [[ -z "$port" ]]; then
    echo "wallpaper-pick-popup: サーバの起動に失敗しました" >&2
    exit 1
fi

PROFILE_DIR="$(mktemp -d)"
open -na "Vivaldi" --args \
    --app="http://127.0.0.1:${port}" \
    --user-data-dir="$PROFILE_DIR" \
    --window-position=200,120 \
    --window-size=900,720
