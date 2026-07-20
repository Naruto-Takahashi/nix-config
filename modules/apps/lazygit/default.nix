# =========================================================================
# LazyGit 宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # --- LazyGitの設定 ---
  # LazyGitの有効化，およびカスタムコマンド・外観テーマを設定します．
  programs.lazygit = {
    enable = true;
    
    settings = {
      # lazygit内蔵の差分パネルはデフォルトでは自前のシンタックスハイライトを
      # 使っており、~/.gitconfigのcore.pager=deltaとは無関係。ここでもdeltaを
      # 使うよう明示する (git diff/showと同じ見た目に揃える)。
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };

      # Gemini APIを使用したコミットメッセージ自動生成コマンドの登録
      customCommands = [
        {
          key = "<c-g>";
          description = "Generate commit message via Gemini and Edit";
          context = "global";
          command = "/home/nalt/.local/bin/lazygit-gemini-commit";
          output = "terminal";
        }
        {
          # commitizen (cz) で type/scope/subject を対話選択してコミット
          # (docs/gitmoji.md, .cz.toml 参照)。stageされた変更がある前提。
          # 既定のcommitChanges(通常コミット)を使わなくなったため、
          # 一等地の c キーをcustomCommandsで上書きする
          # (lazygitはcustomCommandsを既定キーバインドより優先する)。
          # 素のコミットメッセージ入力に戻したい場合は C (commitChangesWithEditor)
          # または w (commitChangesWithoutHook, フック無視) を使う。
          key = "c";
          description = "Commit interactively via commitizen (cz)";
          context = "files";
          command = "cz commit";
          output = "terminal";
        }
      ];

      # 外観テーマ設定（kanagawa-dragon配色）
      gui = {
        theme = {
          activeBorderColor = [ "#e6c384" "bold" ]; # kanagawa carpYellow (nvim/YASBのフォールバックaccentと統一)
          inactiveBorderColor = [ "#a89984" ]; # kanagawa-dragon fg_gutter or slightly dimmed
          searchingActiveBorderColor = [ "#ff9e3b" ]; # kanagawa-dragon autumnYellow
          optionsTextColor = [ "#7e9cd8" ]; # kanagawa-dragon crystalBlue
          selectedLineBgColor = [ "#2d4f67" ]; # kanagawa-dragon waveBlue2
          cherryPickedCommitBgColor = [ "#2d4f67" ];
          cherryPickedCommitFgColor = [ "#7e9cd8" ];
          unstagedChangesColor = [ "#c4746e" ]; # kanagawa-dragon autumnRed
          defaultFgColor = [ "#c5c9c5" ]; # kanagawa-dragon fimi
        };
      };
    };
  };
}
