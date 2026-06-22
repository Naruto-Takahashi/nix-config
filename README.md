# 🌌 Naruto's Declarative Configuration (NixOS + Home Manager)

このリポジトリは，**Nix Flakes** と **Home Manager** を使用して，NixOS，Linuxデスクトップ（Ubuntu），および WSL2 環境を宣言的に一元管理するための設定ファイル群（レシピ）です．
ゴールド（`#ffc20d`）とダークテーマを基調とした，美しく，キーボード駆動で圧倒的な生産性を誇る「極上のハッカー向け開発環境」を構築します．

---

## 📖 設定・キーマップの詳細解説 (Detailed Documentation)

デスクトップの操作方法やキーマップの詳細は，以下の各個別ドキュメントから詳細にご確認いただけます．

* 🗔 **[i3wm キーバインド・設定詳細](docs/i3wm.md)** (Desktop/NixOSのみ): 画面のレイアウト，ワークスペース切り替え，スクリーンショット，最小化・オートタイル復元の詳細．
* 🗔 **[Hyprland キーバインド・設定詳細](docs/hyprland.md)** (NixOSのみ): 物理Altキーから変換されたSuperキーを使ったGlazeWM互換操作，自動テーマ配色連携（Matugen）の詳細．
* 🗔 **[GlazeWM キーバインド・設定詳細](docs/glazewm.md)** (WSLのみ/Windows側): Windows環境におけるタイル型ウィンドウ操作，Zebar連携，一時停止モードの詳細．
* ⌨️ **[Kanata キーマップ詳細](docs/kanata.md)** (NixOS/Desktopのみ): スペースキー長押しによるVimライク移動，Altキーによるウィンドウ操作・Mac風IME切り替えの詳細．
* 💻 **[WezTerm 設定・キーバインド詳細](docs/wezterm.md)**: フォント，背景の75%半透明適用，動的タブタイトル，Leaderキー（`Ctrl+Space`）によるタブ・ペイン管理．
* 📝 **[Neovim 設定・キーマップ詳細](docs/neovim.md)**: 相対行表示や透過背景設定，`jk` によるインサート抜け，Zenn用画像貼り付けなどの高度なLuaカスタムマクロ．
* 📁 **[Yazi 設定・使い方詳細](docs/yazi.md)**: Cyberdreamテーマカスタマイズ・透過設定，Vim風キーバインド全一覧，シェル統合によるディレクトリ移動連携．
* 🌐 **[Chrome Remote Desktop 設定詳細](docs/chrome-remote-desktop.md)**: 自宅から研究室PCへセキュアにアクセスするための，Google経由のリモートデスクトップ設定手順．

---

## 🎨 環境・機能のこだわり紹介 (Showcase)

* **NixOS 統合管理**: OSのブートローダー，ネットワーク，日本語入力（Fcitx5-Mozc）から，ユーザー個人の Neovim や WezTerm 設定まで，完全に単一の Flake で再現可能にしました．
* **キーボードリマッパー (`Kanata`)**: US配列キーボードを前提とし，左右Alt単押しでのIME（日本語/英語）の切り替えや，**SandS（Space and Shift）**思想を継承した「スペース長押しナビゲーションレイヤー」を搭載．
* **ウィンドウマネージャー (`i3wm` / `GlazeWM`)**: Linux環境での `i3wm` と，WSL使用時のWindows側での `GlazeWM` の両環境で，ゴールドとダークな色調で美しく統一されたタイル型ウィンドウ環境を構築．
* **ターミナル (`WezTerm`)**: 不透明度75%の美しい半透明背景．フォントには「HackGen NF」を適用し，上部タブバーも本体と同じ透過率に完璧に調和．
* **互換性機能 (`nix-ld`)**: NixOS にありがちな「外部でビルドされた動的リンクバイナリ（`agy` コマンドなど）が動作しない」問題を，`nix-ld` をシステムで有効化することで自動的に解決．

---

## 🚀 新しいPCで環境を完全再現する手順（PC移行ガイド）

### A. NixOS 環境へ導入する場合

NixOSの公式インストーラで最小インストール（ユーザー名は **`nalt`** で作成）を完了した後の手順です．

