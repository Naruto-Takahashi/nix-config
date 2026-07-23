# =========================================================================
# Komorebi (Windows用タイル型WM) 宣言的設定モジュール
# =========================================================================
{ config, dotfilesPath, ... }:

{
  # --- Komorebi設定ファイル ---
  # メイン設定ファイル．
  xdg.configFile."komorebi/komorebi.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/komorebi.json";
    force = true;
  };

  # アプリケーションごとの個別設定ファイル．
  xdg.configFile."komorebi/applications.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/applications.json";
    force = true;
  };

  # --- Windows環境向け連携スクリプトおよび設定 ---
  # 操作用ホットキーを定義するAutoHotkeyスクリプト．
  xdg.configFile."komorebi/komorebi.ahk" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/komorebi.ahk";
    force = true;
  };

  # ログオン時にタスクスケジューラから呼び出されるスタートアップスクリプト．
  xdg.configFile."komorebi/startup.ps1" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/startup.ps1";
    force = true;
  };

  # Windows環境構築時のパッケージ導入などを自動化するスクリプト．
  xdg.configFile."komorebi/setup-windows.ps1" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/setup-windows.ps1";
    force = true;
  };
}
