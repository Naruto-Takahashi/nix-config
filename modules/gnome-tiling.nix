# =========================================================================
# GNOME タイリング拡張機能 (Forge) モジュール
# =========================================================================
{ config, pkgs, lib, ... }:

{
  # 必要なパッケージのインストール
  home.packages = [
    pkgs.gnomeExtensions.forge
  ];

  # dconf 設定による拡張機能の有効化と設定
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "forge@jura.projects.gihub.com"
        "ubuntu-dock@ubuntu.com"
        "desktop-icons@csoriano"
        "tiling-assistant@ubuntu.com"
      ];
      # 💡 拡張機能のバージョンチェックを無効化 (Nix管理をより完全にするため)
      disable-extension-version-validation = true;
    };

    # Forge の一般設定
    "org/gnome/shell/extensions/forge" = {
      tiling-mode-enabled = true;
      window-gap-size = lib.hm.gvariant.mkUint32 2;
      window-gap-hidden-on-single = true;
      focus-border-toggle = true;
      focus-border-color = "#ffc20d"; # GlazeWM ゴールド
    };

    # Forge のキーバインド (Kanata によって Alt+HJKL -> Super+HJKL に変換されて届く)
    "org/gnome/shell/extensions/forge/keybinds" = {
      window-focus-left = ["<Super>h"];
      window-focus-down = ["<Super>j"];
      window-focus-up = ["<Super>k"];
      window-focus-right = ["<Super>l"];

      # 今後 Kanata 側を拡張すれば移動も Alt+Shift+HJKL で可能になります
      window-move-left = ["<Super><Shift>h"];
      window-move-down = ["<Super><Shift>j"];
      window-move-up = ["<Super><Shift>k"];
      window-move-right = ["<Super><Shift>l"];

      window-toggle-float = ["<Alt><Shift>space"];
      window-toggle-fullscreen = ["<Alt>f"];
    };

    # --- アプリに吸われないための工夫 (GNOME 本体の設定) ---

    "org/gnome/desktop/wm/preferences" = {
      # Alt+ドラッグ で窓が動く機能を Super に変更 (Altを自由に使うため)
      mouse-button-modifier = "<Super>";
    };

    "org/gnome/desktop/wm/keybindings" = {
      # Alt + 1〜9 (Kanata 経由で Super+1〜9 に変換されて届く) でワークスペース切り替え
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      switch-to-workspace-7 = ["<Super>7"];
      switch-to-workspace-8 = ["<Super>8"];
      switch-to-workspace-9 = ["<Super>9"];

      # Alt + Shift + 1〜9 (Kanata 経由で Super+Shift+1〜9 に変換されて届く) でウィンドウを移動
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      move-to-workspace-5 = ["<Super><Shift>5"];
      move-to-workspace-6 = ["<Super><Shift>6"];
      move-to-workspace-7 = ["<Super><Shift>7"];
      move-to-workspace-8 = ["<Super><Shift>8"];
      move-to-workspace-9 = ["<Super><Shift>9"];

      # ウィンドウを閉じる (Kanata 経由で Alt+Q が Super+Shift+Q に変換されて届く)
      close = ["<Super><Shift>q"];
      
      # 競合しがちな標準機能を無効化
      minimize = [];
      begin-move = [];
      begin-resize = [];
    };

    # アプリ(ブラウザ等)が Alt 単押しでメニューにフォーカスするのを防ぐ (環境による)
    "org/gnome/desktop/interface" = {
      menubar-accel = ""; # デフォルトは F10
    };

    # 画面ロックの衝突回避 (Super + L を解放する)
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = ["<Alt><Super>l"]; 
    };

    # Ubuntu Dock が Super+数字 を奪うのを防ぐ
    "org/gnome/shell/extensions/dash-to-dock" = {
      app-shift-hotkey-1 = [];
      app-shift-hotkey-2 = [];
      app-shift-hotkey-3 = [];
      app-shift-hotkey-4 = [];
      app-shift-hotkey-5 = [];
      app-shift-hotkey-6 = [];
      app-shift-hotkey-7 = [];
      app-shift-hotkey-8 = [];
      app-shift-hotkey-9 = [];
      app-ctrl-hotkey-1 = [];
      app-ctrl-hotkey-2 = [];
      app-ctrl-hotkey-3 = [];
      app-ctrl-hotkey-4 = [];
      app-ctrl-hotkey-5 = [];
      app-ctrl-hotkey-6 = [];
      app-ctrl-hotkey-7 = [];
      app-ctrl-hotkey-8 = [];
      app-ctrl-hotkey-9 = [];
      hot-keys = false; # 数字キーによるアプリ起動全体を無効化
    };
  };
}

