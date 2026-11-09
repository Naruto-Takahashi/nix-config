#!/usr/bin/env bash
# =========================================================================
# matugen-apply (mac) — 現在のデスクトップ壁紙から matugen でパレットを抽出し、
# 各アプリへ展開する。OS 共通部分は lib/palette.sh にあり、ここには Mac 固有の
# 処理 (壁紙の取得・AeroSpace の枠線・macOSシステムカラー設定) を置く。
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

matugen image "$img" -m dark --source-color-index 0 \
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
# 4. macOS 本体のアクセントカラー & ハイライトカラーを追従させる
# -------------------------------------------------------------------------
# accent色から色相を計算し、最も近いmacOSプリセット色をAppleAccentColorに、
# 実RGB値をAppleHighlightColor (テキスト選択ハイライト) に適用する。
python3 - <<PY || true
import colorsys, subprocess

hex_color = "${accent}".lstrip("#")
r, g, b = (int(hex_color[i:i+2], 16) / 255.0 for i in (0, 2, 4))
h, l, s = colorsys.rgb_to_hls(r, g, b)
deg = h * 360.0

# AppleAccentColor:
# -1: Graphite, 0: Red, 1: Orange, 2: Yellow, 3: Green, 4: Blue, 5: Purple, 6: Pink
if s < 0.12:
    accent_val = -1
    aqua_val = 6
elif deg >= 350 or deg < 15:
    accent_val = 0
    aqua_val = 1
elif deg < 40:
    accent_val = 1
    aqua_val = 1
elif deg < 75:
    accent_val = 2
    aqua_val = 1
elif deg < 165:
    accent_val = 3
    aqua_val = 1
elif deg < 255:
    accent_val = 4
    aqua_val = 1
elif deg < 305:
    accent_val = 5
    aqua_val = 1
else:
    accent_val = 6
    aqua_val = 1

subprocess.run(["defaults", "write", "-g", "AppleAccentColor", "-int", str(accent_val)], check=False)
subprocess.run(["defaults", "write", "-g", "AppleAquaColorVariant", "-int", str(aqua_val)], check=False)
highlight_str = f"{r:.6f} {g:.6f} {b:.6f}"
subprocess.run(["defaults", "write", "-g", "AppleHighlightColor", "-string", highlight_str], check=False)
PY

echo "matugen-apply (mac): 適用完了 (accent=${accent})"
