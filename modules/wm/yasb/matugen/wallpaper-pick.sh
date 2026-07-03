#!/usr/bin/env bash
# fzf による壁紙ピッカー (ALT+W から WezTerm 内で起動)
# TAB/矢印で移動し ENTER で選択 → Windows の壁紙を変更し yasb-theme で配色を追従
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$PATH"

WSL_DIR="/mnt/c/Users/tnaru/OneDrive/画像/wallpapers"
WIN_DIR='C:\Users\tnaru\OneDrive\画像\wallpapers'

sel="$(find "$WSL_DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \) \
        -printf '%f\n' | sort |
      fzf --bind 'tab:down,btab:up' --prompt='wallpaper> ' --height=100% --border \
          --header='TAB/矢印: 移動, ENTER: 決定, ESC: キャンセル')" || exit 0
[[ -n "$sel" ]] || exit 0

win_path="${WIN_DIR}\\${sel}"

# Windows の壁紙を変更 (SystemParametersInfo: SPI_SETDESKWALLPAPER)
powershell.exe -NoProfile -Command "
  Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class WP { [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }';
  [WP]::SystemParametersInfo(20, 0, '${win_path}', 3) | Out-Null
"

# 配色一式 (YASB/komorebi/starship/WezTerm/fzf/lazygit/nvim/yazi) を追従
"$HOME/.local/bin/yasb-theme" "$win_path"
