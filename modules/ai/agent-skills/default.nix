# =========================================================================
# AI エージェント用共通スキル (Agent Skills) 宣言的配置モジュール
# =========================================================================
# Claude Code (~/.claude/skills), Antigravity CLI (~/.gemini/skills),
# Orca (~/.agents/skills & ~/Library/Application Support/orca/antigravity-chat/config/skills)
# に共通で配備する汎用エンジニアリング・ワークフロースキル群。
# 上流リポジトリは flake inputs (flake.lock) で固定し、週次の lock 更新で追従する。
{
  config,
  lib,
  pkgs,
  skillSources,
  ...
}:

let
  cfg = config.programs.agentSkills;

  vercelSkillsSrc = skillSources.vercel-skills;
  anthropicsSkillsSrc = skillSources.anthropic-skills;
  vercelAgentSkillsSrc = skillSources.vercel-agent-skills;
  mattpocockSkillsSrc = skillSources.mattpocock-skills;

  orcaChatSkillsDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/orca/antigravity-chat/config/skills"
    else
      ".config/orca/antigravity-chat/config/skills";

  deploySkill = name: src: {
    ".claude/skills/${name}".source = src;
    ".agents/skills/${name}".source = src;
    ".gemini/skills/${name}".source = src;
    ".gemini/config/skills/${name}".source = src;
    "${orcaChatSkillsDir}/${name}".source = src;
  };

  # 自作スキル: 実体 (正本) は各リポジトリ側に置き、ここからシンボリックリンクで配置する
  # (obsidian-brain と同じ方式。リポジトリ側の編集が、再 switch なしで即座に反映される)。
  # リポジトリを clone していないマシンではリンク切れになるだけで、実害はない。
  localSkills = {
    # デスクトップペット「もちペット」の開発・拡張の知見と手順 (Naruto-Takahashi/mochi-pet、プライベート)
    mochi-pet = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/mochi-pet/skills/mochi-pet";
  };

  deployLocalSkill = name: path: {
    ".claude/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink path;
    ".agents/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink path;
    ".gemini/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink path;
    ".gemini/config/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink path;
    "${orcaChatSkillsDir}/${name}".source = config.lib.file.mkOutOfStoreSymlink path;
  };

  localSkillsFiles = lib.mkIf cfg.enableLocalSkills (
    lib.mkMerge (lib.mapAttrsToList deployLocalSkill localSkills)
  );

  findSkillsFiles = lib.mkIf cfg.enableFindSkills (
    deploySkill "find-skills" "${vercelSkillsSrc}/skills/find-skills"
  );

  frontendSkillsFiles = lib.mkIf cfg.enableFrontendSkills (
    lib.mkMerge [
      (deploySkill "frontend-design" "${anthropicsSkillsSrc}/skills/frontend-design")
      (deploySkill "web-design-guidelines" "${vercelAgentSkillsSrc}/skills/web-design-guidelines")
    ]
  );

  architectureSkillsFiles = lib.mkIf cfg.enableArchitectureSkills (
    lib.mkMerge [
      (deploySkill "improve-codebase-architecture" "${mattpocockSkillsSrc}/skills/engineering/improve-codebase-architecture")
      (deploySkill "codebase-design" "${mattpocockSkillsSrc}/skills/engineering/codebase-design")
    ]
  );

  workflowSkillsFiles = lib.mkIf cfg.enableWorkflowSkills (
    lib.mkMerge [
      (deploySkill "grill-me" "${mattpocockSkillsSrc}/skills/productivity/grill-me")
      (deploySkill "diagnosing-bugs" "${mattpocockSkillsSrc}/skills/engineering/diagnosing-bugs")
      (deploySkill "skill-creator" "${anthropicsSkillsSrc}/skills/skill-creator")
      (deploySkill "xlsx" "${anthropicsSkillsSrc}/skills/xlsx")
      (deploySkill "pdf" "${anthropicsSkillsSrc}/skills/pdf")
    ]
  );
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

    enableLocalSkills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "自作スキル (mochi-pet など。実体は各リポジトリ側) をシンボリックリンクで配置するかどうか。";
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
      localSkillsFiles
    ];
  };
}
