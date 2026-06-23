# =========================================================================
# Home Manager Mac環境用設定ファイル (~/.config/home-manager/hosts/mac/default.nix)
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../modules/shell/fastfetch.nix
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
    ../../modules/apps/wezterm.nix
    ../../modules/apps/neovim
    ../../modules/shell/direnv.nix
    ../../modules/apps/yazi.nix
    ../../modules/apps/lazygit.nix
  ];

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username      = "nalt";
  home.homeDirectory = "/Users/nalt";
  home.stateVersion  = "25.11";

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # 非自由ライセンスのインストールを許可
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------------------------------
  # インストールするパッケージの定義
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    fastfetch
    cowsay
    fortune
    lolcat
    nodejs_22
    gh
  ];
}
