#!/usr/bin/env bash
# =========================================================================
# aerospace-launch-borders — JankyBorders (borders) をmatugenパレットの
# triad(色相120度回転)/muted色で(再)起動する。
# =========================================================================
# 壁紙と同化して見失わないよう、枠線色(active_color)には色相120度回転の
# triad を優先して使う (無ければ complement / accent を使う)。
#
# borders は既に起動中のインスタンスがあれば、同じコマンドを再実行するだけで
# IPC経由で設定を生きたまま更新する (kill不要。killすると次のインスタンスが
# 上がるまでの一瞬、枠ハイライトが消える)。未起動なら通常通り新規起動する。
set -euo pipefail

COLORS="$HOME/.cache/matugen/colors.lua"
border_color="a2c9fd"
muted="c3c6cf"

if [[ -f "$COLORS" ]]; then
    # 壁紙と枠線が同化しないよう、色相120度回転の triad を優先利用
    t="$(grep -m1 '^\s*triad\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    c="$(grep -m1 '^\s*complement\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    a="$(grep -m1 '^\s*accent\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    m="$(grep -m1 '^\s*muted\s*=' "$COLORS" | grep -oE '#[0-9a-fA-F]{6}' | tr -d '#' || true)"
    if [[ -n "$t" ]]; then
        border_color="$t"
    elif [[ -n "$c" ]]; then
        border_color="$c"
    elif [[ -n "$a" ]]; then
        border_color="$a"
    fi
    [[ -n "$m" ]] && muted="$m"
fi

if pgrep -x borders >/dev/null 2>&1; then
    /opt/homebrew/bin/borders "active_color=0xff${border_color}" "inactive_color=0xff${muted}" width=8.0
else
    /opt/homebrew/bin/borders "active_color=0xff${border_color}" "inactive_color=0xff${muted}" width=8.0 &
    disown
fi
