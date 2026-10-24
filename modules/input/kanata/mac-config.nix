# =========================================================================
# Kanata macOS 用設定テキスト (プレースホルダ置換済み)
# =========================================================================
# config.kbd はプレースホルダー (cap-ctrl-action / wmmodifier- / eisu / kana)
# を含むテンプレート。macOS では以下に置換して使う:
#   1. macOSでは Ctrl 長押し時に ctrl-layer を有効化する (cap-ctrl-action -> (layer-toggle ctrl-layer))
#   2. ウィンドウマネージャーのモディファイアは Ctrl + Cmd (C-M-) にする (wmmodifier- -> C-M-)
#   3. macOSでは Alt + Space (alt-layer + spc) を A-spc (Alt + Space) に直接マッピングする (@hyp-d -> A-spc)
#   4. macOSでは Alt + Tab (alt-layer + tab) を A-tab (Alt + Tab) に直接マッピングする (AltTabアプリ連携用)
let
  original = builtins.readFile ./config.kbd;

  replaced1 = builtins.replaceStrings [ "cap-ctrl-action" ] [ "(layer-toggle ctrl-layer)" ] original;
  replaced2 = builtins.replaceStrings [ "wmmodifier-" ] [ "C-M-" ] replaced1;
  replaced3 = builtins.replaceStrings [ "@hyp-d " ] [ "A-spc " ] replaced2;
  replaced4 = builtins.replaceStrings [ "@hyp-tab" ] [ "A-tab" ] replaced3;
in
  replaced4
