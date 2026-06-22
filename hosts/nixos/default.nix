# =========================================================================
# NixOS システム設定ファイル (/etc/nixos/configuration.nix 相当)
# =========================================================================
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ブートローダー設定 (EFIシステム用)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ネットワーク設定
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # タイムゾーンと地域言語設定
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";
  console.keyMap = "jp106";

  # X11 / デスクトップ環境 (GNOME を使用するための基本設定)
  services.xserver = {
    enable = true;
    xkb = {
      layout = "jp";
      options = "ctrl:nocaps"; # CapsLockをCtrlに変更 (お好みで)
    };
    
    # ディスプレイマネージャー & デスクトップ環境設定
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # ユーザー `nalt` の定義
  users.users.nalt = {
    isNormalUser = true;
    description = "nalt";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Zsh をシステム全体で有効化 (ユーザーのログインシェル設定に必要)
  programs.zsh.enable = true;

  # Nix コマンドと Flakes の有効化
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # パッケージインストール許可
  nixpkgs.config.allowUnfree = true;

  # システムパッケージ
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    vivaldi # Vivaldiブラウザの追加
  ];

  # システムバージョン
  system.stateVersion = "25.11";
}
