# =========================================================================
# WSL環境用 Windows側への設定同期スクリプト (sync-win)
# =========================================================================
# WSL側で生成された WezTerm, Komorebi, AHK, YASB, Vivaldi, Kanata 設定を
# Windowsホスト側の所定パスへ同期する。
{ pkgs }:

pkgs.writeShellApplication {
  name = "sync-win";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    echo "Syncing WezTerm config..."
    mkdir -p /mnt/c/Users/tnaru/.config/wezterm
    cp ~/.config/wezterm/*.lua /mnt/c/Users/tnaru/.config/wezterm/

    mkdir -p /mnt/c/Users/tnaru/Tools/Customization
    if [ -d ~/.config/ahk ]; then
        echo "Syncing AutoHotkey scripts..."
        cp -rL ~/.config/ahk/* /mnt/c/Users/tnaru/Tools/Customization/
    fi

    echo "Syncing Komorebi config..."
    mkdir -p /mnt/c/Users/tnaru/.config/komorebi
    cp -L ~/.config/komorebi/komorebi.json /mnt/c/Users/tnaru/.config/komorebi/
    cp -L ~/.config/komorebi/komorebi.ahk /mnt/c/Users/tnaru/.config/komorebi/
    cp -L ~/.config/komorebi/applications.json /mnt/c/Users/tnaru/.config/komorebi/
    cp -L ~/.config/komorebi/workspace-watcher.ps1 /mnt/c/Users/tnaru/.config/komorebi/
    cp -L ~/.config/komorebi/komorebi.json /mnt/c/Users/tnaru/
    cp -L ~/.config/komorebi/applications.json /mnt/c/Users/tnaru/
    rm -f "/mnt/c/Users/tnaru/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/komorebi.ahk"
    cp -L ~/.config/komorebi/startup.ps1 /mnt/c/Users/tnaru/Tools/Customization/
    cp -L ~/.config/komorebi/setup-windows.ps1 /mnt/c/Users/tnaru/Tools/Customization/

    echo "Syncing YASB config..."
    mkdir -p /mnt/c/Users/tnaru/.config/yasb
    cp -rL ~/.config/yasb/* /mnt/c/Users/tnaru/.config/yasb/
    if [ -x "$HOME/.local/bin/matugen-apply" ]; then
        "$HOME/.local/bin/matugen-apply" --reapply
    fi

    echo "Syncing Vivaldi CSS..."
    mkdir -p /mnt/c/Users/tnaru/Tools/Vivaldi
    cp -L ~/.config/vivaldi/custom.css /mnt/c/Users/tnaru/Tools/Vivaldi/custom.css
    cp -L ~/.config/vivaldi/air-zenify.css /mnt/c/Users/tnaru/Tools/Vivaldi/air-zenify.css

    echo "Syncing kanata (Windows)..."
    mkdir -p /mnt/c/Users/tnaru/.config/kanata-wsl
    cp -L ~/.local/bin/kanata-windows.exe /mnt/c/Users/tnaru/.config/kanata-wsl/kanata-windows.exe
    cp -L ~/.config/kanata-wsl/config.kbd /mnt/c/Users/tnaru/.config/kanata-wsl/config.kbd
    cp -L ~/.config/ahk/ime-off.ahk ~/.config/ahk/ime-on.ahk /mnt/c/Users/tnaru/Tools/Customization/

    echo "Done."
  '';
}
