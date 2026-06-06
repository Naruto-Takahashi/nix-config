# =========================================================================
# fastfetch 設定モジュール (90度回転ブラケット枠線・グラデーション版)
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
          "separator": "38;2;245;239;201",
          "output": "38;2;160;169;203"
        }
      },
      "modules": [
        // --- Hardware Group ---
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m┌─── Hardware ──────────────────────────────────────────┐\u001b[0m"
        },
        {
          "type": "host",
          "key": "  \u001b[38;2;165;208;245mHost"
        },
        {
          "type": "cpu",
          "key": "  \u001b[38;2;205;224;223mCPU"
        },
        {
          "type": "gpu",
          "key": "  \u001b[38;2;245;239;201mGPU"
        },
        {
          "type": "memory",
          "key": "  \u001b[38;2;255;208;112mMemory"
        },
        {
          "type": "disk",
          "key": "  \u001b[38;2;255;181;117mDisk"
        },
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m└───────────────────────────────────────────────────────┘\u001b[0m"
        },
        // --- Blank line ---
        {
          "type": "custom",
          "format": ""
        },
        // --- Software Group ---
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m┌─── Software ──────────────────────────────────────────┐\u001b[0m"
        },
        {
          "type": "os",
          "key": "  \u001b[38;2;255;154;122mOS"
        },
        {
          "type": "kernel",
          "key": "  \u001b[38;2;255;127;143mKernel"
        },
        {
          "type": "de",
          "key": "  \u001b[38;2;245;112;165mDE"
        },
        {
          "type": "wm",
          "key": "  \u001b[38;2;218;108;188mWM"
        },
        {
          "type": "terminal",
          "key": "  \u001b[38;2;190;108;211mTerminal"
        },
        {
          "type": "packages",
          "key": "  \u001b[38;2;161;108;233mPackages"
        },
        {
          "type": "shell",
          "key": "  \u001b[38;2;130;108;255mShell"
        },
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m└───────────────────────────────────────────────────────┘\u001b[0m"
        },
        // --- Blank line ---
        {
          "type": "custom",
          "format": ""
        },
        // --- Other Group ---
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m┌─── その他 ────────────────────────────────────────────┐\u001b[0m"
        },
        {
          "type": "localip",
          "key": "  \u001b[38;2;58;126;189mLocal IP"
        },
        {
          "type": "custom",
          "format": "\u001b[38;2;160;169;203m└───────────────────────────────────────────────────────┘\u001b[0m"
        }
      ]
    }
  '';
}
