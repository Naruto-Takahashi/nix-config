# =========================================================================
# Orca (マルチエージェント ADE) 専用スキル配置モジュール
# =========================================================================
# Orca のワーカーオーケストレーション (orchestration, orca-cli, computer-use)
# に必要なスキルを宣言的に取得・配置する。
# 汎用のエンジニアリング・ワークフロースキルは modules/ai/agent-skills を参照。
{
  config,
  lib,
  skillSources,
  ...
}:

let
  cfg = config.programs.orca;

  orcaSrc = skillSources.orca;

  skillFiles = name: {
    ".claude/skills/${name}/SKILL.md".source = "${orcaSrc}/skills/${name}/SKILL.md";
    ".gemini/config/skills/${name}/SKILL.md".source = "${orcaSrc}/skills/${name}/SKILL.md";
  };
in
{
  options.programs.orca = {
    enable = lib.mkEnableOption "Orca 用エージェントスキルの配置";

    skills = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "orchestration"
        "orca-cli"
        "computer-use"
      ];
      description = "stablyai/orca リポジトリの skills/ 配下から配置するスキル名。";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge (map skillFiles cfg.skills);
  };
}
