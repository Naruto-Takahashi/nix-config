#!/usr/bin/env bash
# =========================================================================
# matugen-apply (mac) — 現在のデスクトップ壁紙から matugen でパレットを抽出し、
# 各アプリへ展開する。OS 共通部分は lib/palette.sh にあり、ここには Mac 固有の
# 処理 (壁紙の取得・AeroSpace の枠線) だけを置く。
# =========================================================================
# 呼び出し:
#   matugen-apply             現在の壁紙 (System Events経由) を自動検出して適用
#   matugen-apply <画像パス>   指定した画像で適用
#   matugen-apply --reapply   前回の壁紙で再生成 (テンプレート更新の反映用)
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/opt/homebrew/bin:$PATH"

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
    # 現在のデスクトップ壁紙のパスを取得する (初回はSystem Eventsのオートメーション許可が必要)
    img="$(osascript -e 'tell application "System Events" to tell first desktop to get picture' 2>/dev/null || true)"
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
# 3. AeroSpace (JankyBorders) の枠色を追従させる
# -------------------------------------------------------------------------
[[ -x "$HOME/.local/bin/aerospace-launch-borders" ]] && \
    "$HOME/.local/bin/aerospace-launch-borders" || true

echo "matugen-apply (mac): 適用完了 (accent=${accent})"
