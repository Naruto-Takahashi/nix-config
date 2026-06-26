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
    wayvnc

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
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        configFile = ../../modules/desktop/config.kbd;
      };
    };
  };

  # システム全体で利用可能なフォントの追加
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  # システムバージョン
  system.stateVersion = "25.11";
}
