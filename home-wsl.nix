# =========================================================================
# Home Manager WSL環境用設定ファイル (~/.config/home-manager/home-wsl.nix)
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ./modules/zsh.nix           # Zsh シェル環境 (エイリアス, カスタム関数等)
    ./modules/starship.nix      # Starship プロンプト
    ./modules/wezterm.nix       # WezTerm ターミナル
    ./modules/neovim.nix        # Neovim エディタ
    ./modules/glazewm.nix       # GlazeWM & Zebar 設定
    ./modules/direnv.nix        # direnv 設定 (nix-direnv対応)
  ];

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username      = "nalt";
  home.homeDirectory = "/home/nalt";
  home.stateVersion  = "25.11";

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
  ];
}
