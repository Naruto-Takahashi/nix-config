#!/usr/bin/env bash
# =========================================================================
# matugen-apply (mac) — 現在のデスクトップ壁紙から matugen でパレットを抽出し、
# 各アプリへ展開する。OS 共通部分は lib/palette.sh にあり、ここには Mac 固有の
# 処理 (壁紙の取得・AeroSpace の枠線) を置く。
# =========================================================================
# 呼び出し:
#   matugen-apply             現在の壁紙 (System Events経由) を自動検出して適用
#   matugen-apply <画像パス>   指定した画像で適用
#   matugen-apply --reapply   前回の壁紙で再生成 (テンプレート更新の反映用)
set -euo pipefail

USER_NAME="${USER:-$(id -un)}"
export PATH="/etc/profiles/per-user/$USER_NAME/bin:$HOME/.nix-profile/bin:/opt/homebrew/bin:$PATH"

# 多重起動ガード (壁紙切り替え時の二重実行対策)。macOSに`flock`が無いため
# `mkdir`のアトミック性を使った簡易ロックにする (WSL/Linuxの`flock`と役割は同じ)。
mkdir -p "$HOME/.cache/matugen"
LOCK_DIR="$HOME/.cache/matugen/.apply.lock.d"
for _ in $(seq 1 50); do
    mkdir "$LOCK_DIR" 2>/dev/null && break
    sleep 0.1
done
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

CACHE="$HOME/.cache/matugen/mac-palette.css"

# -------------------------------------------------------------------------
# 1. 壁紙の決定と matugen 実行
# -------------------------------------------------------------------------
if [[ "${1:-}" == "--reapply" ]]; then
    img=""
    [[ -f "$HOME/.cache/matugen/last-wallpaper" ]] && img="$(cat "$HOME/.cache/matugen/last-wallpaper")"
    [[ -f "$img" ]] || img=""
elif [[ -n "${1:-}" ]]; then
    img="$1"
else
    # 現在のデスクトップ壁紙のパスを取得する
    img="$(osascript -e 'tell application "System Events" to tell first desktop to get picture' 2>/dev/null || true)"
    if [[ -z "${img:-}" || "$img" == "missing value" || ! -f "$img" ]]; then
        # macOS Sonoma以降で missing value になる場合のフォールバック (直近キャッシュ)
        [[ -f "$HOME/.cache/matugen/last-wallpaper" ]] && img="$(cat "$HOME/.cache/matugen/last-wallpaper")"
    fi
fi

if [[ -z "${img:-}" || ! -f "$img" ]]; then
    echo "matugen-apply: 壁紙画像が見つからないため中断しました (img=${img:-<empty>})" >&2
    exit 1
fi

# matugen の候補色 (--show-source-colors) は面積 (支配率) 順に並んでいるため、
# 原則として面積最大の候補0を採用する。
# ただし候補0が黒背景 (L < 0.12)・白背景 (L > 0.88)・無彩色グレー背景 (chroma < 0.10) の場合のみ、
# 候補1以降から人間の視覚感度 (CIE相対輝度 Y) × 彩度 (chroma) が最大の鮮やか色へフォールバックする。
source_idx="$(
    python3 - "$img" <<'PY' || echo 0
import colorsys, math, re, subprocess, sys

img = sys.argv[1]
out = subprocess.check_output(
    ["matugen", "image", img, "--show-source-colors"],
    text=True,
    stderr=subprocess.STDOUT,
)
hexes = re.findall(r"#[0-9a-fA-F]{6}", out)
parsed = []
for idx, hx in enumerate(hexes):
    c = hx.lstrip("#")
    r, g, b = (int(c[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    _, l, s = colorsys.rgb_to_hls(r, g, b)
    chroma = (1.0 - abs(2.0 * l - 1.0)) * s
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    score = chroma * math.sqrt(y) if 0.12 <= l <= 0.88 else 0.0
    parsed.append((idx, l, chroma, score))

if not parsed:
    print(0)
elif 0.12 <= parsed[0][1] <= 0.88 and parsed[0][2] >= 0.10:
    print(0)
elif len(parsed) > 1:
    best = max(parsed[1:], key=lambda x: x[3])
    print(best[0])
else:
    print(0)
PY
)"

matugen image "$img" -m dark --source-color-index "${source_idx:-0}" \
    -c "$HOME/.config/matugen-mac/config.toml"
printf '%s\n' "$img" > "$HOME/.cache/matugen/last-wallpaper"

# -------------------------------------------------------------------------
# 2. パレット抽出と OS 共通アプリへの展開 (WSL と共通の lib/palette.sh)
# -------------------------------------------------------------------------
# shellcheck source=SCRIPTDIR/../lib/palette.sh
source "$HOME/.config/matugen-common/lib/palette.sh"

# surface には明るいコンテナ色 (--surface2) を使う (WSL は YASB に揃えて --base)
if ! matugen_build_palette "$CACHE" surface2; then
    echo "matugen-apply: パレット抽出に失敗した (必須キー欠落: $CACHE)" >&2
    exit 1
fi
matugen_render_common

# -------------------------------------------------------------------------
# 3. AeroSpace (JankyBorders) の枠色を追従させる (補色を優先利用)
# -------------------------------------------------------------------------
[[ -x "$HOME/.local/bin/aerospace-launch-borders" ]] && \
    "$HOME/.local/bin/aerospace-launch-borders" || true

# -------------------------------------------------------------------------
# 4. macOS のテキスト選択ハイライト色 (AppleHighlightColor) を 120度回転色 (triad) に追従させる
# -------------------------------------------------------------------------
# アクセントカラー (AppleAccentColor) は青固定のまま維持し、任意の RGB を指定できる
# テキスト強調表示色だけをウィンドウ枠線と同じ triad (+120度回転色) に即時反映する。
python3 - "$triad" <<'PY' || true
import ctypes, sys
from ctypes import c_bool, c_char_p, c_double, c_long, c_void_p

hex_color = sys.argv[1].lstrip("#")
r, g, b = (int(hex_color[i:i+2], 16) / 255.0 for i in (0, 2, 4))

objc = ctypes.cdll.LoadLibrary("/usr/lib/libobjc.A.dylib")
appkit = ctypes.cdll.LoadLibrary("/System/Library/Frameworks/AppKit.framework/AppKit")

objc.objc_getClass.argtypes = [c_char_p]
objc.objc_getClass.restype = c_void_p
objc.sel_registerName.argtypes = [c_char_p]
objc.sel_registerName.restype = c_void_p

msgSend_color = ctypes.CFUNCTYPE(c_void_p, c_void_p, c_void_p, c_double, c_double, c_double, c_double)(("objc_msgSend", objc))
NSColor = objc.objc_getClass(b"NSColor")
sel = objc.sel_registerName(b"colorWithSRGBRed:green:blue:alpha:")
ns_color = msgSend_color(NSColor, sel, r, g, b, 1.0)

appkit.NSColorSetUserHighlightColor.argtypes = [c_long, c_void_p, c_bool]
appkit.NSColorSetUserHighlightColor(-2, ns_color, True)
PY

echo "matugen-apply (mac): 適用完了 (accent=${accent}, triad=${triad})"
