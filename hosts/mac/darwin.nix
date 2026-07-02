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
      "karabiner-elements" # キーマップリマッパー
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



  # macOS向け Kanata バックグラウンド起動サービスの設定 (System Daemon として実行し、root権限を付与)
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "until [ -f /run/current-system/sw/bin/kanata ]; do sleep 1; done && sleep 5 && exec /run/current-system/sw/bin/kanata --cfg /Users/nalt/.config/kanata/config.kbd"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Library/Logs/kanata.out.log";
      StandardErrorPath = "/Library/Logs/kanata.err.log";
    };
  };
}
