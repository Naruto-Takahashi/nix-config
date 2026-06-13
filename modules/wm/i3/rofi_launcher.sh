#!/bin/bash
# =========================================================================
# Rofi 起動ラッパースクリプト (リモート判定によるフォント自動調整)
# =========================================================================

# DISPLAY番号の取得
display_num=$(echo $DISPLAY | cut -d: -f2 | cut -d. -f1)

# リモート接続時（DISPLAY番号10以上）はフォントを小さくする
if [ -n "$display_num" ] && [ "$display_num" -ge 10 ]; then
    # リモート用の小さいフォント
    FONT_ARG="-font \"HackGen NF 11\""
else
    # ネイティブ用の標準フォント（指定なしでテーマのデフォルト 14 を使用）
    FONT_ARG=""
fi

# Rofi の起動
# Wayland 誤検知防止のため XDG_SESSION_TYPE=x11 を強制
exec env XDG_SESSION_TYPE=x11 rofi $FONT_ARG "$@"
