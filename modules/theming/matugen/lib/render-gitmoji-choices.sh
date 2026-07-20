#!/usr/bin/env bash
# @@GITMOJI_CZ_CHOICES@@ マーカー行を、gitmoji-types.txt (単一ソース、
# type と絵文字を空白区切りで1行ずつ並べたもの) からTOMLのchoices配列
# 本文に展開して埋め込む。render-template.sh (色の@@KEY@@置換) とは別工程
# として、対象ファイルへin-placeで適用する。
set -euo pipefail

usage() { echo "usage: render-gitmoji-choices.sh <gitmoji-types.txt> <target-file>" >&2; exit 1; }

TYPES_FILE="${1:?}"; TARGET="${2:?}"
[[ -f "$TYPES_FILE" ]] || { echo "types file not found: $TYPES_FILE" >&2; exit 1; }
[[ -f "$TARGET" ]] || { echo "target file not found: $TARGET" >&2; exit 1; }

awk -v types_file="$TYPES_FILE" '
  /@@GITMOJI_CZ_CHOICES@@/ {
    while ((getline line < types_file) > 0) {
      if (line == "") continue
      split(line, a, " ")
      printf("  { value = \"%s %s\", name = \"%s %s\" },\n", a[2], a[1], a[2], a[1])
    }
    close(types_file)
    next
  }
  { print }
' "$TARGET" > "${TARGET}.tmp"
mv "${TARGET}.tmp" "$TARGET"
