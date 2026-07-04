# =========================================================================
# NixOS システム設定ファイル (/etc/nixos/configuration.nix 相当)
# =========================================================================
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # GPU / Graphics hardware settings
  hardware.graphics = {
    enable = true;
  };

  # Load NVIDIA proprietary drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false; # Proprietary Nvidia driver
    nvidiaSettings = true;
  };

  # ブートローダー設定 (EFIシステム用)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "pcie_aspm=off" ];

  # ネットワーク設定
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # タイムゾーンと地域言語設定
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";
  console.keyMap = "us";

  # 日本語入力 (Fcitx5 + Mozc) の設定
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
    ];
  };

  # X11 / デスクトップ環境 (GNOME を使用するための基本設定)
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      options = "ctrl:nocaps"; # CapsLockをCtrlに変更 (お好みで)
    };
    
    # ディスプレイマネージャー & デスクトップ環境設定
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.desktop.input-sources]
        sources=[('xkb', 'us')]
      '';
    };
  };

  # ユーザー `nalt` の定義
  users.users.nalt = {
    isNormalUser = true;
    description = "nalt";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "uinput" ];
    shell = pkgs.zsh;
  };

  # Zsh をシステム全体で有効化 (ユーザーのログインシェル設定に必要)
  programs.zsh.enable = true;

  # nix-ld を有効にして，一般的なLinux向けバイナリをそのまま実行可能にする
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
  ];

  # Nix コマンドと Flakes の有効化
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hyprland システムモジュールの有効化
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # パッケージインストール許可
  nixpkgs.config.allowUnfree = true;

  # システムパッケージ
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    vivaldi # Vivaldiブラウザの追加

    # Hyprland 関連ツール
    awww
    matugen
    pamixer
    libnotify
    playerctl
    hyprpicker
    rofi
    swaynotificationcenter
    waybar
    wlogout
    hypridle
    hyprlock
    networkmanagerapplet
    blueman
    grim
    slurp
  ];

  # Kanata キーボードリマッパーのシステムサービス有効化
  # config.kbd はプレースホルダー (cap-ctrl-action / wmmodifier-) を含むテンプレートなので、
  # home-manager 側 (modules/desktop/kanata.nix) と同じ置換をしてから渡す必要がある。
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        configFile = pkgs.writeText "kanata-config.kbd" (
          builtins.replaceStrings
            [ "cap-ctrl-action" "wmmodifier-" "eisu" "kana" ]
            [ "lctl" "M-" "muhenkan" "henkan" ]
            (builtins.readFile ../../modules/desktop/config.kbd)
        );
      };
    };
  };

  # 再起動後の無人リモート復帰: 自動ログインでグラフィカルセッション (= Sunshine) を自動起動
  services.displayManager.autoLogin = {
    enable = true;
    user = "nalt";
  };
  # GDM 自動ログインの既知バグ回避 (https://github.com/NixOS/nixpkgs/issues/103746)
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # 無人運用中にサスペンドしてリモート接続が切れないようにする
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # リモートアクセス (Windowsノート → 研究室PC)
  # Tailscale で大学NATを越え、Sunshine (KMSキャプチャ) で Wayland 無人接続、SSH は復旧用
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.sunshine = {
    enable = true;
    package = pkgs.sunshine.override { cudaSupport = true; }; # NVENC ハードウェアエンコード有効化
    autoStart = true;
    capSysAdmin = true; # KMS キャプチャに必要 (ログイン画面も取得可能)
    openFirewall = false; # 大学LANには公開せず Tailscale (trustedInterfaces) 経由のみ許可
  };

  services.openssh = {
    enable = true;
    openFirewall = false; # 大学LANには公開せず Tailscale (trustedInterfaces) 経由のみ許可
    settings.PasswordAuthentication = false; # 鍵認証のみ (authorized_keys 登録済み)
    settings.KbdInteractiveAuthentication = false;
  };

  # システム全体で利用可能なフォントの追加
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  # システムバージョン
  system.stateVersion = "25.11";
}
