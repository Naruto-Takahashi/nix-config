# =========================================================================
# WezTerm ターミナルエミュレータ宣言的設定モジュール
# =========================================================================
# Lua 設定は同ディレクトリの実ファイル (wezterm.lua / keybinds.lua) を配置する。
# Nix 文字列への埋め込みをやめ、エディタ支援とエスケープ安全性を優先した構成。
{ config, pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
  };

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  xdg.configFile."wezterm/keybinds.lua".source = ./keybinds.lua;
}
