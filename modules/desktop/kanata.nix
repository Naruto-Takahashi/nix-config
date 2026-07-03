# =========================================================================
# Kanata キーボードリマッパー設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # Kanata: キーボードリマッパー（宣言的キーマップ管理）
  # -----------------------------------------------------------------------
  # Linux (NixOS) 向けの設定生成: 
  # 1. Ctrl長押し時はそのまま通常の lctl 修飾キーにする (cap-ctrl-action -> lctl)
  # 2. ウィンドウマネージャーのモディファイアは単一の Super (M-) にする (wmmodifier- -> M-)
  xdg.configFile."kanata/config.kbd".text =
    let
      original = builtins.readFile ./config.kbd;
      replaced1 = builtins.replaceStrings [ "cap-ctrl-action" ] [ "lctl" ] original;
      replaced2 = builtins.replaceStrings [ "wmmodifier-" ] [ "M-" ] replaced1;
      # eisu/kana は macOS 専用の仮想キーで Linux 版 kanata には存在しないため、
      # Linux で有効な IME 切り替えキー (JIS 無変換/変換) に置き換える
      replaced3 = builtins.replaceStrings [ "eisu" "kana" ] [ "muhenkan" "henkan" ] replaced2;
    in
      replaced3;
}
