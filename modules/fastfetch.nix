# =========================================================================
# fastfetch 設定モジュール (罫線グループ化・壁紙グラデーション再現版)
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
          "width": 14
        },
        "color": {
          "separator": "38;2;245;239;201",
          "output": "38;2;160;169;203"
        }
      },
      "modules": [
        {
          "type": "title",
          "color": {
            "user": "38;2;165;208;245",
            "at": "38;2;165;208;245",
            "host": "38;2;165;208;245"
          }
        },
        "separator",
        // --- System Group ---
        {
          "type": "os",
          "key": "┌ OS",
          "keyColor": "38;2;165;208;245"
        },
        {
          "type": "host",
          "key": "├ Host",
          "keyColor": "38;2;205;224;223"
        },
        {
          "type": "kernel",
          "key": "├ Kernel",
          "keyColor": "38;2;245;239;201"
        },
        {
          "type": "uptime",
          "key": "└ Uptime",
          "keyColor": "38;2;255;208;112"
        },
        // --- Blank line ---
        {
          "type": "custom",
          "format": ""
        },
        // --- Environment/Shell Group ---
        {
          "type": "packages",
          "key": "┌ Packages",
          "keyColor": "38;2;255;181;117"
        },
        {
          "type": "shell",
          "key": "├ Shell",
          "keyColor": "38;2;255;154;122"
        },
        {
          "type": "de",
          "key": "├ DE",
          "keyColor": "38;2;255;127;143"
        },
        {
          "type": "wm",
          "key": "├ WM",
          "keyColor": "38;2;245;112;165"
        },
        {
          "type": "terminal",
          "key": "└ Terminal",
          "keyColor": "38;2;218;108;188"
        },
        // --- Blank line ---
        {
          "type": "custom",
          "format": ""
        },
        // --- Hardware Group ---
        {
          "type": "display",
          "key": "┌ Display",
          "keyColor": "38;2;190;108;211"
        },
        {
          "type": "cpu",
          "key": "├ CPU",
          "keyColor": "38;2;161;108;233"
        },
        {
          "type": "gpu",
          "key": "├ GPU",
          "keyColor": "38;2;130;108;255"
        },
        {
          "type": "memory",
          "key": "├ Memory",
          "keyColor": "38;2;98;115;233"
        },
        {
          "type": "disk",
          "key": "├ Disk",
          "keyColor": "38;2;75;122;211"
        },
        {
          "type": "localip",
          "key": "└ Local IP",
          "keyColor": "38;2;58;126;189"
        }
      ]
    }
  '';
}
