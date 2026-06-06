# =========================================================================
# fastfetch 設定モジュール (カテゴリ連結ボックス・壁紙グラデーション再現版)
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
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m┌─── System ──────────────────────────────────────────\u001b[0m"
        },
        {
          "type": "os",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mOS",
          "keyColor": "38;2;165;208;245"
        },
        {
          "type": "host",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mHost",
          "keyColor": "38;2;205;224;223"
        },
        {
          "type": "kernel",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mKernel",
          "keyColor": "38;2;245;239;201"
        },
        {
          "type": "uptime",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mUptime",
          "keyColor": "38;2;255;208;112"
        },
        // --- Environment/Shell Group ---
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m├─── Environment ─────────────────────────────────────\u001b[0m"
        },
        {
          "type": "packages",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mPackages",
          "keyColor": "38;2;255;181;117"
        },
        {
          "type": "shell",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mShell",
          "keyColor": "38;2;255;154;122"
        },
        {
          "type": "de",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mDE",
          "keyColor": "38;2;255;127;143"
        },
        {
          "type": "wm",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mWM",
          "keyColor": "38;2;245;112;165"
        },
        {
          "type": "terminal",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mTerminal",
          "keyColor": "38;2;218;108;188"
        },
        // --- Hardware Group ---
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m├─── Hardware ────────────────────────────────────────\u001b[0m"
        },
        {
          "type": "display",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mDisplay",
          "keyColor": "38;2;190;108;211"
        },
        {
          "type": "cpu",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mCPU",
          "keyColor": "38;2;161;108;233"
        },
        {
          "type": "gpu",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mGPU",
          "keyColor": "38;2;130;108;255"
        },
        {
          "type": "memory",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mMemory",
          "keyColor": "38;2;98;115;233"
        },
        {
          "type": "disk",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mDisk",
          "keyColor": "38;2;75;122;211"
        },
        {
          "type": "localip",
          "key": "\u001b[38;2;160;169;203m│ \u001b[0mLocal IP",
          "keyColor": "38;2;58;126;189"
        },
        // --- End Border ---
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m└─────────────────────────────────────────────────────\u001b[0m"
        }
      ]
    }
  '';
}
