# =========================================================================
# GNOME タイリング拡張機能 (Forge) モジュール
# =========================================================================
{ config, pkgs, lib, ... }:

{
  # 必要なパッケージのインストール (GNOME Shell 拡張機能)
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
      ];
      # 拡張機能のバージョンチェックを無効化 (Nix管理を円滑にするため)
      disable-extension-version-validation = true;
      
      # 競合する Ubuntu 標準のタイリングアシスタントを無効化する
      disabled-extensions = [
        "tiling-assistant@ubuntu.com"
      ];
    };

    # Forge の一般設定 (隙間サイズやフォーカス色)
    "org/gnome/shell/extensions/forge" = {
      tiling-mode-enabled         = true;
      window-gap-size             = lib.hm.gvariant.mkUint32 2;
      window-gap-hidden-on-single = true;
      focus-border-toggle         = true;
      focus-border-color          = "#ffc20d"; # i3wm/GlazeWMと統一されたゴールドテーマ
    };

    # Forge のキーバインド設定
    # ※ Kanata によって Alt単押しはIME、Alt長押しはSuperに変換されて届くため、
    #    Altを使用する箇所はすべて <Super> 基準に美しく統一・ブリッジしています。
    "org/gnome/shell/extensions/forge/keybindings" = {
      # フォーカス移動 (Alt + HJKL -> Super + HJKL)
      window-focus-left           = ["<Super>h"];
      window-focus-down           = ["<Super>j"];
      window-focus-up             = ["<Super>k"];
      window-focus-right          = ["<Super>l"];

      # ウィンドウ移動 (Alt+Shift+HJKL -> Super+Shift+HJKL)
      window-move-left            = ["<Super><Shift>h"];
      window-move-down            = ["<Super><Shift>j"];
      window-move-up              = ["<Super><Shift>k"];
      window-move-right           = ["<Super><Shift>l"];

      # フローティング / フルスクリーンの切り替え (Kanata の Altマッピングと完璧に同期)
      window-toggle-float         = ["<Super><Shift>space"];
      window-toggle-fullscreen    = ["<Super>f"];

      # リサイズ調整 (Alt + U/I/O/P -> Super + U/I/O/P)
      window-resize-right-decrease  = ["<Super>u"];
      window-resize-right-increase  = ["<Super>p"];
      window-resize-bottom-decrease = ["<Super>i"];
      window-resize-bottom-increase = ["<Super>o"];
      
      # 不要なデフォルトショートカットの解除
      window-resize-left-decrease   = [];
      window-resize-left-increase   = [];
      window-resize-top-decrease    = [];
      window-resize-top-increase    = [];
    };

    # ---------------------------------------------------------------------
    # アプリや入力に吸われないための工夫 (GNOME 本体の競合解除)
    # ---------------------------------------------------------------------
    "org/gnome/desktop/wm/preferences" = {
      # Alt+ドラッグでの窓移動機能を Super+ドラッグ に変更 (Altキーを完全に解放するため)
      mouse-button-modifier       = "<Super>";
      # GNOME 本体の簡易タイリング機能を完全にオフ (Forgeと衝突するのを防止)
      edge-tiling                 = false;
    };

    "org/gnome/mutter" = {
      # ウィンドウスナップ機能を無効化
      edge-tiling                 = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      # 衝突を避けるために GNOME 標準のショートカットを徹底的に無効化
      minimize                    = [];
      switch-monitor              = []; # Super + P (ディスプレイ切替) の競合を解除
      begin-move                  = [];
      begin-resize                = [];

      # Alt + 1〜9 (Kanata経由で Super+1〜9 に変換) でワークスペース切り替え
      switch-to-workspace-1       = ["<Super>1"];
      switch-to-workspace-2       = ["<Super>2"];
      switch-to-workspace-3       = ["<Super>3"];
      switch-to-workspace-4       = ["<Super>4"];
      switch-to-workspace-5       = ["<Super>5"];
      switch-to-workspace-6       = ["<Super>6"];
      switch-to-workspace-7       = ["<Super>7"];
      switch-to-workspace-8       = ["<Super>8"];
      switch-to-workspace-9       = ["<Super>9"];

      # Alt + Shift + 1〜9 (Kanata経由で Super+Shift+1〜9 に変換) でウィンドウを別WSへ移動
      move-to-workspace-1         = ["<Super><Shift>1"];
      move-to-workspace-2         = ["<Super><Shift>2"];
      move-to-workspace-3         = ["<Super><Shift>3"];
      move-to-workspace-4         = ["<Super><Shift>4"];
      move-to-workspace-5         = ["<Super><Shift>5"];
      move-to-workspace-6         = ["<Super><Shift>6"];
      move-to-workspace-7         = ["<Super><Shift>7"];
      move-to-workspace-8         = ["<Super><Shift>8"];
      move-to-workspace-9         = ["<Super><Shift>9"];

      # ウィンドウを閉じる (Alt + Q -> Super + Shift + Q に変換)
      close                       = ["<Super><Shift>q"];
    };

    # 各種アプリ(ブラウザ等)が Alt 単押しでメニューにフォーカスするのを防止
    "org/gnome/desktop/interface" = {
      menubar-accel               = ""; # デフォルトの F10 割り当てを空にして無効化
    };

    # 画面ロックの衝突回避 (Super + L を解放する)
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver                 = ["<Alt><Super>l"]; 
      video-out                   = []; # Super + P の競合を解除
    };

    # Ubuntu Dock が Super+数字キー を横取りするのを徹底的に無効化
    "org/gnome/shell/extensions/dash-to-dock" = {
      # アプリ起動ホットキーの解除
      app-hotkey-1                = [];
      app-hotkey-2                = [];
      app-hotkey-3                = [];
      app-hotkey-4                = [];
      app-hotkey-5                = [];
      app-hotkey-6                = [];
      app-hotkey-7                = [];
      app-hotkey-8                = [];
      app-hotkey-9                = [];
      
      app-shift-hotkey-1          = [];
      app-shift-hotkey-2          = [];
      app-shift-hotkey-3          = [];
      app-shift-hotkey-4          = [];
      app-shift-hotkey-5          = [];
      app-shift-hotkey-6          = [];
      app-shift-hotkey-7          = [];
      app-shift-hotkey-8          = [];
      app-shift-hotkey-9          = [];
      app-ctrl-hotkey-1           = [];
      app-ctrl-hotkey-2           = [];
      app-ctrl-hotkey-3           = [];
      app-ctrl-hotkey-4           = [];
      app-ctrl-hotkey-5           = [];
      app-ctrl-hotkey-6           = [];
      app-ctrl-hotkey-7           = [];
      app-ctrl-hotkey-8           = [];
      app-ctrl-hotkey-9           = [];
      hot-keys                    = false; # 数字キーによるドックアプリ起動自体を完全無効化
    };
  };
}
