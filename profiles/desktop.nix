# =========================================================================
# デスクトップ GUI 共通プロファイル (desktop.nix)
# =========================================================================
# Mac, WSL, NixOS 等のグラフィカル環境向け共通モジュール。
# ターミナルエミュレータ (WezTerm)、壁紙動的配色 (Matugen 共通部)、フォント等を配置する。
{ config, pkgs, ... }:

{
  imports = [
    ./core.nix
    ../modules/apps/wezterm
    ../modules/theming/matugen
  ];

  home.packages = [
    pkgs.smassh # タイピング練習 TUI
    pkgs.imagemagick # 画像処理 (matugenの色抽出補助が使用)
  ];
}
