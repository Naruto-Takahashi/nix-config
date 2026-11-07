#!/usr/bin/env bash
# =========================================================================
# Bitwarden CLI (`bw`) を用いた SSH 鍵および config 復元スクリプト
# =========================================================================
# 新しいマシンや環境で、Bitwarden に保管された SSH 秘密鍵・公開鍵、
# および ~/.ssh/config を取得し、適切なパーミッション (700/600/644) で展開します。
#
# 前提:
#   - `bw` (Bitwarden CLI) と `jq` がインストールされていること (profiles/core.nix に同梱)
#   - Bitwarden に "ssh-id_ed25519" という名前のアイテム (SSHキー または セキュアメモ)
#     が登録されていること
#
# 引数:
#   $1: アイテム名 (デフォルト: ssh-id_ed25519)
#   $2: 出力先ディレクトリ (デフォルト: $HOME/.ssh)
#   $3: 鍵ファイル名 (デフォルト: id_ed25519)
set -euo pipefail

ITEM_NAME="${1:-ssh-id_ed25519}"
TARGET_DIR="${2:-$HOME/.ssh}"
KEY_NAME="${3:-id_ed25519}"

# 1. 依存コマンドの存在確認
for cmd in bw jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "::error:: コマンド '$cmd' が見つかりません。" >&2
    echo "nix-config の profiles/core.nix を適用してから再実行してください。" >&2
    exit 1
  fi
done

# 2. Bitwarden のログイン・ロック状態確認
STATUS="$(bw status 2>/dev/null | jq -r '.status // "unknown"')"

if [ "$STATUS" = "unauthenticated" ]; then
  echo "Bitwarden にログインしていません。ログインしてください:"
  bw login
  STATUS="$(bw status 2>/dev/null | jq -r '.status // "unknown"')"
fi

if [ "$STATUS" = "locked" ]; then
  echo "Vault がロックされています。アンロックしてください:"
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
fi

echo "Bitwarden からアイテム '$ITEM_NAME' を取得しています..."

# 3. アイテム JSON の取得
BW_ERR="$(mktemp)"
trap 'rm -f "$BW_ERR"' EXIT
if ! ITEM_JSON="$(bw get item "$ITEM_NAME" 2>"$BW_ERR")"; then
  echo "::error:: アイテム '$ITEM_NAME' の取得に失敗しました: $(cat "$BW_ERR")" >&2
  echo "Bitwarden 内に '$ITEM_NAME' という名前のアイテム (SSHキーまたはセキュアメモ) が存在するか確認してください。" >&2
  exit 1
fi

# 4. 秘密鍵の抽出 (SSHキーアイテムの sshKey.privateKey、またはメモ/カスタムフィールド)
PRIVATE_KEY="$(echo "$ITEM_JSON" | jq -r '
  .sshKey.privateKey //
  (if (.notes // "") | test("-----BEGIN ") then .notes else empty end) //
  (.fields[]? | select(.name == "private_key" or .name == "id_ed25519") | .value) //
  empty
')"

if [ -z "$PRIVATE_KEY" ]; then
  echo "::error:: アイテム '$ITEM_NAME' から秘密鍵を見つけられませんでした。" >&2
  echo "Bitwarden の「SSHキー」タイプの秘密鍵欄、または「メモ」欄に秘密鍵が設定されているか確認してください。" >&2
  exit 1
fi

# 5. 公開鍵の抽出
PUBLIC_KEY="$(echo "$ITEM_JSON" | jq -r '
  .sshKey.publicKey //
  (.fields[]? | select(.name == "public_key" or .name == "id_ed25519.pub") | .value) //
  empty
')"

# 6. SSH config の抽出 (カスタムフィールド "config" または メモ欄に Host 定義がある場合)
SSH_CONFIG="$(echo "$ITEM_JSON" | jq -r '
  (.fields[]? | select(.name == "config" or .name == "ssh_config") | .value) //
  (if (.notes // "") | test("^Host ") then .notes else empty end) //
  empty
')"

# 7. ディレクトリの作成とパーミッション設定
mkdir -p "$TARGET_DIR"
chmod 700 "$TARGET_DIR"

# 8. 秘密鍵の書き出し
PRIV_TARGET="$TARGET_DIR/$KEY_NAME"
if [ -f "$PRIV_TARGET" ]; then
  BACKUP="$PRIV_TARGET.bak-$(date +%Y%m%d%H%M%S)"
  echo "既存の秘密鍵が存在するためバックアップします: $BACKUP"
  cp "$PRIV_TARGET" "$BACKUP"
fi

# umask 077 で書き込み、パーミッション 600 を保証
(
  umask 077
  printf "%s\n" "$PRIVATE_KEY" > "$PRIV_TARGET"
)
chmod 600 "$PRIV_TARGET"
echo "✅ 秘密鍵を復元しました: $PRIV_TARGET (chmod 600)"

# 9. 公開鍵の書き出し (無ければ ssh-keygen で自動生成)
PUB_TARGET="$TARGET_DIR/$KEY_NAME.pub"
if [ -n "$PUBLIC_KEY" ]; then
  printf "%s\n" "$PUBLIC_KEY" > "$PUB_TARGET"
  chmod 644 "$PUB_TARGET"
  echo "✅ 公開鍵を復元しました: $PUB_TARGET (chmod 644)"
elif command -v ssh-keygen >/dev/null 2>&1; then
  echo "公開鍵が見つからないため、秘密鍵から生成します..."
  ssh-keygen -y -f "$PRIV_TARGET" > "$PUB_TARGET"
  chmod 644 "$PUB_TARGET"
  echo "✅ 公開鍵を生成しました: $PUB_TARGET (chmod 644)"
fi

# 10. SSH config の書き出し (存在する場合)
if [ -n "$SSH_CONFIG" ]; then
  CONFIG_TARGET="$TARGET_DIR/config"
  if [ -f "$CONFIG_TARGET" ]; then
    BACKUP="$CONFIG_TARGET.bak-$(date +%Y%m%d%H%M%S)"
    echo "既存の config が存在するためバックアップします: $BACKUP"
    cp "$CONFIG_TARGET" "$BACKUP"
  fi
  printf "%s\n" "$SSH_CONFIG" > "$CONFIG_TARGET"
  chmod 600 "$CONFIG_TARGET"
  echo "✅ SSH config を復元しました: $CONFIG_TARGET (chmod 600)"
fi

echo "🎉 SSH 鍵の復元が完了しました。"
