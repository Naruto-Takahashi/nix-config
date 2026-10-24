# =========================================================================
# Hyprland (Waylandコンポジタ) 宣言的設定モジュール
# =========================================================================
{
  config,
  pkgs,
  dotfilesPath,
  ...
}:

let
  cfgPath = "${dotfilesPath}/modules/wm/hyprland/config";
in
{
  # --- Hyprland本体およびユーティリティ設定のリンク ---
  # リポジトリ実ファイルへの直結リンク (mkOutOfStoreSymlink) で配置する。
  # switch 不要で hyprctl reload や Waybar の即時反映が可能。
  xdg.configFile."hypr/hyprland.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/hypr/hyprland.conf";
  xdg.configFile."hypr/hypridle.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/hypr/hypridle.conf";
  xdg.configFile."hypr/hyprlock.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/hypr/hyprlock.conf";
  xdg.configFile."hypr/configs".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/hypr/configs";
  xdg.configFile."hypr/scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/hypr/scripts";

  # --- Waybar (ステータスバー) 設定のリンク ---
  xdg.configFile."waybar/configs".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/configs";
  xdg.configFile."waybar/style".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/style";
  xdg.configFile."waybar/colors.css".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/colors.css";
  xdg.configFile."waybar/Modules".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/Modules";
  xdg.configFile."waybar/ModulesCustom".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/ModulesCustom";
  xdg.configFile."waybar/ModulesGroups".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/ModulesGroups";
  xdg.configFile."waybar/ModulesWorkspaces".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/waybar/ModulesWorkspaces";

  # --- Rofi (アプリケーションランチャー) 設定のリンク ---
  xdg.configFile."rofi/config.rasi".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgPath}/rofi/config.rasi";

  # --- SwayNC (通知センター) 設定のリンク ---
  xdg.configFile."swaync".source = config.lib.file.mkOutOfStoreSymlink "${cfgPath}/swaync";

  # --- wlogout (ログアウトメニュー) 設定のリンク ---
  xdg.configFile."wlogout".source = config.lib.file.mkOutOfStoreSymlink "${cfgPath}/wlogout";

  # --- Matugen (配色ジェネレーター) 設定のリンク ---
  xdg.configFile."matugen".source = config.lib.file.mkOutOfStoreSymlink "${cfgPath}/matugen";
}
