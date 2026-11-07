# =========================================================================
# Kanata macOS 用設定テキスト (プレースホルダ置換済み)
# =========================================================================
# config.kbd はプレースホルダーを含むテンプレート。macOS では以下に置換して使う:
#   1. デバイス指定: 内蔵キーボード (Apple Internal Keyboard / Trackpad) も対象に含める
#   2. US配列実機対応: スペース左右の物理Command (lmet / rmet) を defsrc に追加
#   3. IME切り替え: 左右Command単押しで英数/かな (Tap: eisu/kana / Hold: 通常のCommand)
#   4. WM操作: 左右Alt (Option) 長押しでウィンドウ操作レイヤー (alt-layer) を起動
#   5. Ctrl長押し: macOSでは Ctrl 長押し時に ctrl-layer を有効化する
#   6. WMモディファイア: ウィンドウマネージャーのモディファイアは Ctrl + Cmd (C-M-) にする
#   7. Alt + Space: A-spc (Alt + Space) に直接マッピングする
#   8. Alt + Tab: A-tab (Alt + Tab) に直接マッピングする (AltTabアプリ連携用)
let
  original = builtins.readFile ./config.kbd;

  replaced =
    builtins.replaceStrings
      [
        "\"HHKB-Hybrid_2\""
        "caps  lalt  spc   ralt  lctl  esc"
        "  alt-eng  (tap-hold-press 200 200 eisu (layer-toggle alt-layer))\n  alt-jp   (tap-hold-press 200 200 kana (layer-toggle alt-layer))"
        "@cap-ctrl @alt-eng @spc-nav @alt-jp @cap-ctrl @esc-eng"
        "@alt-ctrl-toggle _ @hyp-d _ @alt-ctrl-toggle _"
        "(deflayer nav\n  _     _     _     _     _     _"
        "  _     @alt-ctrl-toggle _ @alt-ctrl-toggle _ _"
        "(deflayer alt-ctrl-layer\n  _     _     _            _     _     _"
        "cap-ctrl-action"
        "wmmodifier-"
        "@hyp-d "
        "@hyp-tab"
      ]
      [
        "\"Apple Internal Keyboard / Trackpad\"\n    \"HHKB-Hybrid_2\""
        "caps  lalt  lmet  spc   rmet  ralt  lctl  esc"
        "  ;; 左右Command単押しでのIME切り替え（Tap：英数/かな / Hold：通常のCommand）\n  cmd-eng  (tap-hold-press 200 200 eisu lmet)\n  cmd-jp   (tap-hold-press 200 200 kana rmet)\n\n  ;; 左右Alt(Option)長押しでのウィンドウ操作レイヤー移行\n  alt-wm   (layer-toggle alt-layer)"
        "@cap-ctrl @alt-wm @cmd-eng @spc-nav @cmd-jp @alt-wm @cap-ctrl @esc-eng"
        "@alt-ctrl-toggle _ _ @hyp-d _ _ @alt-ctrl-toggle _"
        "(deflayer nav\n  _     _     _     _     _     _     _     _"
        "  _     @alt-ctrl-toggle _ _ _ @alt-ctrl-toggle _ _"
        "(deflayer alt-ctrl-layer\n  _     _     _     _     _     _     _     _"
        "(layer-toggle ctrl-layer)"
        "C-M-"
        "A-spc "
        "A-tab"
      ]
      original;
in
replaced
