# =========================================================================
# LazyGit 設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      customCommands = [
        {
          key = "<c-g>";
          description = "Generate commit message via Gemini and Edit";
          context = "global";
          command = "/home/nalt/.local/bin/lazygit-gemini-commit";
          output = "terminal";
        }
      ];
      gui = {
        theme = {
          activeBorderColor = [ "#ffc20d" "bold" ];
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
