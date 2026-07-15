# =========================================================================
# direnv 宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # --- direnv設定 ---
  # direnvの有効化，およびnix-direnvとの統合，Zsh連携を設定します．
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
