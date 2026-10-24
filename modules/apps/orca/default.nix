# =========================================================================
# Orca (マルチエージェント ADE) 専用スキル配置モジュール
# =========================================================================
# Orca のワーカーオーケストレーション (orchestration, orca-cli, computer-use)
# に必要なスキルを宣言的に取得・配置する。
# 汎用のエンジニアリング・ワークフロースキルは modules/apps/agent-skills を参照。
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.orca;

  orcaSrc = pkgs.fetchFromGitHub {
    owner = "stablyai";
    repo = "orca";
    rev = "071747853f5995ee233b36751613f09a60007c2b";
    sha256 = "0af2pcm6pkjy5gjs9adz63n3hs1vjyxq906mr44a6h4wan1phafl";
  };

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
      default = [ "orchestration" "orca-cli" "computer-use" ];
      description = "stablyai/orca リポジトリの skills/ 配下から配置するスキル名。";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge (map skillFiles cfg.skills);
  };
}
