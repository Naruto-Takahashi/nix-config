# =========================================================================
# AI エージェント統合プロファイル (ai-agent.nix)
# =========================================================================
# Claude Code, Antigravity CLI, Orca スキル群,
# および Obsidian 外部脳 (MCP / CLI) 連携を一元管理する。
{ config, pkgs, ... }:

{
  imports = [
    ../modules/ai/claude-code
    ../modules/ai/antigravity
    ../modules/ai/agent-skills
    ../modules/services/obsidian-brain.nix
  ];

  programs.claudeCode.enable = true;
  programs.antigravityCli.enable = true;
  programs.agentSkills.enable = true;
  # Orca 特有のスキル (orchestration, orca-cli 等) はアプリ本体と密結合しているため、
  # Orca 自身 (orca skills install) に管理を委ねる。
  services.obsidianBrain.enable = true;
}
