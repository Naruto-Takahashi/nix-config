# =========================================================================
# eza モジュール
# =========================================================================
# eza (ls置き換え) 本体のインストールと、ファイル種別ごとの色をkanagawa-dragon系に
# 固定するテーマ配置を行う。全ホスト共通 (profiles/base.nix) で読み込まれるため、
# ここでパッケージも持たせることで全ホストで確実にeza本体が入るようにする。
# matugen環境では ~/.cache/matugen/eza/theme.yml (生成版) が
# EZA_CONFIG_DIR経由で優先される (modules/shell/zsh/functions.zsh 参照)。
{ pkgs, ... }:

{
  home.packages = [ pkgs.eza ];
  home.file.".config/eza/theme.yml".source = ./theme.yml;
}
