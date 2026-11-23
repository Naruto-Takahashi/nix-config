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
  };

  # ディスプレイマネージャー & デスクトップ環境設定
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.input-sources]
      sources=[('xkb', 'us')]
    '';
  };

  # ユーザー `nalt` の定義
  users.users.nalt = {
    isNormalUser = true;
    description = "nalt";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
    ];
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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # 古いシステム世代を週1で削除して GC し、ストア内の同一ファイルをハードリンクで重複排除する
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # Hyprland システムモジュールの有効化
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Steam の有効化
  programs.steam = {
    enable = true;
  };

  # Cloudflare WARP (学内規制バイパス用トンネル)
  services.cloudflare-warp = {
    enable = true;
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
  # 設定は modules/input/kanata/linux-config.nix (config.kbd テンプレートの NixOS 向け置換) から生成する。
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        configFile = pkgs.writeText "kanata-config.kbd" (
          import ../../modules/input/kanata/linux-config.nix
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
  # Cloudflare WARP と DNS (/etc/resolv.conf) が競合しないよう Tailscale 側の DNS 管理は無効化
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-dns=false" ];
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Cloudflare WARP (優先度 5209 + inet cloudflare-warp policy drop) が
  # tailscaled の外向き通信 (fwmark 0x80000 / 41641/udp) を遮断するため、
  # pref 5205 と最小限の nftables 許可ルールを冪等に差し込んで直通を維持する。
  # WARP の接続完了待ちや再接続時のテーブル再生成にも追従できるよう 30 秒周期で検査する。
  systemd.services.tailscale-warp-bypass = {
    description = "Allow tailscaled traffic (fwmark 0x80000) to bypass Cloudflare WARP";
    after = [ "network-online.target" "cloudflare-warp.service" "tailscaled.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "tailscale-warp-bypass" ''
        set -euo pipefail
        ip="${pkgs.iproute2}/bin/ip"
        nft="${pkgs.nftables}/bin/nft"
        grep="${pkgs.gnugrep}/bin/grep"

        for fam in -4 -6; do
          if ! "$ip" "$fam" rule list | "$grep" -qE '^5205:'; then
            "$ip" "$fam" rule add pref 5205 from all fwmark 0x80000/0xff0000 lookup main
          fi
        done

        if "$nft" list table inet cloudflare-warp >/dev/null 2>&1; then
          if ! "$nft" list chain inet cloudflare-warp output | "$grep" -qE '0x(00)?080000'; then
            "$nft" insert rule inet cloudflare-warp output meta mark '&' 0x00ff0000 == 0x00080000 accept
          fi
          if ! "$nft" list chain inet cloudflare-warp input | "$grep" -qE '0x(00)?080000'; then
            "$nft" insert rule inet cloudflare-warp input ct mark '&' 0x00ff0000 == 0x00080000 accept
          fi
          if ! "$nft" list chain inet cloudflare-warp input | "$grep" -q 'dport 41641'; then
            "$nft" insert rule inet cloudflare-warp input udp dport 41641 accept
          fi
        fi
      '';
    };
  };

  systemd.timers.tailscale-warp-bypass = {
    description = "Periodically ensure Tailscale bypasses Cloudflare WARP";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "30s";
    };
  };

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
