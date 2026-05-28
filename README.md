# 🌌 Naruto's Declarative Desktop Configuration (Nix + Home Manager)

このリポジトリは、**Nix Flakes** と **Home Manager** を使用して、Linuxデスクトップ環境を宣言的に一元管理するための設定ファイル群（レシピ）です。
ゴールド（`#ffc20d`）とダークテーマを基調とした、美しく、キーボード駆動で圧倒的な生産性を誇る「極上のハッカー向け開発環境」を構築します。

---

## 📖 設定・キーマップの詳細解説 (Detailed Documentation)

デスクトップの操作方法やキーマップの詳細は、以下の各個別ドキュメントから詳細にご確認いただけます。

* 🗔 **[i3wm キーバインド・設定詳細](docs/i3wm.md)**: 画面のレイアウト、ワークスペース切り替え、スクリーンショット、最小化・オートタイル復元の詳細。
* ⌨️ **[Kanata キーマップ詳細](docs/kanata.md)**: スペースキー長押しによるVimライク移動、Altキーによるウィンドウ操作・Mac風IME切り替えの詳細。
* 💻 **[WezTerm 設定・キーバインド詳細](docs/wezterm.md)**: フォント、背景の75%半透明適用、動的タブタイトル、Leaderキー（`Ctrl+Space`）によるタブ・ペイン管理。
* 📝 **[Neovim 設定・キーマップ詳細](docs/neovim.md)**: 相対行表示や透過背景設定、`jk` によるインサート抜け、Zenn用画像貼り付けなどの高度なLuaカスタムマクロ。

---

## 🎨 環境・機能のこだわり紹介 (Showcase)

* **ウィンドウマネージャー (`i3wm`)**: ゴールドとダークな色調で美しく統一された X11 ウィンドウ環境。
* **ターミナル (`WezTerm`)**: 不透明度75%の美しい半透明背景。フォントには「HackGen NF」を適用し、上部タブバーも本体と同じ透過率に完璧に調和。
* **シェル (`Zsh`)**: Starship プロンプトをベースに、コマンドの有効/無効をリアルタイム色分け（緑/赤）する構文ハイライト、`zoxide` によるディレクトリ超高速移動、`fzf` による履歴検索を完備。
* **キーマップ管理 (`Kanata`)**: 左右Alt単押しでのIME（日本語/英語）切り替えに加え、**SandS（Space and Shift）**の思想を継承した「スペース長押しナビゲーションレイヤー」を搭載（`Space + HJKL/A/E/U/B/X` でカーソル移動・Undo・Backspace・Deleteが可能）。
* **グラフィックス (`picom`)**: X11コンポジタ。NVIDIAグラフィックス環境でも100%クラッシュせず極めて軽量に動作する `xrender` バックエンドを採用。
* **オートタイル復元**: 最小化（Scratchpad退避）したウィンドウを `ALT+TAB`（Rofi）で復元した際、手動でトグルせずとも自動的にタイリング表示へと瞬時に再配置する独自のラッパースクリプト（`rofi_window_wrapper.py`）を搭載。

---

## 🚀 新しいPCで環境を完全再現する手順（PC移行ガイド）

新しく Ubuntu 等をクリーンインストールした別のPCに、この環境をそのまま100%復元するためのセットアップ手順です。

### ⚙️ 事前の微調整（新しいPCのユーザー名が異なる場合）
新しいPCのユーザー名が `nalt` 以外（例: `naruto`）の場合は、リポジトリをクローン後、以下のファイルのユーザーメタデータを事前に書き換えてください。
* **対象ファイル**: `home.nix`（24〜25行目付近）
  ```nix
  home.username      = "new_username";      # 新しいユーザー名に変更
  home.homeDirectory = "/home/new_username";# 新しいホームの絶対パスに変更
  ```

---

### Step 1: Nix パッケージマネージャーのインストール
まずはすべての基盤となる Nix をインストールします。

