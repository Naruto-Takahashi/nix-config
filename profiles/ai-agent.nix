# =========================================================================
# AI エージェント統合プロファイル (ai-agent.nix)
# =========================================================================
# Claude Code, Antigravity CLI / Gemini CLI, Orca スキル群,
# および Obsidian 外部脳 (MCP / CLI) 連携を一元管理する。
{ config, pkgs, ... }:

{
  imports = [
    ../modules/apps/claude-code
    ../modules/apps/gemini
    ../modules/apps/orca
    ../modules/services/obsidian-mcp.nix
  ];

  programs.claudeCode.enable = true;
  programs.geminiCli.enable = true;
  services.obsidianBrain.enable = true;
  programs.orca.enable = true;
}
