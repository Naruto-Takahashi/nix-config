#!/usr/bin/env bash
# =========================================================================
# matugen-apply — 壁紙から matugen でパレットを抽出し、各アプリへ展開する
# =========================================================================
# 呼び出し:
#   matugen-apply <壁紙パス (win/wsl)>  YASB の wallpapers ウィジェット run_after から
#   matugen-apply --reapply             sync-win から (前回の壁紙でフル再生成)
#
# 全体の流れ (docs/matugen-palette.md も参照):
#   1. matugen がテンプレート palette.css から yasb-palette.css を生成する
#   2. Mac と共通の modules/theming/matugen/lib/palette.sh がパレットを抽出し、
#      派生色 (complement/triad/accent_pale) の計算と OS 共通アプリ
#      (starship/lazygit/yazi/eza/btop/fzf 等) への展開を行う
#   3. 本スクリプトは Windows 固有部分 (ロック画面/YASB/komorebi/Windows 側
#      WezTerm・starship) だけを担う
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$PATH"

# Windows 側ユーザープロファイル (WSL から見たパス)。動的解決に失敗したら従来値
WIN_HOME="$(wslpath "$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" 2>/dev/null || true)"
[[ -d "$WIN_HOME" ]] || WIN_HOME="/mnt/c/Users/tnaru"

# 多重起動ガード: 壁紙を素早く切り替えると run_after が並走し、
# 古いパレットのプロセスが後から生成物を上書きして世代が混ざるため直列化する
mkdir -p "$HOME/.cache/matugen"
exec 9>"$HOME/.cache/matugen/.apply.lock"
flock 9

CACHE="$HOME/.cache/matugen/yasb-palette.css"

# -------------------------------------------------------------------------
# 1. 壁紙の決定と matugen 実行
# -------------------------------------------------------------------------
if [[ "${1:-}" != "--reapply" ]]; then
    img="${1:?usage: matugen-apply <image path (win or wsl)> | --reapply}"
    # Windowsパス (C:\...) で渡されたら WSL パスへ変換
    if [[ "$img" == *\\* || "$img" == [A-Za-z]:* ]]; then
        img="$(wslpath "$img")"
    fi
else
    # --reapply: 記録済みの壁紙があればそこから完全再生成 (テンプレート更新を反映するため)
    img=""
    [[ -f "$HOME/.cache/matugen/last-wallpaper" ]] && img="$(cat "$HOME/.cache/matugen/last-wallpaper")"
    [[ -f "$img" ]] || img=""
fi

