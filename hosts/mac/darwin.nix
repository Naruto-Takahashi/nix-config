# =========================================================================
# nix-darwin Macシステム環境設定ファイル (hosts/mac/darwin.nix)
# =========================================================================
{ pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # システム共通パッケージの定義
  # -----------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  # -----------------------------------------------------------------------
  # システムフォントの定義 (/Library/Fonts/Nix Fonts へ配置)
  # -----------------------------------------------------------------------
  fonts.packages = [
    pkgs.hackgen-nf-font
  ];

  # -----------------------------------------------------------------------
  # Homebrew連携 (Caskアプリの宣言的インストール用)
  # -----------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation = {
      # switch ではバージョン更新をしない (宣言と実態の一致だけを担当させる)。
      # WM 周りの更新は任意のタイミングで `brew update && brew upgrade` を実行する。
      autoUpdate = false;
      upgrade = false;
      # 既存の手動インストールアプリを誤って削除しないよう保護。新しい Mac では宣言と
      # 実態が一致した状態から始められるため、移行後に "uninstall" へ切り替える
      # (宣言から外した cask が switch で自動削除されるようになる。docs/setup-mac.md 参照)。
      # 注意: 切り替え前に、brew で入れたのに未宣言の cask (moonlight, spokenly 等) を
      # casks に足すか手放すか決めること。未宣言のまま切り替えると switch で削除される。
      cleanup = "none";
    };
    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
      "rdrkr/tap"
      "dimentium/autoraise"
    ];
    # WM 周り (インフラ) だけを cask で管理する。aerospace は CLI が /opt/homebrew/bin に入り、
    # アクセシビリティ権限も /Applications 固定のパスで安定する。
    casks = [
      "karabiner-elements" # キーボードリマップ (設定は modules/input/karabiner から配置)
      "aerospace" # タイリングウィンドウマネージャ
      "aerospacebar" # AeroSpaceのワークスペースをメニューバーに表示 (rdrkr/tap。設定は手動，docs/aerospace.md参照)
      "dimentium/autoraise/autoraiseapp" # マウスホバーフォーカス追従 (AutoRaise.app)
      "hammerspoon" # トラックパッドジェスチャーによるワークスペース移動・ウィンドウ操作
      "stats" # メニューバーに CPU・メモリ・ネットワーク等を表示するシステムモニタ
      "thaw" # メニューバー整理ツール (Ice のフォーク。macOS 26 以降は Ice が動かないため)
    ];
    # 手動で入れるアプリ (自己更新するため宣言しない): Vivaldi / Raycast / Zotero / Obsidian /
    # Google Drive / Orca (同名の cask "orca" は plotly 用の別アプリなので使わないこと)。
    # 手順は docs/setup-mac.md の移行チェックリスト。
    brews = [
      "borders" # アクティブウィンドウの枠線ハイライト用ツール
      "libomp" # LightGBM (PyPI wheel) が必要とする OpenMP ランタイム
    ];
  };

  # Determinate Nix 衝突防止のため、nix-darwin側のNix管理を無効化
  nix.enable = false;

  # macOS のシステム設定 (defaults)。キーボード・トラックパッド・ショートカット・
  # ウィンドウ管理まわりは入力/WM の設定と合わせて別途宣言する。
  system.defaults = {
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    dock.autohide = true;
  };

  # nix.enable = false のため nix-darwin の nix.gc は使えない。root の launchd デーモンで
  # 古いシステム世代を週1 (日曜 4:00) で削除して GC する (ユーザー側の世代は profiles/core.nix の nix.gc)
  launchd.daemons.nix-gc = {
    serviceConfig = {
      ProgramArguments = [
        "/nix/var/nix/profiles/default/bin/nix-collect-garbage"
        "--delete-older-than"
        "30d"
      ];
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 4;
          Minute = 0;
        }
      ];
      StandardOutPath = "/Library/Logs/nix-gc.out.log";
      StandardErrorPath = "/Library/Logs/nix-gc.err.log";
    };
  };

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

  # sudo の認証に Touch ID を有効化 (macOS 標準の pam_tid.so を sudo_local 経由で使用)
  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs.config.allowUnfree = true;
}
