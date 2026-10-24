# =========================================================================
# AI エージェント統合プロファイル (ai-agent.nix)
# =========================================================================
# Claude Code, Antigravity CLI / Gemini CLI, Orca スキル群,
# および Obsidian 外部脳 (MCP / CLI) 連携を一元管理する。
{ config, pkgs, ... }:

{
  imports = [
    ../modules/ai/claude-code
    ../modules/ai/gemini
    ../modules/ai/agent-skills
    ../modules/ai/orca
    ../modules/services/obsidian-brain.nix
  ];

  programs.claudeCode.enable = true;
  programs.geminiCli.enable = true;
  programs.agentSkills.enable = true;
  programs.orca.enable = true;
  services.obsidianBrain.enable = true;
}
