# =========================================================================
# Orca デスクトップアプリ (orca-ide) モジュール
# =========================================================================
# スキル配置は Orca 公式 (`orca skills install`) の責務とし、ここでは
# Linux 向けデスクトップアプリ本体 (AppImage ラッパー) の導入のみを扱う。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.orca;
in
{
  options.programs.orca = {
    enable = lib.mkEnableOption "Orca デスクトップアプリ (orca-ide)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      description = "Orca デスクトップアプリのパッケージ。";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
