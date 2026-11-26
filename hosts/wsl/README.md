# hosts/wsl — WSL2 (Windows)

> **役割**: Windows 上の WSL2。Home Manager のスタンドアロン構成 (`homeConfigurations.wsl`)。WSL 側 (Linux) の設定と、Windows 側 (komorebi / YASB / AutoHotkey / Kanata) の設定をまとめて管理し、`sync-win` で Windows に反映する
> **適用**: `just switch` のあと、`just sync-win` (Windows 側へ設定を同期)
> **初回セットアップ**: [docs/setup-wsl.md](../../docs/setup-wsl.md)

## このホストが使うもの

| 区分 | 内容 | 場所 |
| :--- | :--- | :--- |
| ユーザー設定の入口 | imports の一覧。ここを読めば、このホストが使うモジュールが全部分かる | [default.nix](default.nix) |
| Windows への反映 | Windows 側へファイルをコピーする処理 (設定・Vivaldi の CSS など) | [sync-win.nix](sync-win.nix) |
| 共通の土台 | CLI・シェル・WezTerm・Matugen・AI エージェント環境 | [profiles/base.nix](../../profiles/base.nix) |
| ウィンドウ管理 | komorebi + YASB (Windows 側で動く) | [komorebi](../../modules/wm/komorebi/README.md) / [yasb](../../modules/wm/yasb) |
| キーボードリマップ | Kanata (Windows 側のバイナリ) と、フォールバックの AutoHotkey | [kanata/wsl.nix](../../modules/input/kanata/wsl.nix) / [ahk](../../modules/input/ahk/main.ahk) |
| 壁紙連動の配色 | Matugen (WSL / Windows 用パイプライン) | [modules/theming/matugen/wsl](../../modules/theming/matugen/wsl) |
| Windows 側のユーザー名・ホーム | WSL 向けの共通オプション | [modules/platform/wsl.nix](../../modules/platform/wsl.nix) |
| Linux 共通パッケージ | NixOS と WSL で共有 | [modules/gui/linux.nix](../../modules/gui/linux.nix) |
| ブラウザ | Vivaldi (Windows 側へコピーして使う) | [modules/gui/vivaldi](../../modules/gui/vivaldi) |

## 対になる実装 (直したら他も確認する)

- キーボードリマップ: Kanata / AutoHotkey ↔ [Karabiner](../../modules/input/karabiner/default.nix) (Mac)
- WM のキーバインド: komorebi ↔ [AeroSpace](../../modules/wm/aerospace/README.md) ↔ [Hyprland](../../modules/wm/hyprland/README.md)
- Matugen の適用スクリプト: WSL ↔ [Mac](../../modules/theming/matugen/mac)

一覧と検査の仕組みは [README の「運用ルールと二重管理の一覧」](../../README.md#運用ルールと二重管理の一覧) と [CONTRIBUTING.md](../../CONTRIBUTING.md) を参照。

## 補足

WSL からは Windows 側の物理キーボードを直接掴めないため、Kanata は Windows 側のバイナリとして動く。Windows 側のファイルを変えたときは `just sync-win` を忘れない。