```bash
curl -L https://nixos.org/nix/install | sh
```
*画面の指示に従ってEnterを押してインストールを完了してください。完了後、一度ターミナルを開き直すか、以下を実行してNixコマンドをロードします。*
```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

### Step 2: Nix Flakes 機能の有効化
設定のビルドに必要なモダン機能「Nix Flakes」および新しいNixコマンドを有効化します。

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Step 3: 設定リポジトリのクローン
この設定ファイル群を、ホームディレクトリの所定の位置に直接クローンします。

```bash
git clone https://github.com/Naruto-Takahashi/home-manager-config.git ~/.config/home-manager
```

### Step 4: Home Manager の適用（全自動インストール）
Nix Flakesの力を使って、Home Manager自体のインストール、必要なアプリのダウンロード、設定ファイルの配置、シンボリックリンクの作成を一瞬で全自動実行します。

```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager --impure
```
> [!IMPORTANT]
> `--impure`（不純許可）フラグは、実行マシンの物理グラフィックス（NVIDIAドライバ等）の情報をNixのサンドボックス内に一時的に取り込んで、WezTermやpicomのハードウェアアクセラレーションを最適にビルドするために必須のフラグです。

### Step 5: キーボードリマッパー（Kanata）の自動起動登録
カスタムキーマップのエンジンである Kanata はシステムサービスとして動くため、自動起動に登録し、今すぐ有効化させます。

```bash
systemctl --user daemon-reload
systemctl --user enable --now kanata
```

### Step 6: 新しいシェルの起動
最後に、Ubuntu標準のBashから、極上カスタマイズされたZshへと切り替えます。

```bash
exec zsh
```

---

<details>
<summary>📖 <b>English Translation (Click to expand)</b></summary>

## 🌌 Overview

This repository manages Naruto's Linux desktop environment declaratively using **Nix Flakes** and **Home Manager**. It provides a fully unified, modern, keyboard-driven development environment with premium gold (`#ffc20d`) / dark hacker-mode aesthetics.

### 📖 Detailed Configurations & Keymaps Documentation
Detailed operations and custom keymaps can be viewed in the following documents:
* 🗔 **[i3wm Keybindings & Configurations](docs/i3wm.md)**: Details on layout structure, workspace navigation, screenshots, scratchpad minimization, and auto-tiling restoration.
* ⌨️ **[Kanata Keyboard Remapping](docs/kanata.md)**: Details on SandS Vim-like spacebar navigation, Alt-key window commands, and Mac-style IME switching.
* 💻 **[WezTerm Configurations & Keybindings](docs/wezterm.md)**: Font setups, 75% uniform background transparency, dynamic tab titles, and custom Leader key (`Ctrl+Space`) bindings.
* 📝 **[Neovim Configurations & Keybindings](docs/neovim.md)**: Relative numbers, transparent editor background, `jk` escape shortcut, Zenn custom screenshot pasting macro, and robust Lazy.nvim plugin list.

---

### 🎨 Environment & Theme Showcase
* **Window Manager (`i3wm`)**: Custom Premium Gold (`#ffc20d`) / Dark Theme.
* **Terminal (`WezTerm`)**: 75% uniform background transparency, HackGen NF font, and sleek custom tab layout.
* **Shell (`Zsh`)**: Starship Prompt, smart syntax highlighting (valid in green, invalid in red), automatic `zoxide` integration, and `fzf` completion widgets.
* **Keyboard Mapper (`Kanata`)**: Mac-style Alt Tap IME switching, and **SandS (Space and Shift)** Vim-like navigation layer (`Space + HJKL/A/E/U/B/X`).
* **Compositor (`picom`)**: Configured with a robust `xrender` backend for seamless performance on NVIDIA GPUs.
* **Intelligence**: Custom auto-tiling wrapper script (`rofi_window_wrapper.py`) that instantly restores minimized scratchpad windows in tiled mode when selected via Alt+Tab.

---

## 🚀 Environment Setup & Replication Guide (PC Migration)

### ⚙️ Pre-setup Customization (If your username is different)
If your username on the new PC is different from `nalt` (e.g., `naruto`), edit the [home.nix](home.nix) file's user metadata before applying:
```nix
# home.nix
home.username      = "new_username";
home.homeDirectory = "/home/new_username";
```

### Step 1: Install the Nix Package Manager
```bash
curl -L https://nixos.org/nix/install | sh
```
*Follow the on-screen instructions. Once completed, restart your terminal or load Nix paths using:*
```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

### Step 2: Enable Nix Flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Step 3: Clone this Configuration Repository
```bash
git clone https://github.com/Naruto-Takahashi/home-manager-config.git ~/.config/home-manager
```

### Step 4: Run the First Home Manager Switch (Activation)
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager --impure
```

### Step 5: Enable Kanata User Daemon
```bash
systemctl --user daemon-reload
systemctl --user enable --now kanata
```

### Step 6: Start the Recreated Zsh Shell
```bash
exec zsh
```

</details>
