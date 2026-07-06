# =========================================================================
# Hyprland (Waylandコンポジタ) 宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # --- Hyprland本体およびユーティリティ設定のリンク ---
  # Hyprland本体，アイドル管理，画面ロックなどの設定を配置します．
  xdg.configFile."hypr/hyprland.conf".source = ./config/hypr/hyprland.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./config/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./config/hypr/hyprlock.conf;
  xdg.configFile."hypr/configs".source = ./config/hypr/configs;
  xdg.configFile."hypr/scripts".source = ./config/hypr/scripts;

  # --- Waybar (ステータスバー) 設定のリンク ---
  # Waybar本体の定義や各種モジュール，スタイルシートなどの設定を配置します．
  xdg.configFile."waybar/configs".source = ./config/waybar/configs;
  xdg.configFile."waybar/style".source = ./config/waybar/style;
  xdg.configFile."waybar/colors.css".source = ./config/waybar/colors.css;
  xdg.configFile."waybar/Modules".source = ./config/waybar/Modules;
  xdg.configFile."waybar/ModulesCustom".source = ./config/waybar/ModulesCustom;
  xdg.configFile."waybar/ModulesGroups".source = ./config/waybar/ModulesGroups;
  xdg.configFile."waybar/ModulesWorkspaces".source = ./config/waybar/ModulesWorkspaces;

  # --- Rofi (アプリケーションランチャー) 設定のリンク ---
  # アプリケーション起動メニューなどの定義ファイルを配置します．
  xdg.configFile."rofi/config.rasi".source = ./config/rofi/config.rasi;

  # --- SwayNC (通知センター) 設定のリンク ---
  # デスクトップ通知管理の設定を配置します．
  xdg.configFile."swaync".source = ./config/swaync;

  # --- wlogout (ログアウトメニュー) 設定のリンク ---
  # システム終了やログアウトを行うメニュー設定を配置します．
  xdg.configFile."wlogout".source = ./config/wlogout;

  # --- Matugen (配色ジェネレーター) 設定のリンク ---
  # システム配色を動的に生成・反映する設定を配置します．
  xdg.configFile."matugen".source = ./config/matugen;
}
