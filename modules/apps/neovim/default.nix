# =========================================================================
# Neovim テキストエディタ宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # Neovim パッケージの有効化
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Copilot.lua は Neovim 内で Node.js を使うため、Neovim 自体にも同梱する
    withNodeJs = true;
  };

  # -----------------------------------------------------------------------
  # Neovim 設定ディレクトリの宣言的配置 (ディレクトリ・ソース方式)
  # -----------------------------------------------------------------------
  xdg.configFile."nvim".source = ./nvim;

  # Rofi テーマ設定
  xdg.configFile."rofi/simple_theme.rasi".source = ../../desktop/simple_theme.rasi;
}
