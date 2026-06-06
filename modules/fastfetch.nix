# =========================================================================
# fastfetch 設定モジュール (Starship ゴールドカラー統一版)
# =========================================================================
{ config, pkgs, ... }:

{
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": "none",
      "display": {
        "separator": ": ",
        "key": {
          "width": 12
        },
        "color": {
          "separator": "38;2;255;194;13"
        }
      },
      "modules": [
        {
          "type": "title",
          "color": {
            "user": "38;2;255;194;13",
            "at": "38;2;255;194;13",
            "host": "38;2;255;194;13"
          }
        },
        "separator",
        {
          "type": "os",
          "key": "OS",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "host",
          "key": "Host",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "kernel",
          "key": "Kernel",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "uptime",
          "key": "Uptime",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "packages",
          "key": "Packages",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "shell",
          "key": "Shell",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "de",
          "key": "DE",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "wm",
          "key": "WM",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "terminal",
          "key": "Terminal",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "display",
          "key": "Display",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "cpu",
          "key": "CPU",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "gpu",
          "key": "GPU",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "memory",
          "key": "Memory",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "disk",
          "key": "Disk",
          "keyColor": "38;2;255;194;13"
        },
        {
          "type": "localip",
          "key": "Local IP",
          "keyColor": "38;2;255;194;13"
        }
      ]
    }
  '';
}
