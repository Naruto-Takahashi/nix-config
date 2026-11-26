# hosts/nixos — NixOS

> **役割**: NixOS 機 (Hyprland のデスクトップ)。NixOS (システム) + Home Manager (ユーザー) の構成 (`nixosConfigurations.nixos`)
> **適用**: `just switch` (または `nixos-rebuild switch`)
> **初回セットアップ**: [docs/setup-nixos.md](../../docs/setup-nixos.md) (Tailscale + Sunshine のリモートデスクトップ設定を含む)

## このホストが使うもの

| 区分 | 内容 | 場所 |
| :--- | :--- | :--- |
| システム設定 | カーネル・GPU・ネットワーク (Tailscale / WARP)・サービス・`nix.gc` | [configuration.nix](configuration.nix) |
| ハードウェア | 自動生成 (手で編集しない) | [hardware-configuration.nix](hardware-configuration.nix) |
| ユーザー設定の入口 | imports の一覧。ここを読めば、このホストが使うモジュールが全部分かる | [default.nix](default.nix) |
| 共通の土台 | CLI・シェル・WezTerm・Matugen・AI エージェント環境 | [profiles/base.nix](../../profiles/base.nix) |
| ウィンドウ管理 | Hyprland (Waybar / Rofi / swaync / wlogout を含む) | [modules/wm/hyprland](../../modules/wm/hyprland/README.md) |
| キーボードリマップ | Kanata (Linux 用の置換は `linux-config.nix`) | [modules/input/kanata](../../modules/input/kanata/README.md) |
| Linux 共通パッケージ | NixOS と WSL で共有する GUI 系パッケージ (kanata など) | [modules/gui/linux.nix](../../modules/gui/linux.nix) |
| ブラウザ | Vivaldi | [modules/gui/vivaldi](../../modules/gui/vivaldi) |
| Orca | Orca IDE のパッケージ | [modules/ai/orca](../../modules/ai/orca) |

## 対になる実装 (直したら他も確認する)

- キーボードリマップ: Kanata ↔ [Karabiner](../../modules/input/karabiner/default.nix) (Mac) / [AutoHotkey](../../modules/input/ahk/main.ahk) (WSL)
- WM のキーバインド: Hyprland ↔ [AeroSpace](../../modules/wm/aerospace/README.md) ↔ [komorebi](../../modules/wm/komorebi/README.md)

一覧と検査の仕組みは [README の「運用ルールと二重管理の一覧」](../../README.md#運用ルールと二重管理の一覧) と [CONTRIBUTING.md](../../CONTRIBUTING.md) を参照。
