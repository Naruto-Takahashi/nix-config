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
          # E = Emoji の連想。<c-e>はdiffingMenu-alt、xはconfirmDiscardと衝突するため
          # 単独の大文字Eを使う(files/universalどちらでも未使用)。
          key = "E";
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
