# =========================================================================
# bat (シンタックスハイライト付きページャ) 宣言的設定モジュール
# =========================================================================
# bat自体だけでなく、deltaの`syntax-theme`(~/.gitconfig)もbatと同じ
# syntect(sublime-syntax)エンジンのテーマ名を参照する。デフォルトの
# "Monokai Extended" はオレンジが目立ちkanagawa-dragonと馴染まないため、
# kanagawa.nvim公式のtmTheme (extras/tmTheme/kanagawa.tmTheme、無印wave配色)
# をベースに、kanagawa.nvimのlua/kanagawa/themes.lua内 dragon テーブルの
# 色定義に合わせて手動で色置換したものを kanagawa-dragon.tmTheme として
# 取り込んでいる (upstreamにdragon版のtmThemeは存在しないため)。
# bat/deltaの両方から "Kanagawa Dragon" として使える
{ ... }:

{
  programs.bat = {
    enable = true;
    themes = {
      "Kanagawa Dragon" = {
        src = ./.;
        file = "kanagawa-dragon.tmTheme";
      };
    };
    config = {
      theme = "Kanagawa Dragon";
    };
  };
}
