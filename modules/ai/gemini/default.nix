# =========================================================================
# Gemini CLI / Antigravity CLI 宣言的設定モジュール (~/.gemini/GEMINI.md)
# =========================================================================
# GEMINI.md はこのモジュールが唯一のオーナーとして生成する。他モジュール
# (obsidian-brain 等) が独自ルールを注入したい場合は home.file を直接触らず、
# programs.geminiCli.extraInstructions に文字列を追加すること。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.geminiCli;
in
{
  options.programs.geminiCli = {
    enable = lib.mkEnableOption "Gemini CLI / Antigravity CLI の宣言的設定";

    extraInstructions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        GEMINI.md に追記する追加ルール (Markdown 文字列)。
        機能ごとに独立したモジュール (例: obsidian-brain) がここに
        追記することで、GEMINI.md 生成のオーナーシップを本モジュールに
        一本化しつつ、各機能のルール定義は元のモジュール側に置ける。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.gemini-cli
      pkgs.antigravity-cli # バイナリ名は agy
    ];

    home.file.".gemini/GEMINI.md".text = lib.concatStringsSep "\n\n" (
      [ (builtins.readFile ./GEMINI.md) ] ++ cfg.extraInstructions
    );
  };
}
