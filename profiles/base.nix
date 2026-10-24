# =========================================================================
# 開発用フルスタック共通プロファイル (base.nix)
# =========================================================================
# desktop.nix (GUI + コアCLI) と ai-agent.nix (AI開発連携) を束ねた
# デフォルトの開発機向けプロファイル。
# リモートサーバーやコンテナで GUI が不要な場合は、直接 profiles/core.nix や
# profiles/ai-agent.nix を単体で import する。
{ config, pkgs, lib, ... }:

{
  imports = [
    ./desktop.nix
    ./ai-agent.nix
  ];
}
