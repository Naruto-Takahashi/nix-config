# =========================================================================
# Home Manager WSL環境用設定ファイル (~/.config/home-manager/home-wsl.nix)
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../modules/shell/fastfetch.nix
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
    ../../modules/apps/wezterm
    ../../modules/apps/neovim
    # ../../modules/wm/glazewm
    ../../modules/wm/komorebi
    ../../modules/wm/yasb
    ../../modules/shell/direnv.nix
    ../../modules/apps/yazi.nix
    ../../modules/services/obsidian-mcp.nix
    ../../modules/apps/lazygit.nix
    ../../modules/apps/vivaldi
  ];

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username      = "nalt";
  home.homeDirectory = "/home/nalt";
  home.stateVersion  = "25.11";

  # -----------------------------------------------------------------------
  # 各モジュールで利用するグローバル引数
  # -----------------------------------------------------------------------
  _module.args = {
    dotfilesPath = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/nix-config";
  };

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # 非自由ライセンス（Vivaldi等プロプライエタリなソフトウェア）のインストールを許可
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------------------------------
  # インストールするパッケージの定義
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    gemini-cli-bin
    codex
    claude-code
    fastfetch
    cowsay
    fortune
    lolcat
    nodejs_22
    wsl-open # Windowsの規定のアプリでファイルを開くためのコマンド
    gh
    sshfs   # SSH経由でリモートホストのファイルシステムをマウントするためのツール
    cava
    matugen # 壁紙から配色を抽出しYASB等へ流し込むツール
  ];
}
