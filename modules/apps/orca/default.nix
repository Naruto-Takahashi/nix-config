# =========================================================================
# Orca (マルチエージェント ADE) 用エージェントスキル配置モジュール
# =========================================================================
# Orca 本体 (デスクトップアプリ) は Windows 側にインストールし、エージェント
# (claude / agy) は Orca の managed WSL session として WSL 内で動かす前提。
# そのためスキルは WSL 側のエージェントが読む場所へ配置する。
#
# `npx skills add ... --global` の代わりに、上流リポジトリをコミット固定で
# 取得して宣言的に配置する。skills CLI (1.7.2) は Antigravity CLI の配置先を
# ~/.gemini/antigravity-cli/skills としているが、agy 1.2.x が実際に読む
# グローバルスキルは ~/.gemini/config/skills/<name>/SKILL.md である。
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.orca;

  # スキルを更新する場合は rev と hash を差し替える
  # (hash は `nix-prefetch-url --unpack <archive URL>` で取得)
  orcaSrc = pkgs.fetchFromGitHub {
    owner = "stablyai";
    repo = "orca";
    rev = "071747853f5995ee233b36751613f09a60007c2b";
    sha256 = "0af2pcm6pkjy5gjs9adz63n3hs1vjyxq906mr44a6h4wan1phafl";
  };

  vercelSkillsSrc = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "skills";
    rev = "a80e4c9d12d607631249d4d7d059f835d4b2f13a";
    sha256 = "1djab5lz3yg0r8f4m57071sxj0jpprlzzhrd1zswdann96297xb1";
  };

  skillFiles = name: {
    ".claude/skills/${name}/SKILL.md".source = "${orcaSrc}/skills/${name}/SKILL.md";
    ".gemini/config/skills/${name}/SKILL.md".source = "${orcaSrc}/skills/${name}/SKILL.md";
  };

  findSkillsFiles = lib.mkIf cfg.enableFindSkills {
    ".claude/skills/find-skills/SKILL.md".source = "${vercelSkillsSrc}/skills/find-skills/SKILL.md";
    ".gemini/config/skills/find-skills/SKILL.md".source = "${vercelSkillsSrc}/skills/find-skills/SKILL.md";
  };
in
{
  options.programs.orca = {
    enable = lib.mkEnableOption "Orca 用エージェントスキルの配置";

    skills = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # orchestration はハンドオフ・ターミナル操作を orca-cli スキルへ委譲するため両方入れる
      # computer-use は Windows アプリの GUI 操作用 (WSL からは orca-ide 経由)
      default = [ "orchestration" "orca-cli" "computer-use" ];
      description = "stablyai/orca リポジトリの skills/ 配下から配置するスキル名。";
    };

    enableFindSkills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "vercel-labs/skills の find-skills (スキル探索・導入メタスキル) を配置するかどうか。";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge (
      (map skillFiles cfg.skills)
      ++ [ findSkillsFiles ]
    );
  };
}
