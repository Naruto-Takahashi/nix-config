#!/usr/bin/env bash
# =========================================================================
# Bitwarden CLI (`bw`) を用いた環境変数・シークレット復元スクリプト
# =========================================================================
# 新しいマシンや環境で、Bitwarden のセキュアメモから API キー等の
# 機密情報を取得し、~/.env にパーミッション 600 で安全に展開します。
#
# 前提:
#   - `bw` (Bitwarden CLI) がインストールされていること (profiles/core.nix に同梱)
#   - Bitwarden に "developer-env" という名前のセキュアメモが存在すること
#     (メモ本文に `GEMINI_API_KEY=...` や `ANTHROPIC_API_KEY=...` を記述)
set -euo pipefail

ITEM_NAME="${1:-developer-env}"
TARGET_FILE="${2:-$HOME/.env}"

# 1. bw コマンドの存在確認
if ! command -v bw >/dev/null 2>&1; then
  echo "::error:: Bitwarden CLI ('bw') が見つかりません。" >&2
  echo "nix-config の profiles/core.nix を適用してから再実行してください。" >&2
  exit 1
fi

# 2. Bitwarden のログイン・ロック状態確認
STATUS="$(bw status 2>/dev/null | jq -r '.status // "unknown"')"

if [ "$STATUS" = "unauthenticated" ]; then
  echo "Bitwarden にログインしていません。ログインしてください:"
  bw login
  STATUS="$(bw status 2>/dev/null | jq -r '.status // "unknown"')"
fi

if [ "$STATUS" = "locked" ]; then
  echo "Vault がロックされています。アンロックしてください:"
  export BW_SESSION="$(bw unlock --raw)"
fi

echo "Bitwarden からセキュアメモ '$ITEM_NAME' を取得しています..."

# 3. セキュアメモ本文の取得
if ! NOTES="$(bw get notes "$ITEM_NAME" 2>/dev/null)"; then
  echo "::error:: アイテム '$ITEM_NAME' の取得に失敗しました。" >&2
  echo "Bitwarden 内に '$ITEM_NAME' という名前のセキュアメモが存在するか確認してください。" >&2
  exit 1
fi

if [ -z "$NOTES" ]; then
  echo "::warning:: 取得したメモが空でした。処理を中断します。" >&2
  exit 1
fi

# 4. 既存ファイルのバックアップ
if [ -f "$TARGET_FILE" ]; then
  BACKUP="${TARGET_FILE}.bak.$(date +%Y%m%d%H%M%S)"
  echo "既存の $TARGET_FILE を $BACKUP にバックアップしました。"
  cp "$TARGET_FILE" "$BACKUP"
  chmod 600 "$BACKUP"
fi

# 5. 安全な書き込み (パーミッション 600)
# umask 077 で作成し、自分以外の読み取りを禁止
(
  umask 077
  printf "%s\n" "$NOTES" > "$TARGET_FILE"
)

echo "✅ $TARGET_FILE にシークレットを安全に復元しました (chmod 600)。"
