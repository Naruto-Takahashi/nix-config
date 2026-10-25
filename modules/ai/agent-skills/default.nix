# =========================================================================
# AI エージェント用共通スキル (Agent Skills) 宣言的配置モジュール
# =========================================================================
# Claude Code (~/.claude/skills) および Antigravity CLI (~/.gemini/config/skills)
# に共通で配備する汎用エンジニアリング・ワークフロースキル群。
# 上流リポジトリは flake inputs (flake.lock) で固定し、週次の lock 更新で追従する。
{
  config,
  lib,
  skillSources,
  ...
}:

let
  cfg = config.programs.agentSkills;

  vercelSkillsSrc = skillSources.vercel-skills;

  anthropicsSkillsSrc = skillSources.anthropic-skills;

  vercelAgentSkillsSrc = skillSources.vercel-agent-skills;

  mattpocockSkillsSrc = skillSources.mattpocock-skills;

  findSkillsFiles = lib.mkIf cfg.enableFindSkills {
    ".claude/skills/find-skills/SKILL.md".source = "${vercelSkillsSrc}/skills/find-skills/SKILL.md";
    ".gemini/config/skills/find-skills/SKILL.md".source =
      "${vercelSkillsSrc}/skills/find-skills/SKILL.md";
  };

  frontendSkillsFiles = lib.mkIf cfg.enableFrontendSkills {
    ".claude/skills/frontend-design/SKILL.md".source =
      "${anthropicsSkillsSrc}/skills/frontend-design/SKILL.md";
    ".gemini/config/skills/frontend-design/SKILL.md".source =
      "${anthropicsSkillsSrc}/skills/frontend-design/SKILL.md";
    ".claude/skills/web-design-guidelines/SKILL.md".source =
      "${vercelAgentSkillsSrc}/skills/web-design-guidelines/SKILL.md";
    ".gemini/config/skills/web-design-guidelines/SKILL.md".source =
      "${vercelAgentSkillsSrc}/skills/web-design-guidelines/SKILL.md";
  };

  architectureSkillsFiles = lib.mkIf cfg.enableArchitectureSkills {
    ".claude/skills/improve-codebase-architecture".source =
      "${mattpocockSkillsSrc}/skills/engineering/improve-codebase-architecture";
    ".gemini/config/skills/improve-codebase-architecture".source =
      "${mattpocockSkillsSrc}/skills/engineering/improve-codebase-architecture";
    ".claude/skills/codebase-design".source =
      "${mattpocockSkillsSrc}/skills/engineering/codebase-design";
    ".gemini/config/skills/codebase-design".source =
      "${mattpocockSkillsSrc}/skills/engineering/codebase-design";
  };

  workflowSkillsFiles = lib.mkIf cfg.enableWorkflowSkills {
    ".claude/skills/grill-me".source = "${mattpocockSkillsSrc}/skills/productivity/grill-me";
    ".gemini/config/skills/grill-me".source = "${mattpocockSkillsSrc}/skills/productivity/grill-me";
    ".claude/skills/diagnosing-bugs".source =
      "${mattpocockSkillsSrc}/skills/engineering/diagnosing-bugs";
    ".gemini/config/skills/diagnosing-bugs".source =
      "${mattpocockSkillsSrc}/skills/engineering/diagnosing-bugs";
    ".claude/skills/skill-creator".source = "${anthropicsSkillsSrc}/skills/skill-creator";
    ".gemini/config/skills/skill-creator".source = "${anthropicsSkillsSrc}/skills/skill-creator";
    ".claude/skills/xlsx".source = "${anthropicsSkillsSrc}/skills/xlsx";
    ".gemini/config/skills/xlsx".source = "${anthropicsSkillsSrc}/skills/xlsx";
    ".claude/skills/pdf".source = "${anthropicsSkillsSrc}/skills/pdf";
    ".gemini/config/skills/pdf".source = "${anthropicsSkillsSrc}/skills/pdf";
  };
in
{
  options.programs.agentSkills = {
    enable = lib.mkEnableOption "AI エージェント共通スキルの配置";

    enableFindSkills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "vercel-labs/skills の find-skills (スキル探索・導入メタスキル) を配置するかどうか。";
    };

    enableFrontendSkills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "フロントエンド・UI/UX品質向上スキル (frontend-design / web-design-guidelines) を配置するかどうか。";
    };

    enableArchitectureSkills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "コードベース設計・アーキテクチャ改善スキル (improve-codebase-architecture / codebase-design) を配置するかどうか。";
    };

    enableWorkflowSkills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "開発ワークフロー・データ解析スキル (grill-me, diagnosing-bugs, skill-creator, xlsx, pdf) を配置するかどうか。";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge [
      findSkillsFiles
      frontendSkillsFiles
      architectureSkillsFiles
      workflowSkillsFiles
    ];
  };
}
