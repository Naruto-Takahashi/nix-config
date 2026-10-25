# =========================================================================
# WSL環境用 Windows側への設定同期スクリプト (sync-win)
# =========================================================================
# WSL側で生成された WezTerm, Komorebi, AHK, YASB, Vivaldi, Kanata 設定を
# Windowsホスト側の所定パスへ同期する。
{ pkgs, windowsHome }:

pkgs.writeShellApplication {
  name = "sync-win";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    echo "Syncing WezTerm config..."
    mkdir -p ${windowsHome}/.config/wezterm
    cp ~/.config/wezterm/*.lua ${windowsHome}/.config/wezterm/

    mkdir -p ${windowsHome}/Tools/Customization
    if [ -d ~/.config/ahk ]; then
        echo "Syncing AutoHotkey scripts..."
        cp -rL ~/.config/ahk/* ${windowsHome}/Tools/Customization/
    fi

    echo "Syncing Komorebi config..."
    mkdir -p ${windowsHome}/.config/komorebi
    cp -L ~/.config/komorebi/komorebi.json ${windowsHome}/.config/komorebi/
    cp -L ~/.config/komorebi/komorebi.ahk ${windowsHome}/.config/komorebi/
    cp -L ~/.config/komorebi/applications.json ${windowsHome}/.config/komorebi/
    cp -L ~/.config/komorebi/workspace-watcher.ps1 ${windowsHome}/.config/komorebi/
    cp -L ~/.config/komorebi/komorebi.json ${windowsHome}/
    cp -L ~/.config/komorebi/applications.json ${windowsHome}/
    rm -f "${windowsHome}/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/komorebi.ahk"
    cp -L ~/.config/komorebi/startup.ps1 ${windowsHome}/Tools/Customization/
    cp -L ~/.config/komorebi/setup-windows.ps1 ${windowsHome}/Tools/Customization/

    echo "Syncing YASB config..."
    mkdir -p ${windowsHome}/.config/yasb
    cp -rL ~/.config/yasb/* ${windowsHome}/.config/yasb/
    if [ -x "$HOME/.local/bin/matugen-apply" ]; then
        "$HOME/.local/bin/matugen-apply" --reapply
    fi

    echo "Syncing Vivaldi CSS..."
    mkdir -p ${windowsHome}/Tools/Vivaldi
    cp -L ~/.config/vivaldi/glass.css ${windowsHome}/Tools/Vivaldi/glass.css
    # 廃止したCSSの残骸を消す (VivaldiはMods Directory内のCSSを全て
    # 読み込むため、残っていると適用され続ける)
    rm -f ${windowsHome}/Tools/Vivaldi/custom.css ${windowsHome}/Tools/Vivaldi/air-zenify.css

    echo "Syncing kanata (Windows)..."
    mkdir -p ${windowsHome}/.config/kanata-wsl
    if ! cmp -s ~/.local/bin/kanata-windows.exe ${windowsHome}/.config/kanata-wsl/kanata-windows.exe; then
        if ! cp -L ~/.local/bin/kanata-windows.exe ${windowsHome}/.config/kanata-wsl/kanata-windows.exe 2>/dev/null; then
            echo "::warning:: kanata-windows.exe の更新に失敗しました (Windows 側で実行中の可能性があります)。kanata を停止してから再度 sync-win を実行してください。" >&2
        fi
    fi
    cp -L ~/.config/kanata-wsl/config.kbd ${windowsHome}/.config/kanata-wsl/config.kbd
    cp -L ~/.config/ahk/ime-off.ahk ~/.config/ahk/ime-on.ahk ${windowsHome}/Tools/Customization/

    echo "Done."
  '';
}
