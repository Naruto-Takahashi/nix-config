# =========================================================================
# nix-darwin Macシステム環境設定ファイル (~/.config/home-manager/hosts/mac/darwin.nix)
# =========================================================================
{ pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # システム共通パッケージの定義
  # -----------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    git
    vim
    kanata
  ];

  # -----------------------------------------------------------------------
  # Homebrew連携 (Caskアプリの宣言的インストール用)
  # -----------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none"; # 既存の手動インストールアプリを誤って削除しないよう保護
    };
    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
    casks = [
      "aerospace"          # タイリングウィンドウマネージャ
      "vivaldi"            # Vivaldiブラウザ
      "raycast"            # クイックランチャー / Spotlight代替
      "alt-tab"            # WindowsスタイルのAlt+Tabスイッチャー
    ];
    brews = [
      "borders"            # アクティブウィンドウの枠線ハイライト用ツール
    ];
  };

  # Determinate Nix 衝突防止のため、nix-darwin側のNix管理を無効化
  nix.enable = false;

  # -----------------------------------------------------------------------
  # macOS システムレベルの設定
  # -----------------------------------------------------------------------
  # プライマリユーザーの指定（homebrew.enable 等に必須）
  system.primaryUser = "nalt";

  # ユーザーアカウントの定義
  users.users.nalt = {
    name = "nalt";
    home = "/Users/nalt";
  };

  # macOS システムレベルの設定
  system.stateVersion = 5;

  # シェルの設定 (Zshを有効化)
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;



  # Karabiner-DriverKit-VirtualHIDDevice デーモンの起動サービス設定．
  # Karabiner-Elements本体（グラバー/メニュー等）はmacOSのBackground Task
  # Managementで管理されており launchctl disable が定着しないため，
  # Karabiner-Elements本体は導入せず，このドライバ（Kanataの仮想キー出力に
  # 必須）だけを nix-darwin 管理の LaunchDaemon で直接起動する．
  # ドライバ本体（システム拡張）は事前に手動インストール・承認が必要．
  launchd.daemons.karabiner-vhid-daemon = {
    serviceConfig = {
      ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Library/Logs/karabiner-vhid-daemon.out.log";
      StandardErrorPath = "/Library/Logs/karabiner-vhid-daemon.err.log";
    };
  };

  # macOS向け Kanata バックグラウンド起動サービスの設定 (System Daemon として実行し、root権限を付与)
  # 仮想キーボードへの書き込み先である上記 VirtualHIDDevice デーモンの起動を待ってから起動する．
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "until pgrep -f Karabiner-VirtualHIDDevice-Daemon >/dev/null; do sleep 1; done && until [ -f /run/current-system/sw/bin/kanata ]; do sleep 1; done && sleep 5 && exec /run/current-system/sw/bin/kanata --cfg /Users/nalt/.config/kanata/config.kbd"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Library/Logs/kanata.out.log";
      StandardErrorPath = "/Library/Logs/kanata.err.log";
    };
  };
}
