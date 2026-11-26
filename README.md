<div align="center">

![header](https://capsule-render.vercel.app/api?type=waving&height=210&color=0:171717,35:484848,65:999999,100:c6c6c6&text=nix-config&fontColor=c7c7c7&fontSize=64&fontAlignY=36&desc=Declarative%20environments%20for%20NixOS%20%C2%B7%20WSL2%20%C2%B7%20macOS&descColor=c7c7c7&descSize=16&descAlignY=58)

[![CI](https://img.shields.io/github/actions/workflow/status/Naruto-Takahashi/nix-config/check.yml?branch=main&style=flat-square&logo=github-actions&logoColor=white&label=CI&labelColor=181616)](https://github.com/Naruto-Takahashi/nix-config/actions/workflows/check.yml)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?style=flat-square&logo=nixos&logoColor=white&labelColor=181616)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-7aa89f?style=flat-square&logo=nixos&logoColor=white&labelColor=181616)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-e6c384?style=flat-square&logo=nixos&logoColor=white&labelColor=181616)](https://github.com/nix-community/home-manager)
[![nix-darwin](https://img.shields.io/badge/nix-darwin-a292a3?style=flat-square&logo=apple&logoColor=white&labelColor=181616)](https://github.com/LnL7/nix-darwin)
[![Last Commit](https://img.shields.io/github/last-commit/Naruto-Takahashi/nix-config?style=flat-square&logo=git&logoColor=white&labelColor=181616&color=7fb4ca)](https://github.com/Naruto-Takahashi/nix-config/commits/main)

<br>

[![Tech Stack](https://skillicons.dev/icons?i=nix,linux,windows,apple,neovim,lua,bash,py,git&theme=dark)](https://github.com/Naruto-Takahashi/nix-config)

</div>

**Nix Flakes** と **Home Manager** を使用して，NixOS，および WSL2 環境を宣言的に一元管理するための設定ファイル群（レシピ）です．

OSレベルのシステム定義から，シェル環境，ウィンドウマネージャー，開発ツールまでを一元管理し，キーボード駆動の快適な開発環境を構築します．すべての CLI/GUI が **Matugen** により壁紙から生成された配色で統一されます．

![divider](https://capsule-render.vercel.app/api?type=rect&height=3&color=0:c6c6c6,50:999999,100:999999)

## どれがどのOSで動くか (対応表)

このリポジトリは3つのホスト (`nixosConfigurations.nixos` / `homeConfigurations.wsl` / `darwinConfigurations.mac`) を1つのFlakeから宣言的に管理しています．
全ホスト共通の土台は [`profiles/base.nix`](profiles/base.nix) で，そこにホストごとの [`hosts/<host>/`](hosts) が個別モジュールを足していく構造です．
**同じ「Alt長押しでウィンドウ操作」のような機能でも，OSごとに実装方式が違う**箇所があるので，表で確認してから各ドキュメントに進んでください．

凡例: ✅ 有効 / ➖ 未導入 (この構成では使っていない) / (Windows) Windows側で動作 (WSLからは同期のみ)

| 機能 / モジュール | NixOS | WSL2 | macOS |
| :--- | :---: | :---: | :---: |
| **タイルWM** | [Hyprland](modules/wm/hyprland/README.md) ✅ | [komorebi](modules/wm/komorebi/README.md) (Windows) | [AeroSpace](modules/wm/aerospace/README.md) ✅ |
| **ステータスバー** | [Waybar](modules/wm/hyprland/README.md) ✅ | [YASB](modules/wm/komorebi/README.md) (Windows) | macOS標準メニューバー |
| **キーボードリマップ** | [Kanata](modules/input/kanata/README.md) ✅ | [AutoHotkey](modules/input/kanata/README.md) (Windows)※1 | [Karabiner-Elements](modules/input/karabiner/default.nix) ✅※2 |
| **壁紙連動の動的配色** | [Matugen](modules/theming/matugen/README.md) ✅ | [Matugen](modules/theming/matugen/README.md) ✅ (Windows側) | [Matugen](modules/theming/matugen/README.md) ✅ |
| **日本語入力** | fcitx5 + Mozc ✅ | Google日本語入力 (kanata非搭載のため対象外) | macOS標準IME ([切替キー](modules/input/kanata/README.md)) |
| **リモートデスクトップ** | [Tailscale+Sunshine](docs/setup-nixos.md#5-リモートデスクトップの初回認証tailscale--sunshine) ✅ | ➖ (接続元クライアント) | ➖ |
| **Obsidian 外部脳連携** | [Obsidian Brain](modules/services/README.md) ✅ | [Obsidian Brain](modules/services/README.md) ✅ | [Obsidian Brain](modules/services/README.md) ✅ |
| **Homebrew Cask管理** | ➖ | ➖ | [darwin.nix](hosts/mac/darwin.nix) ✅ |
| [WezTerm](modules/gui/wezterm/README.md) | ✅ | ✅ | ✅ |
| [Neovim](modules/cli/neovim/README.md) | ✅ | ✅ | ✅ |
| [Yazi](modules/cli/yazi/README.md) | ✅ | ✅ | ✅ |
| [lazygit / eza / bat / btop / atuin / starship等](docs/cli-tools.md) | ✅ | ✅ | ✅ |
| [gitmoji](modules/cli/git-hooks/README.md) (git-hooks) | ✅ | ✅ | ✅ |

※1 WSLからはWindows側の物理キーボードを直接掴めないため，Kanataではなく [`modules/input/ahk/main.ahk`](modules/input/ahk/main.ahk) が同等の機能を別実装しています．
※2 macOSはWM操作の変換先が`Ctrl+Cmd`（NixOSは`Super`単体）になるなど，キー配線が一部異なります．詳細は[kanata.md](modules/input/kanata/README.md)の「対象OS・実装方式の違い」を参照．

## 運用ルールと二重管理の一覧

- **変更・追加の手順、置き場所のルール、確認コマンド**は [CONTRIBUTING.md](CONTRIBUTING.md) にまとめています。人も AI も、作業の前に読んでください ([AGENTS.md](AGENTS.md) から誘導しています)。
- **ホストごとの索引** (そのホストが何を使っているか): [mac](hosts/mac/README.md) / [nixos](hosts/nixos/README.md) / [wsl](hosts/wsl/README.md) / [distrobox](hosts/distrobox/README.md) / [sandbox](hosts/sandbox/README.md)
- 各ツールの解説は、そのツールのフォルダにある `README.md` です (例: [AeroSpace](modules/wm/aerospace/README.md))。冒頭に「役割・対象ホスト・対になる実装・注意」があります。

### 同じ役割の別実装 (どれかを直したら、他も確認する)

OSごとにツールが違うため、同じ役割の実装が複数あります。**片方を直したら、下の「対になる実装」も確認してください。** 該当ファイルの先頭に `SYNC-PAIR:` のコメントがあり、CI が相互参照を検査します (`just check-sync`)。

| 役割 | macOS | NixOS | WSL2 |
| :--- | :--- | :--- | :--- |
| キーボードリマップ | [Karabiner](modules/input/karabiner/default.nix) | [Kanata](modules/input/kanata/config.kbd) | Kanata (同じ `config.kbd`) / [AutoHotkey](modules/input/ahk/main.ahk) (フォールバック) |
| WM のキーバインド | [aerospace.toml](modules/wm/aerospace/aerospace.toml) | [keybinds.conf](modules/wm/hyprland/config/hypr/configs/keybinds.conf) | [komorebi.ahk](modules/wm/komorebi/komorebi.ahk) |
| Matugen の適用スクリプト | [mac/](modules/theming/matugen/mac) | [Hyprland 側](modules/wm/hyprland/config/matugen) | [wsl/](modules/theming/matugen/wsl) |

![divider](https://capsule-render.vercel.app/api?type=rect&height=3&color=0:c6c6c6,50:999999,100:999999)

## ディレクトリ構造

```
.
├── flake.nix                  # Flake エントリーポイント（システム構成の定義）
├── justfile                   # 共通タスクランナー (switch, check, fmt, lint, restore-secrets 等)
├── AGENTS.md                  # AI エージェント向けの入口 (CONTRIBUTING.md を読ませる)
├── CONTRIBUTING.md            # 変更・追加・保守の手順と、置き場所のルール
├── hosts/                     # ホスト別の設定エントリーポイント (全ホスト default.nix = Home Manager)
│   ├── nixos/                 # NixOS 設定 (configuration.nix [システム] ＋ default.nix [HM])
│   ├── wsl/                   # WSL2用 Home Manager スタンドアロン設定 (default.nix + sync-win.nix)
│   ├── mac/                   # macOS用 nix-darwin (darwin.nix) + Home Manager (default.nix) 統合設定
│   ├── distrobox/             # rootless podman コンテナ用 CLI プロファイル (default.nix)
│   └── sandbox/               # 実データ非共有コンテナ用 最小CLI プロファイル (default.nix)
│                              #   各ホストに README.md (そのホストが使うものの索引) がある
├── modules/                   # 機能別の設定モジュール群 (各ツールのフォルダに README.md = 解説)
│   ├── wm/                    # ウィンドウマネージャー設定 (hyprland[Linux], komorebi/yasb[Win], aerospace/hammerspoon[Mac])
│   ├── ai/                    # AIエージェント開発環境 (claude-code, antigravity, agent-skills)
│   ├── cli/                   # ターミナルツール・TUI (bat, btop, eza, git, git-hooks, lazygit, neovim, yazi)
│   ├── gui/                   # デスクトップGUIアプリ (wezterm, vivaldi, linux.nix[Linuxパッケージ])
│   ├── input/                 # 入力系 (kanata キーリマップ[NixOS/Mac/WSL], ahk[WSL])
│   ├── platform/              # プラットフォーム共通オプション (wsl.nix: Windows 側ユーザー名・ホーム)
│   ├── services/              # ユーザーサービス (obsidian-brain 外部脳連携)
│   ├── shell/                 # シェル・端末環境 (zsh, starship, direnv, atuin)
│   └── theming/               # Matugen 共通ロジック / テンプレート (lib, templates) とホスト別パイプライン
├── profiles/                  # 役割別プロファイル
│   ├── core.nix               # 最小共通 CLI (modules/cli/* + modules/shell/*)
│   ├── desktop.nix            # デスクトップ GUI 共通 (modules/gui/wezterm + modules/theming/*)
│   ├── ai-agent.nix           # AIエージェント統合 (modules/ai/* + modules/services/obsidian-brain.nix)
│   └── base.nix               # 開発機向けフルセット (desktop.nix + ai-agent.nix)
└── docs/                      # セットアップ手順書と、複数ツールにまたがる文書 ([索引](docs/README.md))
```

![divider](https://capsule-render.vercel.app/api?type=rect&height=3&color=0:c6c6c6,50:999999,100:999999)

## セットアップとインストール手順 (移行ガイド)

環境の一貫性を保つため，リポジトリは必ず規定の `ghq` ディレクトリ構造配下にクローンしてください．

```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

OSごとの詳しい手順は個別ページに分けています．上の対応表で自分のホストを確認してから該当ページを開いてください．

| ホスト | セットアップ手順 | 特記事項 |
| :--- | :--- | :--- |
| **NixOS** | [docs/setup-nixos.md](docs/setup-nixos.md) | 最もシンプル。`nixos-rebuild switch`一発 |
| **WSL2** | [docs/setup-wsl.md](docs/setup-wsl.md) | 適用後に`sync-win`でWindows側へ設定を同期 |
| **macOS** | [docs/setup-mac.md](docs/setup-mac.md) | 手順が最も多い。TCC/SIPの都合で数点だけ手動のGUI操作が残る |
| **sudo無し共有Linux (rootless podman)** | [docs/setup-distrobox.md](docs/setup-distrobox.md) | CLIツールのみのアドオン的プロファイル。distroboxコンテナ内に`/nix`を作る |

---

### 日常のコマンド操作 (`just`)

共通タスクランナーとして [`just`](justfile) を導入しています．どのマシンでも以下の短縮コマンドが利用できます．

```bash
just switch            # 現在のOSを自動判別して設定を適用 (新規ファイルは git add -N で自動的に評価対象へ)
just check             # 全構成の静的評価・構文検証 (CIと同等)
just fmt               # 全Nixコードの自動フォーマット (nixfmt)
just lint              # リンク切れ・対になる実装の整合性などを検査 (CIと同等)
just sync-win          # Windows側への設定同期 (WSL専用)
just restore-secrets   # Bitwarden CLI から ~/.env を安全に復元 (chmod 600)
just restore-ssh       # Bitwarden CLI から SSH 鍵と config を復元 (chmod 600)
```

![divider](https://capsule-render.vercel.app/api?type=rect&height=3&color=0:c6c6c6,50:999999,100:999999)

<details>
<summary><b>English Translation (Click to expand)</b></summary>

# nix-config

Declarative configurations for NixOS, WSL2, and macOS managed via **Nix Flakes**, **Home Manager**, and **nix-darwin**.

## What runs where (OS support matrix)

This repo manages three hosts (`nixosConfigurations.nixos` / `homeConfigurations.wsl` /
`darwinConfigurations.mac`) from a single flake. All hosts
share [`profiles/base.nix`](profiles/base.nix) as a baseline, and each [`hosts/<host>/`](hosts)
adds host-specific modules on top. **The same logical feature (e.g. "hold Alt to manage windows")
is often implemented differently per OS** — check this table before diving into a doc.

Legend: ✅ enabled · ➖ not set up in this config · (Windows) runs on the Windows side (WSL only syncs to it)

| Feature / Module | NixOS | WSL2 | macOS |
| :--- | :---: | :---: | :---: |
| **Tiling WM** | [Hyprland](modules/wm/hyprland/README.md) ✅ | [komorebi](modules/wm/komorebi/README.md) (Windows) | [AeroSpace](modules/wm/aerospace/README.md) ✅ |
| **Status bar** | [Waybar](modules/wm/hyprland/README.md) ✅ | [YASB](modules/wm/komorebi/README.md) (Windows) | native macOS menu bar |
| **Keyboard remapping** | [Kanata](modules/input/kanata/README.md) ✅ | [AutoHotkey](modules/input/kanata/README.md) (Windows)* | [Karabiner-Elements](modules/input/karabiner/default.nix) ✅** |
| **Wallpaper-driven theming** | [Matugen](modules/theming/matugen/README.md) ✅ | [Matugen](modules/theming/matugen/README.md) ✅ (Windows side) | [Matugen](modules/theming/matugen/README.md) ✅ |
| **Japanese input** | fcitx5 + Mozc ✅ | Google Japanese Input (no Kanata here) | native macOS IME ([switch keys](modules/input/kanata/README.md)) |
| **Remote desktop** | [Tailscale+Sunshine](docs/setup-nixos.md#5-リモートデスクトップの初回認証tailscale--sunshine) ✅ | ➖ (client only) | ➖ |
| **Obsidian External Brain** | [Obsidian Brain](modules/services/README.md) ✅ | [Obsidian Brain](modules/services/README.md) ✅ | [Obsidian Brain](modules/services/README.md) ✅ |
| **Homebrew Cask management** | ➖ | ➖ | [darwin.nix](hosts/mac/darwin.nix) ✅ |
| [WezTerm](modules/gui/wezterm/README.md) | ✅ | ✅ | ✅ |
| [Neovim](modules/cli/neovim/README.md) | ✅ | ✅ | ✅ |
| [Yazi](modules/cli/yazi/README.md) | ✅ | ✅ | ✅ |
| [lazygit / eza / bat / btop / atuin / starship, etc.](docs/cli-tools.md) | ✅ | ✅ | ✅ |
| [gitmoji](modules/cli/git-hooks/README.md) (git-hooks) | ✅ | ✅ | ✅ |

\* WSL can't grab Windows' physical keyboard directly, so [`modules/input/ahk/main.ahk`](modules/input/ahk/main.ahk)
reimplements the equivalent behavior separately instead of using Kanata.
\*\* macOS translates the WM modifier to `Ctrl+Cmd` (vs. bare `Super` on NixOS) and a few
other keys differ — see "OS別の違い" in [kanata.md](modules/input/kanata/README.md).

## Repository Structure

* `hosts/`: Host-specific entry points (NixOS, WSL2, macOS).
* `modules/`: Shared reusable configurations (Window managers, CLI apps, Zsh configs).
* `docs/`: Setup guides and cross-cutting documents. Each tool's own documentation lives in a `README.md` next to its code.
* [`CONTRIBUTING.md`](CONTRIBUTING.md): Where things go and how to change them. AI agents are pointed there from [`AGENTS.md`](AGENTS.md).
* Some roles are implemented separately per OS (key remapping: Karabiner / Kanata / AutoHotkey; WM keybindings: AeroSpace / Hyprland / komorebi). Files carry a `SYNC-PAIR:` comment naming their counterparts, checked by CI (`just check-sync`). See the table in "運用ルールと二重管理の一覧".

## Quick Start

```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

Detailed per-host setup steps live in `docs/` (Japanese only, same convention as the rest of `docs/`).
The short version:

| Host | Setup guide | One-liner |
| :--- | :--- | :--- |
| NixOS | [docs/setup-nixos.md](docs/setup-nixos.md) | `sudo nixos-rebuild switch --flake .#nixos --impure`, then reboot |
| WSL2 | [docs/setup-wsl.md](docs/setup-wsl.md) | Install Nix, `nix run github:nix-community/home-manager -- switch --flake .#wsl --impure`, then `sync-win` to push config to the Windows side |
| macOS | [docs/setup-mac.md](docs/setup-mac.md) | `sudo nix run github:LnL7/nix-darwin -- switch --flake .#mac`, then a few manual TCC/SIP permission grants (unavoidable — see the guide) |
| Sudo-less shared Linux (rootless podman) | [docs/setup-distrobox.md](docs/setup-distrobox.md) | CLI-only add-on profile: `distrobox create` an Ubuntu container, install Nix inside it (real `/nix`, no sudo needed on the host), `nix run github:nix-community/home-manager -- switch --flake .#distrobox --impure` |


</details>

<div align="center">

![footer](https://capsule-render.vercel.app/api?type=waving&height=110&color=0:c6c6c6,35:999999,65:484848,100:171717&section=footer)

</div>
