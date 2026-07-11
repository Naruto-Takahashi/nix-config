# =========================================================================
# 全ホスト共通プロファイル (シェル環境 + コア CLI アプリ)
# =========================================================================
# wsl / mac / desktop / nixos の全ホストが import する共通セット。
# ホスト固有のモジュール (WM や OS 依存アプリ) は各 hosts/*/ 側で追加する。
{ ... }:

{
  imports = [
    ../modules/shell/zsh
    ../modules/shell/starship.nix
    ../modules/shell/direnv.nix
    ../modules/shell/fastfetch.nix
    ../modules/apps/wezterm
    ../modules/apps/neovim
    ../modules/apps/yazi
    ../modules/apps/lazygit.nix
  ];
}