if [[ -n "${img:-}" ]]; then
    # 手動オーバーライド (color-overrides.conf) があればそちらを優先する。
    # matugenの自動抽出は面積優先のため、面積が小さいが目立つ色 (例: クッションの
    # 深緑) を拾えないことがあり、それを人力で補正するための仕組み
    override_hex=""
    overrides_file="$HOME/.config/matugen-wsl/color-overrides.conf"
    if [[ -f "$overrides_file" ]]; then
        img_basename="$(basename "$img")"
        # 該当エントリが無い場合 grep は終了コード1を返し、pipefail 下では
        # スクリプト全体が異常終了してしまう (--source-color-index 0 の自動抽出に
        # フォールバックできず、壁紙を変えても配色が更新されない不具合になっていた)
        override_hex="$(grep -v '^\s*#' "$overrides_file" | grep "^${img_basename}=" | tail -n1 | cut -d= -f2- || true)"
    fi

    if [[ -n "$override_hex" ]]; then
        matugen color hex "$override_hex" -m dark \
            -c "$HOME/.config/matugen-wsl/config.toml"
    else
        # --source-color-index 0: 候補色の対話選択を回避し最有力色を自動採用 (非TTYで必須)
        # -r nearest: 抽出結果はデフォルトフィルタとほぼ変わらない (検証済み) が
        # 大きい壁紙で数百ms速くなる
        matugen image "$img" -m dark --source-color-index 0 -r nearest \
            -c "$HOME/.config/matugen-wsl/config.toml"
    fi
    printf '%s\n' "$img" > "$HOME/.cache/matugen/last-wallpaper"

    # ロック画面の壁紙もデスクトップと同じ画像に追従させる。
    # UWP の UserProfile.LockScreen API を PowerShell の WinRT 投影で呼ぶ
    # (管理者権限不要。Settings アプリと同じ経路)。画像パスは WSLENV の
    # /p フラグで Windows パスに自動変換して $env:LOCK_IMG として渡す。
    # スクリプト本体は -EncodedCommand で渡す (WSL 越しの stdin -Command - は
    # 実行されないため不可。AsTask はオーバーロード解決が効かないので
    # IAsyncOperation/IAsyncAction ともリフレクションで取得する)。
    ps_lockscreen='
      $ErrorActionPreference = "Stop"
      [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
      [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
      Add-Type -AssemblyName System.Runtime.WindowsRuntime
      $methods = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
          $_.Name -eq "AsTask" -and $_.GetParameters().Count -eq 1 }
      $asTaskOp     = ($methods | Where-Object { $_.GetParameters()[0].ParameterType.Name -eq ("IAsyncOperation" + [char]0x60 + "1") })[0]
      $asTaskAction = ($methods | Where-Object { $_.GetParameters()[0].ParameterType.Name -eq "IAsyncAction" })[0]
      $op = [Windows.Storage.StorageFile]::GetFileFromPathAsync($env:LOCK_IMG)
      $file = $asTaskOp.MakeGenericMethod([Windows.Storage.StorageFile]).Invoke($null, @($op)).GetAwaiter().GetResult()
      $asTaskAction.Invoke($null, @([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($file))).GetAwaiter().GetResult() | Out-Null'
    WSLENV="LOCK_IMG/p:${WSLENV:-}" LOCK_IMG="$img" \
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile \
        -EncodedCommand "$(printf '%s' "$ps_lockscreen" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)" \
        >/dev/null 2>&1 || true
fi

# -------------------------------------------------------------------------
# 2. パレット抽出 (WSL / Mac 共通の lib/palette.sh。名前は docs/matugen-palette.md と対応)
# -------------------------------------------------------------------------
# shellcheck source=SCRIPTDIR/../lib/palette.sh
source "$HOME/.config/matugen-common/lib/palette.sh"

# surface は YASB の --base (バー本体/ウィジェットの背景色) と同じロールに揃える。
# 以前は surface2 (--surface2、明るいコンテナ色) を使っていたため、
# WezTerm の画面本体が YASB より明るいグレーになってしまっていた
HAS_PALETTE=0
matugen_build_palette "$CACHE" base && HAS_PALETTE=1

# -------------------------------------------------------------------------
# 3. YASB styles.css (MATUGEN マーカー間をパレットに差し替えて Windows へ配置)
# -------------------------------------------------------------------------
SRC="$HOME/.config/yasb/styles.css"
DEST="${WIN_HOME}/.config/yasb/styles.css"
if [[ -f "$CACHE" ]]; then
    awk -v pal="$CACHE" '
        /\/\* MATUGEN:START \*\// { print; while ((getline line < pal) > 0) print line; skip=1; next }
        /\/\* MATUGEN:END \*\//   { skip=0 }
        !skip
    ' "$SRC" > "$DEST"
else
    cp -L "$SRC" "$DEST"
fi

# 以降のセクションはパレットが揃っているときのみ実行する
if [[ "$HAS_PALETTE" == 1 ]]; then

# -------------------------------------------------------------------------
# 4. komorebi の枠色 (single/floating = accent, monocle = tertiary, unfocused = outline)
# -------------------------------------------------------------------------
for f in "${WIN_HOME}/.config/komorebi/komorebi.json" "${WIN_HOME}/komorebi.json"; do
    [[ -f "$f" ]] && sed -i -E \
        -e "s/(\"single\": *\")#[0-9a-fA-F]{6}/\1${accent}/" \
        -e "s/(\"floating\": *\")#[0-9a-fA-F]{6}/\1${accent}/" \
        -e "s/(\"monocle\": *\")#[0-9a-fA-F]{6}/\1${tertiary}/" \
        -e "s/(\"unfocused\": *\")#[0-9a-fA-F]{6}/\1${outline}/" "$f"
done
"/mnt/c/Program Files/komorebi/bin/komorebic.exe" reload-configuration >/dev/null 2>&1 || true

# -------------------------------------------------------------------------
# 5. OS 共通アプリへの展開 (colors.lua / starship / lazygit / cz / yazi / eza /
#    tealdeer / btop / fzf。lib/palette.sh の matugen_render_common)
# -------------------------------------------------------------------------
matugen_render_common
command cp -f "$HOME/.cache/matugen/colors.lua" "${WIN_HOME}/.config/wezterm/matugen-colors.lua" 2>/dev/null || true

# -------------------------------------------------------------------------
# 6. Windows (PowerShell) 向け starship 変種
# -------------------------------------------------------------------------
# custom.ssh_host は POSIX sh 依存で
# Windows では動かない (プロンプト遅延の原因) ため、静的な PS
# セグメントに置き換えて配置する。
# custom.nixcli_badge (本来distrobox等のコンテナ内だけ表示する意図) は、
# Windows PowerShellではshellを明示しない限りStarshipがcmd.exe経由で
# whenを評価してしまい、cmdは"$container"のようなbash風変数展開をしない
# ためリテラル文字列を非空判定して常にtrue扱いになる不具合があった
# (実機で確認済み: Windowsでも常時「nixcli in <hostname>」が表示されて
# いた)。Windowsでコンテナ内に入ることはそもそも無いため、ssh_hostと
# 同様に丸ごと取り除く
WIN_STARSHIP="${WIN_HOME}/.config/starship.toml"
awk '
    /^\$\{custom\.nixcli_badge\}\\$/ { next }
    /^\$\{custom\.ssh_host\}\\$/ {
        print "[ PS ](fg:on_accent bg:secondary bold)[\xee\x82\xb0](fg:secondary bg:accent)\\"
        next
    }
    /^\[custom\.nixcli_badge\]/ { skip=1 }
    /^\[custom\.ssh_host\]/ { skip=1 }
    skip && /^\[username\]/ { skip=0 }
    !skip
' "$HOME/.cache/matugen/starship.toml" > "${WIN_STARSHIP}.tmp" 2>/dev/null \
    && rm -f "$WIN_STARSHIP" \
    && mv "${WIN_STARSHIP}.tmp" "$WIN_STARSHIP" || true

fi  # HAS_PALETTE
