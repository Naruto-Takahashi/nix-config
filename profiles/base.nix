# =========================================================================
# 全ホスト共通プロファイル (シェル環境 + コア CLI アプリ)
# =========================================================================
# wsl / mac / ubuntu / nixos の全ホストが import する共通セット。
# ホスト固有のモジュール (WM や OS 依存アプリ) は各 hosts/*/ 側で追加する。
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # 各モジュールで利用するグローバル引数
  # -----------------------------------------------------------------------
  # mkOutOfStoreSymlink で参照するこのリポジトリのチェックアウト位置。
  # リポジトリをこのパス以外に clone すると、symlink 配置される設定
  # (starship / yasb / komorebi / vivaldi / matugen-common など) が
  # すべて壊れるので注意。
  _module.args = {
    dotfilesPath = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/nix-config";
  };

  imports = [
    ../modules/shell/zsh
    ../modules/shell/starship
    ../modules/shell/direnv
    ../modules/shell/fastfetch
    ../modules/apps/wezterm
    ../modules/apps/neovim
    ../modules/apps/yazi
    ../modules/apps/lazygit
    ../modules/theming/matugen
  ];

  # -----------------------------------------------------------------------
  # 全ホスト共通の小物 CLI ツール
  # -----------------------------------------------------------------------
  # tldr クライアント (コマンドの使用例を素早く確認する)
  programs.tealdeer = {
    enable = true;
    settings = {
      updates.auto_update = true; # キャッシュが古いとき自動で `tldr --update` 相当を実行
    };
  };

  home.packages = [
    pkgs.smassh # MonkeyType 風の TUI タイピング練習
  ];
}
