# =========================================================================
# eza テーマモジュール
# =========================================================================
# eza (ls置き換え) のファイル種別ごとの色をkanagawa-dragon系に固定する。
# matugen環境では ~/.cache/matugen/eza/theme.yml (生成版) が
# EZA_CONFIG_DIR経由で優先される (modules/shell/zsh/functions.zsh 参照)。
{ ... }:

{
  home.file.".config/eza/theme.yml".source = ./theme.yml;
}
