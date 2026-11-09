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
# 1. 壁紙から代表色を抽出し、macOS プリセット色にスナップして matugen 実行
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

# 壁紙から抽出した色を macOS の8つのシステムプリセット色のうち最も近い色へスナップし、
# さらに +120度回転させた先の macOS プリセット色 (ウィンドウ枠線 & macOS アクセントカラー用) も決定する。
read -r main_preset_id main_preset_hex rot_preset_id rot_accent_hex < <(
    python3 - "$img" <<'PY'
import colorsys, json, subprocess, sys

img = sys.argv[1]
raw = subprocess.check_output(
    ["matugen", "image", img, "-m", "dark", "--source-color-index", "0", "--dry-run", "-j", "hex"],
    text=True,
)
raw_primary = json.loads(raw)["colors"]["primary"]["dark"]["color"].lstrip("#")
r, g, b = (int(raw_primary[i:i+2], 16) / 255.0 for i in (0, 2, 4))
h, l, s = colorsys.rgb_to_hls(r, g, b)
deg = h * 360.0

# macOS 標準アクセントカラーの sRGB 実測値とダークモード primary 派生値
# (-1: Graphite, 0: Red, 1: Orange, 2: Yellow, 3: Green, 4: Blue, 5: Purple, 6: Pink)
PRESETS = {
    -1: ("#98989d", "#acc7ff"),
     0: ("#ff4245", "#ffb3ae"),
     1: ("#ff9230", "#ffb781"),
     2: ("#ffd600", "#ddc56e"),
     3: ("#30d158", "#9ed49d"),
     4: ("#0091ff", "#a4c9fe"),
     5: ("#db34f2", "#ecb4ec"),
     6: ("#ff375f", "#ffb2b7"),
}

# 色相環上の +120度回転に対応する macOS プリセット遷移マップ
ROTATE_120 = {
    -1: -1,
     0: 3,  # Red    -> Green
     1: 3,  # Orange -> Green
     2: 4,  # Yellow -> Blue
     3: 5,  # Green  -> Purple
     4: 6,  # Blue   -> Pink
     5: 2,  # Purple -> Yellow
     6: 3,  # Pink   -> Green
}

if s < 0.12:
    main_id = -1
elif deg >= 350 or deg < 15:
    main_id = 0  # Red
elif deg < 40:
    main_id = 1  # Orange
elif deg < 75:
    main_id = 2  # Yellow
elif deg < 185:
    main_id = 3  # Green (ティール・エメラルド系も含む)
elif deg < 255:
    main_id = 4  # Blue
elif deg < 315:
    main_id = 5  # Purple
else:
    main_id = 6  # Pink

rot_id = ROTATE_120[main_id]
print(main_id, PRESETS[main_id][0], rot_id, PRESETS[rot_id][1])
PY
)

matugen color hex "$main_preset_hex" -m dark \
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

# triad (120度回転色) も macOS プリセット由来の色 (rot_accent_hex) に揃える
triad="$rot_accent_hex"
sed -i '' "s|triad = \"#[0-9a-fA-F]*\"|triad = \"${triad}\"|" "$MATUGEN_LUA"

matugen_render_common

# -------------------------------------------------------------------------
# 3. AeroSpace (JankyBorders) の枠色を追従させる (120度回転後の macOS プリセット色)
# -------------------------------------------------------------------------
[[ -x "$HOME/.local/bin/aerospace-launch-borders" ]] && \
    "$HOME/.local/bin/aerospace-launch-borders" || true

# -------------------------------------------------------------------------
# 4. macOS 本体のアクセントカラー & ハイライトカラーを 120度回転色へ追従させる
# -------------------------------------------------------------------------
# Mission Control の選択枠・Finder サイドバーアイコン・標準コントロール色を
# AeroSpace のウィンドウ枠線と同じ 120度回転後の macOS プリセット色に統一する。
# macOS「システム設定 > 外観」が内部で呼ぶ AppKit の NSColorSetUserAccentColor /
# NSColorSetUserHighlightColor (notify=True) を直接呼び出すことで、再起動なしで
# Finder・Dock(Mission Control)を含む全アプリへ即時反映させる。
python3 - "$rot_preset_id" <<'PY' || true
import ctypes, sys

accent_val = int(sys.argv[1])
appkit = ctypes.cdll.LoadLibrary("/System/Library/Frameworks/AppKit.framework/AppKit")
appkit.NSColorSetUserAccentColor.argtypes = [ctypes.c_long, ctypes.c_bool]
appkit.NSColorSetUserHighlightColor.argtypes = [ctypes.c_long, ctypes.c_void_p, ctypes.c_bool]

appkit.NSColorSetUserAccentColor(accent_val, True)
appkit.NSColorSetUserHighlightColor(accent_val, None, True)
PY

echo "matugen-apply (mac): 適用完了 (main_preset=${main_preset_id}:${main_preset_hex}, accent=${accent}, rot_preset=${rot_preset_id}:${triad})"
