# =========================================================================
# bat (シンタックスハイライト付きページャ) 宣言的設定モジュール
# =========================================================================
# bat自体だけでなく、deltaの`syntax-theme`(~/.gitconfig)もbatと同じ
# syntect(sublime-syntax)エンジンのテーマ名を参照する。デフォルトの
# "Monokai Extended" はオレンジが目立ちkanagawa-dragonと馴染まないため、
# kanagawa.nvim公式のtmTheme (extras/tmTheme/kanagawa.tmTheme) をここに
# 取り込み、bat/deltaの両方から "Kanagawa" として使えるようにする。
# kanagawa-dragon専用ではなく無印kanagawa (wave) 配色だが、後発の
# tmThemeはdragon版が提供されていないため一番近い選択肢として採用
{ ... }:

{
  programs.bat = {
    enable = true;
    themes = {
      Kanagawa = {
        src = ./.;
        file = "kanagawa.tmTheme";
      };
    };
    config = {
      theme = "Kanagawa";
    };
  };
}
