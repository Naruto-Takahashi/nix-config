{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # Declarative configuration folder linking (Directory Source mode)
  # -----------------------------------------------------------------------
  xdg.configFile."hypr/hyprland.conf".source = ./config/hypr/hyprland.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./config/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./config/hypr/hyprlock.conf;
  xdg.configFile."hypr/configs".source = ./config/hypr/configs;
  xdg.configFile."hypr/scripts".source = ./config/hypr/scripts;

  xdg.configFile."waybar/configs".source = ./config/waybar/configs;
  xdg.configFile."waybar/style".source = ./config/waybar/style;
  xdg.configFile."waybar/Modules".source = ./config/waybar/Modules;
  xdg.configFile."waybar/ModulesCustom".source = ./config/waybar/ModulesCustom;
  xdg.configFile."waybar/ModulesGroups".source = ./config/waybar/ModulesGroups;
  xdg.configFile."waybar/ModulesWorkspaces".source = ./config/waybar/ModulesWorkspaces;

  xdg.configFile."rofi/config.rasi".source = ./config/rofi/config.rasi;

  xdg.configFile."swaync".source = ./config/swaync;
  xdg.configFile."wlogout".source = ./config/wlogout;

  xdg.configFile."waybar/colors.css".source = ./config/waybar/colors.css;

  xdg.configFile."matugen".source = ./config/matugen;
}
