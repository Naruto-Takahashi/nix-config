# =========================================================================
# Neovim テキストエディタ宣言的設定モジュール
# =========================================================================
{ config, pkgs, lib, dotfilesPath, ... }:

{
  # Neovim パッケージのインストール
  # programs.neovim を有効にすると Home Manager が自動で init.lua を管理しようとして
  # シンボリックリンクと衝突するため、パッケージを直接インストールします。
  home.packages = with pkgs; [
    neovim
    # 必要に応じて追加のツール（ripgrep, fd等）をここに含める
    ripgrep
    fd
    gcc
  ];

  # -----------------------------------------------------------------------
  # Neovim 設定ディレクトリの宣言的配置 (ディレクトリ・ソース方式)
  # -----------------------------------------------------------------------
  # mkOutOfStoreSymlink を使用して、リポジトリ内のファイルを直接リンクします。
  # これにより、設定変更が即座に反映されるようになります。
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/nvim";
    force = true;
  };

  # Rofi テーマ設定
  xdg.configFile."rofi/simple_theme.rasi" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/simple_theme.rasi";
    force = true;
  };
}
