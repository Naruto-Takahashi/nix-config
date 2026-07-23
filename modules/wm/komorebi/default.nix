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

  # --- AutoHotkey (IME制御・SandS・キーリマップ・komorebi/YASB操作) ---
  # main.ahk が唯一のエントリポイントで、komorebi.ahk はそこから#Includeされる
  # (起動するAHKプロセスを1つに集約するため)。sync-win が ~/.config/ahk 配下を
  # まるごと Windows の Tools/Customization へコピーする
  # (modules/shell/zsh/functions.zsh 参照)。
  xdg.configFile."ahk/main.ahk" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/ahk/main.ahk";
    force = true;
  };
  xdg.configFile."ahk/komorebi.ahk" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/ahk/komorebi.ahk";
    force = true;
  };
  xdg.configFile."ahk/lib/ime_functions.ahk" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/komorebi/ahk/lib/ime_functions.ahk";
    force = true;
  };
}
