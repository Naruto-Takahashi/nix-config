# =========================================================================
# NixOS 環境用 Home Manager 設定ファイル
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../modules/shell/fastfetch.nix
    ../../modules/desktop/packages.nix
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
    ../../modules/desktop/kanata.nix
    # ../../modules/desktop
    ../../modules/apps/wezterm.nix
    ../../modules/apps/neovim
    ../../modules/wm/hyprland
    ../../modules/shell/direnv.nix
    ../../modules/apps/yazi.nix
    ../../modules/apps/lazygit.nix
  ];

  # ユーザーメタデータ
  home.username      = "nalt";
  home.homeDirectory = "/home/nalt";
  home.stateVersion  = "25.11";

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # Nixでインストールしたフォントを認識させる
  fonts.fontconfig.enable = true;

  # デフォルトターミナル環境変数の設定
  home.sessionVariables = {
    TERMINAL = "wezterm";
  };

  # カーソルテーマの設定 (Bibata Modern Ice)
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # Bash の基本設定
  programs.bash = {
    enable = true;
  };

  # Fcitx5 の入力メソッド設定 (US配列キーボード + Mozc) をコードで管理
  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=Default
    Default Layout=us
    IMList/0/Name=keyboard-us
    IMList/1/Name=mozc

    [Groups]
    NumberOfGroups=1
  '';
}
