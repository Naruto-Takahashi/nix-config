{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # Declarative configuration folder linking (Directory Source mode)
  # -----------------------------------------------------------------------
  xdg.configFile."hypr".source = ./config/hypr;
  xdg.configFile."waybar".source = ./config/waybar;
  xdg.configFile."rofi/config.rasi".source = ./config/rofi/config.rasi;
  xdg.configFile."rofi/colors.rasi".source = ./config/rofi/colors.rasi;
  xdg.configFile."swaync".source = ./config/swaync;
  xdg.configFile."wlogout".source = ./config/wlogout;
  xdg.configFile."cava".source = ./config/cava;
  xdg.configFile."kitty".source = ./config/kitty;
  xdg.configFile."matugen".source = ./config/matugen;
}
