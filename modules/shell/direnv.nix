# =========================================================================
# direnv 設定モジュール (nix-direnv対応)
# =========================================================================
{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
