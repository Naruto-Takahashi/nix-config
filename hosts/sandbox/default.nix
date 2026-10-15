# =========================================================================
# Home Manager 用設定ファイル: 実データ非共有コンテナ内のCLI環境
# =========================================================================
# wslc (WSL Containers) 等、ホストのファイルシステムを明示的にマウントしない
# コンテナの中で、普段と同じCLIツール・neovim設定を使うためのプロファイル。
# distrobox系は「ホストとのシームレスな統合」のためホストのファイルシステム
# を広範囲に共有する設計だが、このホストは逆に「コンテナが実データの置き場所
# (ホスト側)を一切見えない」ことを前提にしているため、hosts/distroboxとは
# コンテナの作り方そのものが異なる。GUI/systemdユーザーサービス/カーネル
# 入力リマップ(kanata)等コンテナに乗らないものはimportしない。
#
# このコンテナは使い捨てであり、ホストと共有するユーザーアカウントの概念が
# 不要なため、rootのまま動かす前提でusername/homeDirectoryを固定している。
{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
  ];

  home.username      = "root";
  home.homeDirectory = "/root";
  home.stateVersion  = "25.11";

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
}
