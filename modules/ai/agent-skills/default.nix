# =========================================================================
# AI エージェント用共通スキル (Agent Skills) 宣言的配置モジュール
# =========================================================================
# Claude Code (~/.claude/skills) および Antigravity CLI (~/.gemini/config/skills)
# に共通で配備する汎用エンジニアリング・ワークフロースキル群。
# 上流リポジトリをコミット固定で宣言的に取得・配置する。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.agentSkills;

  vercelSkillsSrc = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "skills";
    rev = "a80e4c9d12d607631249d4d7d059f835d4b2f13a";
    sha256 = "1djab5lz3yg0r8f4m57071sxj0jpprlzzhrd1zswdann96297xb1";
  };

  anthropicsSkillsSrc = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "dbd4588f9e1033efb41dad4bef2f7947c8993d44";
    sha256 = "1x81ypg4nfacr4ma9vphj890yrnwhhv6i6124npq6y7jgh32lhpr";
  };

  vercelAgentSkillsSrc = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-skills";
    rev = "063bee94c3f4df8453406c830b0a7df0f2860278";
    sha256 = "07y8vkfyg44szky962d3035kjz3jd8by5iqlgxa5nhnfkmzqjd5m";
  };

  mattpocockSkillsSrc = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "5beb35b040e3de97e54fa9e386d7e42d15c295c2";
    sha256 = "1lnzvp1xhwmab4fwn8jq1gzbh1d1gzknnjq0kc6cxhf5gxxrylnq";
  };

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
