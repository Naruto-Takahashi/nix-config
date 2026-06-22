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
    # ../../modules/wm/i3
    ../../modules/shell/direnv.nix
    ../../modules/apps/yazi.nix
    ../../modules/services/chrome-remote-desktop.nix
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

  # Bash の基本設定
  programs.bash = {
    enable = true;
  };
}
