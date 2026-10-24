# =========================================================================
# WezTerm ターミナルエミュレータ宣言的設定モジュール
# =========================================================================
# Lua 設定はリポジトリ実ファイルへの直結リンク (mkOutOfStoreSymlink) で配置する。
# switch 不要でホットリロードが効き、キーバインドの微調整が即時反映される。
{ config, pkgs, dotfilesPath, ... }:

{
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
  };

  xdg.configFile."wezterm/wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/apps/wezterm/wezterm.lua";
  xdg.configFile."wezterm/keybinds.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/apps/wezterm/keybinds.lua";
}
