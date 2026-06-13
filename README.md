# 🌌 Naruto's Declarative Desktop Configuration (Nix + Home Manager)

このリポジトリは、**Nix Flakes** と **Home Manager** を使用して、Linuxデスクトップ（Ubuntu）環境およびWSL環境を宣言的に一元管理するための設定ファイル群（レシピ）です。
ゴールド（`#ffc20d`）とダークテーマを基調とした、美しく、キーボード駆動で圧倒的な生産性を誇る「極上のハッカー向け開発環境」を構築します。

---

## 📖 設定・キーマップの詳細解説 (Detailed Documentation)

デスクトップの操作方法やキーマップの詳細は、以下の各個別ドキュメントから詳細にご確認いただけます。

* 🗔 **[i3wm キーバインド・設定詳細](docs/i3wm.md)** (Desktopのみ): 画面のレイアウト、ワークスペース切り替え、スクリーンショット、最小化・オートタイル復元の詳細。
* 🗔 **[GlazeWM キーバインド・設定詳細](docs/glazewm.md)** (WSLのみ/Windows側): Windows環境におけるタイル型ウィンドウ操作、Zebar連携、一時停止モードの詳細。
* ⌨️ **[Kanata キーマップ詳細](docs/kanata.md)** (Desktopのみ): スペースキー長押しによるVimライク移動、Altキーによるウィンドウ操作・Mac風IME切り替えの詳細。
* 💻 **[WezTerm 設定・キーバインド詳細](docs/wezterm.md)**: フォント、背景の75%半透明適用、動的タブタイトル、Leaderキー（`Ctrl+Space`）によるタブ・ペイン管理。
* 📝 **[Neovim 設定・キーマップ詳細](docs/neovim.md)**: 相対行表示や透過背景設定、`jk` によるインサート抜け、Zenn用画像貼り付けなどの高度なLuaカスタムマクロ。
* 📁 **[Yazi 設定・使い方詳細](docs/yazi.md)**: Cyberdreamテーマカスタマイズ・透過設定、Vim風キーバインド全一覧、シェル統合によるディレクトリ移動連携。
* 🌐 **[Chrome Remote Desktop 設定詳細](docs/chrome-remote-desktop.md)**: 自宅から研究室PCへセキュアにアクセスするための、Google経由のリモートデスクトップ設定手順。

---

## 🎨 環境・機能のこだわり紹介 (Showcase)

* **ウィンドウマネージャー (`i3wm` / `GlazeWM`)**: Linux Desktopでの `i3wm` と、WSL使用時のWindows側での `GlazeWM` の両環境で、ゴールドとダークな色調で美しく統一されたタイル型ウィンドウ環境を構築。
* **ターミナル (`WezTerm`)**: 不透明度75%の美しい半透明背景。フォントには「HackGen NF」を適用し、上部タブバーも本体と同じ透過率に完璧に調和。
* **シェル (`Zsh`)**: Starship プロンプトをベースに、コマンドの有効/無効をリアルタイム色分け（緑/赤）する構文ハイライト、`zoxide` によるディレクトリ超高速移動、`fzf` による履歴検索を完備。
* **キーマップ管理 (`Kanata`)** (Desktopのみ): 左右Alt単押しでのIME（日本語/英語）切り替えに加え、**SandS（Space and Shift）**の思想を継承した「スペース長押しナビゲーションレイヤー」を搭載（`Space + HJKL/A/E/U/B/X` でカーソル移動・Undo・Backspace・Deleteが可能）。
* **グラフィックス (`picom`)** (Desktopのみ): X11コンポジタ。NVIDIAグラフィックス環境でも100%クラッシュせず極めて軽量に動作する `xrender` バックエンドを採用。
* **オートタイル復元** (Desktopのみ): 最小化（Scratchpad退避）したウィンドウを `ALT+TAB`（Rofi）で復元した際、手動でトグルせずとも自動的にタイリング表示へと瞬時に再配置する独自のラッパースクリプト（`rofi_window_wrapper.py`）を搭載。

---

## 🚀 新しいPCで環境を完全再現する手順（PC移行ガイド）

新しく環境を構築、またはクリーンインストールした別のPCに、この環境をそのまま100%復元するためのセットアップ手順です。

### ⚙️ 事前の微調整（新しいPCのユーザー名が異なる場合）
新しいPCのユーザー名が `nalt` 以外（例: `naruto`）の場合は、リポジトリをクローン後、適用する環境に応じた以下のファイルのユーザーメタデータを事前に書き換えてください。
* **対象ファイル**: `home-desktop.nix` (Desktop用) または `home-wsl.nix` (WSL用) （どちらも22〜23行目付近）
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
Nix Flakesの力を使って、Home Manager自体のインストール、必要なアプリのダウンロード、設定ファイルの配置、シンボリックリンクの作成を一瞬で全自動実行します。構築する環境に合わせてプロファイルを選択して実行してください。

