# =========================================================================
# Komorebi & Zebar 宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # komorebi のメイン設定ファイル
  xdg.configFile."komorebi/komorebi.json".source = ./komorebi.json;

  # whkd キーバインド設定ファイル
  # 配置先: ~/.config/whkdrc
  xdg.configFile."whkdrc".source = ./whkdrc;

  # komorebi のアプリケーション個別設定
  # NOTE: komorebi.json の app_specific_configuration_path は
  #       Windows パス "C:\Users\tnaru\applications.json" を参照しているため，
  #       sync-win でコピーする必要がある（xdg では~/.config/に配置）
  xdg.configFile."komorebi/applications.json".source = ./applications.json;

  # Zebar 設定ディレクトリの宣言的配置（GlazeWM モジュールから移植）
  xdg.configFile."zebar" = {
    source = ../glazewm/zebar;
    recursive = true;
  };

  # AutoHotkey 設定ディレクトリの宣言的配置（メインの main.ahk を流用）
  xdg.configFile."ahk".source = ../glazewm/ahk;
}
