# =========================================================================
# Kanata macOS 用設定テキスト (構造差分の置換済み)
# =========================================================================
# config.kbd は 3 ホスト共通のテンプレート。WM 修飾子 (Ctrl+Cmd)・Alt+Space/Tab・
# Undo (Cmd+Z)・Ctrl 長押しなど「信号」の差分は config.kbd 内の
# (platform (macos) ...) / deftemplate で kanata 自身が解決する。
# ここで置換するのは、macOS だけ列数が違う物理キー配列まわりのみ:
#   1. デバイス指定: 内蔵キーボード (Apple Internal Keyboard / Trackpad) も対象に含める
#   2. US配列実機対応: スペース左右の物理Command (lmet / rmet) を defsrc に追加
#   3. IME切り替え: 左右Command単押しで英数/かな (Tap: eisu/kana / Hold: 通常のCommand)
#   4. WM操作: 左右Alt (Option) 長押しでウィンドウ操作レイヤー (alt-layer) を起動
#   5. Fnキー: defsrc と各レイヤーの F 行末尾に fn 列を追加 (frow-* コメントを目印に置換)
#   5. Superwhisper: 最下段の物理左Controlを rctl (@whisper) に割り当てて録音キーとして使用 (CapsLockは通常のlctlのまま維持、FnキーはOS標準の機能として開放)
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
        "(deflayer alt-ctrl-layer\n  _     _     _            _     _     _"
        ";; frow-src"
        ";; frow-base"
        ";; frow-l1"
        ";; frow-l2"
        ";; frow-l3"
      ]
      [
        "\"Apple Internal Keyboard / Trackpad\"\n    \"Keychron Q11 Ultra 8K L\"\n    \"Keychron Q11 Ultra 8K R\"\n    \"Keychron Q11 Ultra 8K\"\n    \"Keychron Q11 Ultra\"\n    \"HHKB-Hybrid_2\""
        "caps  lalt  lmet  spc   rmet  ralt  lctl  esc"
        "  ;; 左右Command単押しでのIME切り替え（Tap：英数/かな / Hold：通常のCommand）\n  cmd-eng  (tap-hold-press 200 200 eisu lmet)\n  cmd-jp   (tap-hold-press 200 200 kana rmet)\n\n  ;; 左右Alt(Option)長押しでのウィンドウ操作レイヤー移行\n  alt-wm   (layer-toggle alt-layer)"
        "@cap-ctrl @alt-wm @cmd-eng @spc-nav @cmd-jp @alt-wm @whisper  @esc-eng"
        "@alt-ctrl-toggle _ _ @hyp-d _ _ @alt-ctrl-toggle _"
        "(deflayer nav\n  _     _     _     _     _     _     _     _"
        "(deflayer alt-ctrl-layer\n  _     _     _     _     _     _     _     _"
        "fn ;; fn"
        "@fnk ;; fn"
        "_ ;; fn"
        "_ ;; fn"
        "_ ;; fn"
      ]
      original;
in
replaced
