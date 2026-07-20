# =========================================================================
# gitmoji 強制フック モジュール
# =========================================================================
# git commit時にgitmojiを自動付与/強制するグローバルフック。
# core.hooksPath でどのリポジトリでも共通適用されるため、
# git CLI直接実行・lazygit(nvim内/外)・Claude CodeなどのAIエージェント
# 経由のコミットも含め、`git commit` を呼ぶもの全てに適用される。
#
# ~/.gitconfig 自体はNix管理外(手動ファイル)のため上書きしない。
# 代わりに include 用のconfigスニペットを生成し、
# ~/.gitconfig 側に [include] path = ~/.config/git/gitmoji.conf を
# 追加してもらう(初回のみ手動 or セットアップスクリプトで一度だけ追記)。
{ config, pkgs, ... }:

{
  home.file.".config/git/hooks/prepare-commit-msg" = {
    source = ./hooks/prepare-commit-msg;
    executable = true;
  };
  home.file.".config/git/hooks/commit-msg" = {
    source = ./hooks/commit-msg;
    executable = true;
  };
  home.file.".config/git/gitmoji.conf".text = ''
    [core]
      hooksPath = ${config.home.homeDirectory}/.config/git/hooks
  '';
}
