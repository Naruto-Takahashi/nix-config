# =========================================================================
# Home Manager WSL環境用設定ファイル (hosts/wsl/default.nix)
# =========================================================================
{
  config,
  pkgs,
  nixgl,
  ...
}:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../profiles/base.nix
    ../../modules/input/ahk
    ../../modules/input/kanata/wsl.nix
    ../../modules/wm/komorebi
    ../../modules/wm/yasb
    ../../modules/gui/vivaldi
    ../../modules/gui/linux.nix
    ../../modules/platform/wsl.nix
  ];

  platform.wsl.windowsUser = "tnaru";

  # WSL では Windows 側の Obsidian デスクトップアプリが直接開く Vault を正本とする
  services.obsidianBrain.vaultPath = "${config.platform.wsl.windowsHome}/Obsidian/Vault";

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username = "nalt";
  home.homeDirectory = "/home/nalt";
  home.stateVersion = "25.11";

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # 非自由ライセンス（Vivaldi等プロプライエタリなソフトウェア）のインストールを許可
  nixpkgs.config.allowUnfree = true;

  # WSLではWindows側のGit for Windows (wincred) の資格情報ストアを使う
  # (modules/cli/git の共通設定に対するホスト固有の追加)
  programs.git.settings.credential.helper =
    "/mnt/c/Program Files/Git/mingw64/libexec/git-core/git-credential-wincred.exe";

  # Raspberry Pi 3B SSHFS マウント操作 (sshfs/fusermount は WSL にのみ入れている)
  programs.zsh.shellAliases = {
    raspi-mount = "mkdir -p ~/mnt/raspi && sshfs nalt@192.168.151.253:/home/nalt ~/mnt/raspi && echo 'raspi mounted at ~/mnt/raspi'";
    raspi-umount = "fusermount -u ~/mnt/raspi && echo 'raspi unmounted'";
    raspi = "cd ~/mnt/raspi";
  };

  # -----------------------------------------------------------------------
  # インストールするパッケージの定義 (WSL固有パッケージ)
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    (import ./sync-win.nix {
      inherit pkgs;
      inherit (config.platform.wsl) windowsHome;
    })
    codex
    cowsay
    fortune
    lolcat
    nodejs_22
    wsl-open # Windowsの規定のアプリでファイルを開くためのコマンド
    sshfs # SSH経由でリモートホストのファイルシステムをマウントするためのツール (raspi-* エイリアスが使用)
    cava
    matugen # 壁紙から配色を抽出しYASB等へ流し込むツール
  ];
}
