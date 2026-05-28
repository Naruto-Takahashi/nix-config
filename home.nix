# =========================================================================
# Home Manager メイン設定ファイル (~/.config/home-manager/home.nix)
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ./modules/packages.nix      # パッケージ管理 (maim, slop, antigravity-cli等)
    ./modules/zsh.nix           # Zsh シェル環境 (エイリアス, カスタム関数等)
    ./modules/starship.nix      # Starship プロンプト
    ./modules/kanata.nix        # Kanata キーボードリマッパー (Alt-to-Superレイヤー)
    ./modules/desktop.nix       # デスクトップ環境 (日本語入力Fcitx5, 環境変数)
    ./modules/wezterm.nix       # WezTerm ターミナル
    ./modules/neovim.nix        # Neovim エディタ
    ./modules/gnome-tiling.nix  # GNOME タイリング拡張機能 (Forge)
    ./modules/i3.nix            # i3 Window Manager 設定
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