**Ubuntu デスクトップ環境の場合 (`nalt-desktop`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-desktop --impure
```

**WSL 環境の場合 (`nalt-wsl`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-wsl --impure
```

> [!IMPORTANT]
> `--impure`（不純許可）フラグは、実行マシンの物理グラフィックス（NVIDIAドライバ等）の情報をNixのサンドボックス内に一時的に取り込んで、WezTermやpicomのハードウェアアクセラレーションを最適にビルドするために必須のフラグです。

### Step 5: キーボードリマッパー（Kanata）の自動起動登録 (Desktop環境のみ)
カスタムキーマップのエンジンである Kanata はシステムサービスとして動くため、自動起動に登録し、今すぐ有効化させます（WSL環境では不要です）。

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

## 🖥️ リモートアクセス環境の構築

自宅の Windows ノート PC 等から研究室の Ubuntu デスクトップに安全・快適にアクセスするための手順です。

### 1. Chrome Remote Desktop (推奨)

Google 経由で最も簡単に、かつ高画質・低遅延でアクセスできる方法です。i3wm のセッション設定や動的フォントスケーリングにも対応しています。

#### ホスト PC (Ubuntu) 側での準備
1. **本体のインストールとグループ追加**:
   ```bash
   wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
   sudo apt install ./chrome-remote-desktop_current_amd64.deb
   sudo usermod -a -G chrome-remote-desktop $USER
   ```
2. **Nix 設定の適用**:
   本リポジトリの設定を適用すると、`~/.chrome-remote-desktop-session` が自動生成され、リモート接続時に i3wm が適切な設定（DPI 96, コンパクトフォント）で起動するようになります。
   ```bash
   home-manager switch --flake .#nalt-desktop --impure
   ```
3. **リモートアクセスの有効化**:
   [Chrome Remote Desktop (Headless)](https://remotedesktop.google.com/headless) にアクセスし、指示に従ってコマンドを実行・PIN を設定してください。

#### Windows クライアント側でのコツ
- **アプリ化**: ブラウザのタブではなく PWA（アプリ）としてインストールすると、`Alt+Tab` 等の競合が減り快適になります。
- **全画面表示**: CRD のサイドメニューから「全画面表示」と「システムのショートカットキーを送信」をオンにしてください。
- **キーバインド**: リモート時は `Win` (Super) キーが奪われやすいため、`Alt` (Mod1) を使った代替バインド（`Alt+Enter` でターミナル等）も活用してください。

---

### 2. XRDP (SSHトンネル経由)

Windows 標準のリモートデスクトップ接続 (mstsc) を使用する方法です。
ターミナルで以下のコマンドを実行し、必要なサービスをインストール・有効化し、自動スリープを防止します。

```bash
# 1. XRDP & SSH サーバーのインストール
sudo apt update
sudo apt install xrdp openssh-server -y

# 2. 各サービスの自動起動と起動
sudo systemctl enable --now xrdp ssh

# 3. 自動スリープ（サスペンド）の完全無効化（再起動後も永続）
sudo systemctl mask suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

### 2. Nix（Home Manager）設定の適用
本設定ファイルを適用して、リモートデスクトップ接続時用の `~/.xsession` や、接続時専用のDPIスケーリング（192 DPI = 2倍拡大）およびブラウザ（Vivaldi）の多重起動用プロファイル分離ラッパーを有効化します。

```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-desktop --impure
```
*適用後、i3wm上で `Super + Shift + r` を押してリロードします。*

### 3. WindowsノートPCからの接続手順
1. Windows側でコマンドプロンプトまたはPowerShellを開き、SSHトンネル（ポート転送）を実行します。
   ```cmd
   ssh -L 33890:localhost:3389 nalt@<UbuntuのIPアドレス>
   ```
   *※このターミナルウィンドウは、接続している間は閉じずに開いたままにしてください。*
2. `Win + R` キーを押し、`mstsc` と入力してエンターを押し、**「リモートデスクトップ接続」**を開きます。
3. コンピューター名に **`localhost:33890`** と入力して接続します。
4. ログイン画面でユーザー名 `nalt` とパスワードを入力すると、リモート側に適した解像度・操作感で `i3wm` が起動します。

---

---

<details>
<summary>📖 <b>English Translation (Click to expand)</b></summary>

## 🌌 Overview

This repository manages Naruto's Linux desktop (Ubuntu) and WSL environments declaratively using **Nix Flakes** and **Home Manager**. It provides a fully unified, modern, keyboard-driven development environment with premium gold (`#ffc20d`) / dark hacker-mode aesthetics.

### 📖 Detailed Configurations & Keymaps Documentation
Detailed operations and custom keymaps can be viewed in the following documents:
* 🗔 **[i3wm Keybindings & Configurations](docs/i3wm.md)** (Desktop only): Details on layout structure, workspace navigation, screenshots, scratchpad minimization, and auto-tiling restoration.
* 🗔 **[GlazeWM Keybindings & Configurations](docs/glazewm.md)** (WSL only/Windows side): Details on Windows tiling window management, Zebar status bar integration, and configuration bypass via Pause mode.
* ⌨️ **[Kanata Keyboard Remapping](docs/kanata.md)** (Desktop only): Details on SandS Vim-like spacebar navigation, Alt-key window commands, and Mac-style IME switching.
* 💻 **[WezTerm Configurations & Keybindings](docs/wezterm.md)**: Font setups, 75% uniform background transparency, dynamic tab titles, and custom Leader key (`Ctrl+Space`) bindings.
* 📝 **[Neovim Configurations & Keybindings](docs/neovim.md)**: Relative numbers, transparent editor background, `jk` escape shortcut, Zenn custom screenshot pasting macro, and robust Lazy.nvim plugin list.
* 📁 **[Yazi File Manager — Configuration & Usage](docs/yazi.md)**: Cyberdream theme customization, transparency settings, full Vim-style keybinding reference, and shell integration for seamless directory navigation.

---

### 🎨 Environment & Theme Showcase
* **Window Manager (`i3wm` / `GlazeWM`)**: Custom Premium Gold (`#ffc20d`) / Dark Theme setup. It configures `i3wm` for the Linux Desktop environment and `GlazeWM` on the Windows host side when running in WSL.
* **Terminal (`WezTerm`)**: 75% uniform background transparency, HackGen NF font, and sleek custom tab layout.
* **Shell (`Zsh`)**: Starship Prompt, smart syntax highlighting (valid in green, invalid in red), automatic `zoxide` integration, and `fzf` completion widgets.
* **Keyboard Mapper (`Kanata`)** (Desktop only): Mac-style Alt Tap IME switching, and **SandS (Space and Shift)** Vim-like navigation layer (`Space + HJKL/A/E/U/B/X`).
* **Compositor (`picom`)** (Desktop only): Configured with a robust `xrender` backend for seamless performance on NVIDIA GPUs.
* **Intelligence** (Desktop only): Custom auto-tiling wrapper script (`rofi_window_wrapper.py`) that instantly restores minimized scratchpad windows in tiled mode when selected via Alt+Tab.

---

## 🚀 Environment Setup & Replication Guide (PC Migration)

### ⚙️ Pre-setup Customization (If your username is different)
If your username on the new PC is different from `nalt` (e.g., `naruto`), edit the user metadata in the configuration file corresponding to your environment before applying:
* **Target File**: `hosts/desktop/default.nix` (for Desktop) or `hosts/wsl/default.nix` (for WSL)
```nix
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
Choose the profile that matches your target environment.

**For Ubuntu Desktop environment (`nalt-desktop`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-desktop --impure
```

**For WSL environment (`nalt-wsl`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-wsl --impure
```

> [!IMPORTANT]
> The `--impure` flag is required because it allows Nix to temporarily query the hardware/driver environment (such as NVIDIA drivers) of the host system to correctly build/configure graphics-accelerated applications like WezTerm and picom.

### Step 5: Enable Kanata User Daemon (Desktop only)
Since Kanata (the keyboard remapper) runs as a user-level service, enable it so it starts automatically (not needed for WSL):
```bash
systemctl --user daemon-reload
systemctl --user enable --now kanata
```

### Step 6: Start the Recreated Zsh Shell
```bash
exec zsh
```

</details>
 environment (`nalt-desktop`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-desktop --impure
```

**For WSL environment (`nalt-wsl`)**:
```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager#nalt-wsl --impure
```

> [!IMPORTANT]
> The `--impure` flag is required because it allows Nix to temporarily query the hardware/driver environment (such as NVIDIA drivers) of the host system to correctly build/configure graphics-accelerated applications like WezTerm and picom.

### Step 5: Enable Kanata User Daemon (Desktop only)
Since Kanata (the keyboard remapper) runs as a user-level service, enable it so it starts automatically (not needed for WSL):
```bash
systemctl --user daemon-reload
systemctl --user enable --now kanata
```

### Step 6: Start the Recreated Zsh Shell
```bash
exec zsh
```

</details>