#### Step 1: `git` の一時的起動とリポジトリのクローン
NixOS に `git` が入っていない場合は，一時的に `nix-shell` で `git` を起動してクローンします．
```bash
nix-shell -p git
```
起動したシェルの中で，リポジトリを `ghq` 管理下の所定のディレクトリへクローンします．
```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

#### Step 2: ハードウェア構成ファイルのコピー
その PC 用に自動生成されたハードウェア構成ファイルをリポジトリ内に上書きコピーし，Git の追跡対象に追加します．
```bash
cp /etc/nixos/hardware-configuration.nix hosts/nixos/hardware-configuration.nix
git add hosts/nixos/hardware-configuration.nix
```

#### Step 3: 設定の構築と適用
Flakes を利用してシステム構成と Home Manager の設定を一括適用します．
```bash
sudo nixos-rebuild switch --flake .#nixos --impure
```
適用後，`exit` で一時シェルを抜けて PC を再起動してください．

---

### B. 一般の Linux (Ubuntu) または WSL2 環境へ導入する場合

#### Step 1: Nix パッケージマネージャーのインストール
```bash
curl -L https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
```

#### Step 2: Nix Flakes 機能の有効化
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

#### Step 3: 設定リポジトリのクローンと適用
```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

**Ubuntu デスクトップ環境の場合 (`nalt-desktop`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake .#nalt-desktop --impure
```

**WSL 環境の場合 (`nalt-wsl`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake .#nalt-wsl --impure
```

#### Step 4: 各種サービスとシェルの起動
```bash
# Kanata のユーザーサービス自動起動登録 (Desktopのみ)
systemctl --user daemon-reload
systemctl --user enable --now kanata

# 新しい Zsh シェルの起動
exec zsh
```

---

<details>
<summary>📖 <b>English Translation (Click to expand)</b></summary>

## 🌌 Overview

This repository manages Naruto's NixOS, Linux desktop (Ubuntu), and WSL2 environments declaratively using **Nix Flakes** and **Home Manager**. It provides a fully unified, modern, keyboard-driven development environment with premium gold (`#ffc20d`) / dark hacker-mode aesthetics.

### 📖 Detailed Configurations & Keymaps Documentation

* 🗔 **[i3wm Keybindings & Configurations](docs/i3wm.md)** (Desktop/NixOS only): Details on layout structure, workspace navigation, screenshots, scratchpad minimization, and auto-tiling restoration.
* 🗔 **[Hyprland Keybindings & Configurations](docs/hyprland.md)** (NixOS only): Details on GlazeWM-compatible operations using Super key converted from physical Alt, and Matugen automatic theme color integration.
* 🗔 **[GlazeWM Keybindings & Configurations](docs/glazewm.md)** (WSL only/Windows side): Details on Windows tiling window management, Zebar status bar integration, and configuration bypass via Pause mode.
* ⌨️ **[Kanata Keyboard Remapping](docs/kanata.md)** (NixOS/Desktop only): Details on SandS Vim-like spacebar navigation, Alt-key window commands, and Mac-style IME switching.
* 💻 **[WezTerm Configurations & Keybindings](docs/wezterm.md)**: Font setups, 75% uniform background transparency, dynamic tab titles, and custom Leader key (`Ctrl+Space`) bindings.
* 📝 **[Neovim Configurations & Keybindings](docs/neovim.md)**: Relative numbers, transparent editor background, `jk` escape shortcut, Zenn custom screenshot pasting macro, and robust Lazy.nvim plugin list.
* 📁 **[Yazi File Manager — Configuration & Usage](docs/yazi.md)**: Cyberdream theme customization, transparency settings, full Vim-style keybinding reference, and shell integration for seamless directory navigation.

---

## 🚀 Environment Setup & Replication Guide (PC Migration)

### A. Installing on NixOS

1. Clone this repository under `ghq` directory (using `nix-shell -p git` if `git` is not installed yet):
   ```bash
   mkdir -p ~/ghq/github.com/Naruto-Takahashi
   cd ~/ghq/github.com/Naruto-Takahashi
   git clone https://github.com/Naruto-Takahashi/nix-config.git
   cd nix-config
   ```
2. Copy your auto-generated hardware configuration file:
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/nixos/hardware-configuration.nix
   git add hosts/nixos/hardware-configuration.nix
   ```
3. Apply the system and Home Manager configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos --impure
   ```

### B. Installing on Generic Linux (Ubuntu) or WSL2

1. Install Nix:
   ```bash
   curl -L https://nixos.org/nix/install | sh
   . ~/.nix-profile/etc/profile.d/nix.sh
   ```
2. Enable Flakes:
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```
3. Clone and apply:
   ```bash
   mkdir -p ~/ghq/github.com/Naruto-Takahashi
   cd ~/ghq/github.com/Naruto-Takahashi
   git clone https://github.com/Naruto-Takahashi/nix-config.git
   cd nix-config
   
   # For Ubuntu Desktop:
   nix run github:nix-community/home-manager -- switch --flake .#nalt-desktop --impure
   
   # For WSL:
   nix run github:nix-community/home-manager -- switch --flake .#nalt-wsl --impure
   ```

</details>
