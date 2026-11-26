# hosts/mac — macOS (メイン)

> **役割**: メインのマシン。MacBook と Mac mini で共通の1構成 (`darwinConfigurations."mac"`)。nix-darwin (システム) + Home Manager (ユーザー) の統合設定
> **適用**: `just switch` (sudo は必要な箇所だけ求められる)
> **初回セットアップ**: [docs/setup-mac.md](../../docs/setup-mac.md) (TCC / SIP の都合で手動の GUI 操作が残る)

## このホストが使うもの

| 区分 | 内容 | 場所 |
| :--- | :--- | :--- |
| システム設定 | Homebrew cask、フォント、`nix-gc` (launchd)、`system.defaults`、Touch ID の sudo | [darwin.nix](darwin.nix) |
| ユーザー設定の入口 | imports の一覧。ここを読めば、このホストが使うモジュールが全部分かる | [default.nix](default.nix) |
| 共通の土台 | CLI・シェル・WezTerm・Matugen・AI エージェント環境 | [profiles/base.nix](../../profiles/base.nix) |
| ウィンドウ管理 | AeroSpace / AutoRaise / Hammerspoon | [aerospace](../../modules/wm/aerospace/README.md) / [autoraise](../../modules/wm/autoraise) / [hammerspoon](../../modules/wm/hammerspoon/README.md) |
| キーボードリマップ | Karabiner-Elements (全キーボードに一律適用) | [modules/input/karabiner](../../modules/input/karabiner/default.nix) |
| 壁紙連動の配色 | Matugen (Mac 用パイプライン) | [modules/theming/matugen/mac](../../modules/theming/matugen/mac) |
| ブラウザ | Vivaldi | [modules/gui/vivaldi](../../modules/gui/vivaldi) |

## 対になる実装 (直したら他も確認する)

- キーボードリマップ: Karabiner ↔ [Kanata](../../modules/input/kanata/README.md) (NixOS / WSL) ↔ [AutoHotkey](../../modules/input/ahk/main.ahk)
- WM のキーバインド: AeroSpace ↔ [Hyprland](../../modules/wm/hyprland/README.md) ↔ [komorebi](../../modules/wm/komorebi/README.md)
- Matugen の適用スクリプト: Mac ↔ [WSL](../../modules/theming/matugen/wsl)

一覧と検査の仕組みは [README の「運用ルールと二重管理の一覧」](../../README.md#運用ルールと二重管理の一覧) と [CONTRIBUTING.md](../../CONTRIBUTING.md) を参照。

## 補足

- アプリは Homebrew cask で宣言する (WM 周りと小さなユーティリティだけ)。それ以外は手動インストール。手動で入れるアプリの一覧は `darwin.nix` のコメントにある。
- Mac mini 固有の設定は無い。MacBook と同じ構成を適用する。
