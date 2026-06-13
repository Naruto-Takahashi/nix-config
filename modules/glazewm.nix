# =========================================================================
# GlazeWM & Zebar 宣言的設定モジュール
# =========================================================================
{ config, dotfilesPath, ... }:

{
  # GlazeWM 設定ディレクトリの宣言的配置
  # mkOutOfStoreSymlink を使用して、リポジトリ内のファイルを直接リンクします。
  xdg.configFile."glazewm" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/glazewm";
    force = true;
  };

  # Zebar 設定ディレクトリの宣言的配置
  xdg.configFile."zebar" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/zebar";
    force = true;
  };

  # AutoHotkey 設定ディレクトリの宣言的配置
  xdg.configFile."ahk" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ahk";
    force = true;
  };
}
