# =========================================================================
# Claude Code 宣言的設定モジュール (~/.claude/CLAUDE.md)
# =========================================================================
# CLAUDE.md はこのモジュールが唯一のオーナーとして生成する。他モジュール
# (obsidian-mcp 等) が独自ルールを注入したい場合は home.file を直接触らず、
# programs.claudeCode.extraInstructions に文字列を追加すること。
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claudeCode;
in
{
  options.programs.claudeCode = {
    enable = lib.mkEnableOption "Claude Code の宣言的設定";

    extraInstructions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        CLAUDE.md に追記する追加ルール (Markdown 文字列)。
        機能ごとに独立したモジュール (例: obsidian-mcp) がここに
        追記することで、CLAUDE.md 生成のオーナーシップを本モジュールに
        一本化しつつ、各機能のルール定義は元のモジュール側に置ける。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];

    home.file.".claude/CLAUDE.md".text = lib.concatStringsSep "\n\n" (
      [ (builtins.readFile ./CLAUDE.md) ] ++ cfg.extraInstructions
    );

    # settings.json は管理しない: Claude Code 本体・Orca (hooks 注入)・/config が書き込むため、
    # 読み取り専用の宣言的ファイルにすると承認記録や設定変更が書けなくなる。
  };
}
