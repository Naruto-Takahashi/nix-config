# =========================================================================
# gitmoji 強制フック モジュール
# =========================================================================
# git commit時にgitmojiを自動付与するフック (core.hooksPath)。
# git CLI直接実行・lazygit(nvim内/外)・Claude CodeなどのAIエージェント
# 経由のコミットも含め、`git commit` を呼ぶもの全てに適用される。
#
# ~/.gitconfig 自体はNix管理外(手動ファイル)のため上書きしない。
# 代わりに include 用のconfigスニペットを生成し、
# ~/.gitconfig 側に以下を追加してもらう(初回のみ手動追記):
#   [includeIf "gitdir:~/ghq/github.com/Naruto-Takahashi/**"]
#     path = ~/.config/git/gitmoji.conf
# 個人リポジトリ配下のみに条件付き適用することで、共同開発リポジトリ
# (他人のOSSや会社リポジトリなど)に無断でgitmojiが混ざるのを防ぐ。
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
