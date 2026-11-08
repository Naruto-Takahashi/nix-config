#!/usr/bin/env bash
# =========================================================================
# wallpaper-pick-popup (mac) — Raycast のサムネイルグリッド拡張機能を呼び出し、
# 壁紙を選んで即座にデスクトップと matugen 配色へ反映する。
# AeroSpace のショートカット (ctrl-cmd-w) 等から呼び出される。
# =========================================================================
set -euo pipefail

# Raycast deeplink でピッカーを直接起動 (フロートグリッドが一瞬で開く)
open "raycast://extensions/nalt/wallpaper-picker/pick-wallpaper"
