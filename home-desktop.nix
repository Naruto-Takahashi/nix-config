# =========================================================================
# Home Manager Linuxデスクトップ環境用設定ファイル (~/.config/home-manager/home-desktop.nix)
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ./modules/fastfetch.nix     # fastfetch 設定
    ./modules/packages.nix      # パッケージ管理 (maim, slop, antigravity-cli等)
    ./modules/zsh.nix           # Zsh シェル環境 (エイリアス, カスタム関数等)
    ./modules/starship.nix      # Starship プロンプト
    ./modules/kanata.nix        # Kanata キーボードリマッパー (Alt-to-Superレイヤー)
    ./modules/desktop.nix       # デスクトップ環境 (日本語入力Fcitx5, Environment variables)
    ./modules/wezterm.nix       # WezTerm ターミナル
    ./modules/neovim.nix        # Neovim エディタ
    ./modules/i3.nix            # i3 Window Manager 設定
    ./modules/direnv.nix        # direnv 設定 (nix-direnv対応)
    ./modules/yazi.nix          # Yazi ファイルマネージャ設定
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

  # Nixでインストールしたフォントをシステムのfontconfigにリンクし認識させる
  fonts.fontconfig.enable = true;

  # -----------------------------------------------------------------------
  # Bash の基本設定と Zsh への自動切り替え設定
  # -----------------------------------------------------------------------
  programs.bash = {
    enable = true;
    initExtra = ''
      # ログインシェルかつインタラクティブシェル（通常の端末起動）の場合のみ、Zshへ自動的に切り替えます
      if [ -t 1 ]; then
        exec /home/nalt/.nix-profile/bin/zsh
      fi
    '';
  };
}
