# =========================================================================
# Home Manager Linuxデスクトップ環境用設定ファイル (~/.config/home-manager/home-desktop.nix)
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
    ../../modules/desktop
    ../../modules/apps/wezterm
    ../../modules/apps/neovim
    ../../modules/shell/direnv.nix
    ../../modules/apps/yazi
    ../../modules/apps/lazygit.nix
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

  # Ubuntu環境専用：WezTerm等でGPUを使用するためのOpenGLラッパー
  home.packages = [
    nixgl.packages.${pkgs.system}.nixGLDefault
  ];
}
