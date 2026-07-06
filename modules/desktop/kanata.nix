# =========================================================================
# Kanata キーボードリマッパー宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # --- Kanata: キーボードリマッパー設定 ---
  # Linux（NixOS）向けのキーマップ設定生成を行います．
  # 1. Ctrl長押し時はそのまま通常の lctl 修飾キーにします（cap-ctrl-action -> lctl）．
  # 2. ウィンドウマネージャーのモディファイアは単一の Super（M-）にします（wmmodifier- -> M-）．
  # 3. eisu/kana（macOS専用の仮想キー）をLinuxで有効なIME切り替えキー（JIS 無変換/変換）に置き換えます．
  xdg.configFile."kanata/config.kbd".text =
    let
      original = builtins.readFile ./config.kbd;
      replaced1 = builtins.replaceStrings [ "cap-ctrl-action" ] [ "lctl" ] original;
      replaced2 = builtins.replaceStrings [ "wmmodifier-" ] [ "M-" ] replaced1;
      replaced3 = builtins.replaceStrings [ "eisu" "kana" ] [ "muhenkan" "henkan" ] replaced2;
    in
      replaced3;
}
