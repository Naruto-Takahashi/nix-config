#!/usr/bin/env bash
# fzf による壁紙ピッカー (ALT+W から WezTerm 内で起動)
# TAB/矢印で移動し ENTER で選択 → Windows の壁紙を変更し matugen-apply で配色を追従
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$PATH"

# Windows 側ユーザープロファイル (WSL から見たパス)。動的解決に失敗したら従来値
WIN_HOME="$(wslpath "$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" 2>/dev/null || true)"
[[ -d "$WIN_HOME" ]] || WIN_HOME="/mnt/c/Users/tnaru"

WSL_DIR="${WIN_HOME}/OneDrive/画像/wallpapers"
WIN_DIR="$(wslpath -w "$WSL_DIR")"

sel="$(find "$WSL_DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \) \
        -printf '%f\n' | sort |
      fzf --bind 'tab:down,btab:up' --prompt='wallpaper> ' --height=100% --border \
          --header='TAB/矢印: 移動, ENTER: 決定, ESC: キャンセル')" || exit 0
[[ -n "$sel" ]] || exit 0

win_path="${WIN_DIR}\\${sel}"

# Windows の壁紙を変更 (SystemParametersInfo: SPI_SETDESKWALLPAPER)
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "
  Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class WP { [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }';
  [WP]::SystemParametersInfo(20, 0, '${win_path}', 3) | Out-Null
"

# 配色一式 (YASB/komorebi/starship/WezTerm/fzf/lazygit/nvim/yazi) を追従
"$HOME/.local/bin/matugen-apply" "$win_path"
