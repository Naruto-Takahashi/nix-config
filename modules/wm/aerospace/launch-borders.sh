#!/usr/bin/env bash
# =========================================================================
# aerospace-launch-borders — JankyBorders (borders) をmatugenパレットの
# triad(色相120度回転)色で(再)起動する。
# =========================================================================
# 壁紙と同化して見失わないよう、枠線色(active_color)には色相120度回転の
# triad を優先して使う (無ければ complement / accent を使う)。
# フォーカス中ウィンドウがフローティングのときだけ、補色(complement)に切り替えて
# タイリングと見分けられるようにする (aerospace.toml の on-focus-changed と
# レイアウトトグルキーから都度呼ばれる)。
# 非アクティブ枠線(inactive_color)は完全透明(0x00000000)にする。AeroSpaceは
# 非表示ワークスペースのウィンドウを画面右下に1pxだけ残して退避させる仕様の
# ため、非アクティブ枠線に色を付けると画面右下に太い枠線の角が飛び出して見える。
# order=below (デフォルト) でウィンドウ背面に枠線を描画し、マウス移動時のチラつき(Layer Churn)を防ぐ。
#
# borders は既に起動中のインスタンスがあれば、同じコマンドを再実行するだけで
# IPC経由で設定を生きたまま更新する (kill不要。killすると次のインスタンスが
# 上がるまでの一瞬、枠ハイライトが消える)。未起動なら通常通り新規起動する。
set -euo pipefail

COLORS="$HOME/.cache/matugen/colors.lua"
border_color="a2c9fd"

if [[ -f "$COLORS" ]]; then
    # 壁紙と枠線が同化しないよう、色相120度回転の triad を優先利用
    t="$(grep -m1 '^\s*triad\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    c="$(grep -m1 '^\s*complement\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    a="$(grep -m1 '^\s*accent\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    if [[ -n "$t" ]]; then
        border_color="$t"
    elif [[ -n "$c" ]]; then
        border_color="$c"
    elif [[ -n "$a" ]]; then
        border_color="$a"
    fi
fi

# フォーカス中ウィンドウがフローティングなら補色を使う
layout="$(/opt/homebrew/bin/aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null || true)"
if [[ "$layout" == "floating" && -n "${c:-}" ]]; then
    border_color="$c"
fi

if pgrep -x borders >/dev/null 2>&1; then
    /opt/homebrew/bin/borders "active_color=0xff${border_color}" "inactive_color=0x00000000" width=8.0
else
    /opt/homebrew/bin/borders "active_color=0xff${border_color}" "inactive_color=0x00000000" width=8.0 &
    disown
fi
