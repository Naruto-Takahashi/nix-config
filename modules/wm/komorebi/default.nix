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

  # ログオン時にタスクスケーラで呼び出されるスタートアップスクリプト
  xdg.configFile."komorebi/startup.ps1" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/startup.ps1";
    force = true;
  };

  # Windows環境構築・自動化スクリプト
  xdg.configFile."komorebi/setup-windows.ps1" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/setup-windows.ps1";
    force = true;
  };
}
