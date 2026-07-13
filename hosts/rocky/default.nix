# =========================================================================
# Home Manager Rocky Linux環境用設定ファイル（CLI部分のみ、GUI/WM除外）
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  imports = [
    ../../modules/shell/fastfetch.nix
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
    ../../modules/shell/direnv.nix
    ../../modules/apps/neovim
    ../../modules/apps/yazi.nix
    ../../modules/apps/lazygit.nix
  ];

  home.username      = "pt_takahashi";
  home.homeDirectory = "/home/pt_takahashi";
  home.stateVersion  = "25.11";

  _module.args = {
    dotfilesPath = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/nix-config";
  };

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # 基本CLIユーティリティ
    eza
    bat
    fzf
    zoxide
    ghq
    git
    gh
    ripgrep

    # 開発環境
    gcc
    gnumake
    python3
    nodejs_22

    # クリップボード
    xclip

    # AI連携ツール
    claude-code

    # ジョークツール
    cowsay
    fortune
    lolcat
    fastfetch
  ];
}
