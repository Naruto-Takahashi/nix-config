# =========================================================================
# AIエージェント宣言的設定モジュール (~/.claude/CLAUDE.md, ~/.gemini/GEMINI.md)
# =========================================================================
# CLAUDE.md と GEMINI.md はこのモジュールが唯一のオーナーとして単一ソースから生成する。
# 他モジュール (obsidian-mcp 等) が独自ルールを注入したい場合は home.file を直接触らず、
# programs.claudeCode.extraInstructions に文字列を追加すること。
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claudeCode;
  combinedInstructions = lib.concatStringsSep "\n\n" (
    [ (builtins.readFile ./CLAUDE.md) ] ++ cfg.extraInstructions
  );
in
{
  options.programs.claudeCode = {
    enable = lib.mkEnableOption "AIエージェント (Claude Code / Gemini / Antigravity) の宣言的設定";

    extraInstructions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        CLAUDE.md および GEMINI.md に追記する追加ルール (Markdown 文字列)。
        機能ごとに独立したモジュール (例: obsidian-mcp) がここに
        追記することで、ルール生成のオーナーシップを本モジュールに
        一本化しつつ、Claude Code と Antigravity/Gemini 間の乖離を防ぐ。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];

    home.file.".claude/CLAUDE.md".text = combinedInstructions;
    home.file.".gemini/GEMINI.md".text = combinedInstructions;

    home.file.".claude/settings.json".text = builtins.toJSON {
      effortLevel = "low";
      theme = "dark";
    };
  };
}
