{ config, dotfilesPath, ... }:
{
  # komorebi のメイン設定ファイル
  xdg.configFile."komorebi/komorebi.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/komorebi.json";
    force = true;
  };

  # komorebi 用の AutoHotkey 設定ファイル
  xdg.configFile."komorebi/komorebi.ahk" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/komorebi.ahk";
    force = true;
  };

  # komorebi のアプリケーション個別設定
  xdg.configFile."komorebi/applications.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/applications.json";
    force = true;
  };
}
