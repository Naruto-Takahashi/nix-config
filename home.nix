# =========================================================================
# Home Manager メイン設定ファイル (~/.config/home-manager/home.nix)
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # 外部モジュールの読み込み
  imports = [
    ./modules/packages.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/kanata.nix
    ./modules/desktop.nix
    ./modules/wezterm.nix
    ./modules/neovim.nix
  ];

  # ユーザー情報・基本設定
  home.username = "nalt";
  home.homeDirectory = "/home/nalt";
  home.stateVersion = "25.11";

  # Home Manager 自身の管理を有効化
  programs.home-manager.enable = true;

  # Bash の基本設定と Zsh への自動切り替え設定
  programs.bash = {
    enable = true;
    initExtra = ''
      # インタラクティブシェル（通常の端末起動）の場合のみ、Zshへバトンタッチ
      if [ -t 1 ]; then
        exec /home/nalt/.nix-profile/bin/zsh
      fi
    '';
  };
}
