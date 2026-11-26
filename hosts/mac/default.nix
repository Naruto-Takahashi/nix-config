# =========================================================================
# Home Manager Mac環境用設定ファイル (hosts/mac/default.nix)
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../profiles/base.nix
    ../../modules/wm/aerospace
    ../../modules/wm/autoraise
    ../../modules/wm/hammerspoon
    ../../modules/theming/matugen/mac
    ../../modules/gui/vivaldi
    ../../modules/input/karabiner # キーボードリマップ (Karabiner-Elements)
  ];

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username = "nalt";
  home.homeDirectory = "/Users/nalt";
  home.stateVersion = "25.11";

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # -----------------------------------------------------------------------
  # インストールするパッケージの定義 (Mac固有パッケージ)
  # -----------------------------------------------------------------------
  # hackgen-nf-font は darwin.nix の fonts.packages でシステムフォントとして配置。
  home.packages = with pkgs; [
    nodejs_22
  ];

  # フォントの設定を有効化
  fonts.fontconfig.enable = true;
}
