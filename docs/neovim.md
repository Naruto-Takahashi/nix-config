# Neovim 設計・主要プラグイン・操作ガイド

このドキュメントでは，[modules/cli/neovim/default.nix](../modules/cli/neovim/default.nix) で宣言管理されている Neovim の基本設計方針，独自マクロ，および主要なキー操作のエッセンスについて解説します．

> [!TIP]
> **カンニングペーパー機能 (`which-key.nvim`)**:
> スペースキー（`<Leader>`）を押して一瞬待つと，画面下部に次に押せるキーバインドと説明が一覧表示されます．詳細なキーマップはエディタ内で直接確認可能です．

---

## 1. 基本設計方針 (Core Design)

設定の実体は [`modules/cli/neovim/nvim/`](../modules/cli/neovim/nvim/) にあり，`mkOutOfStoreSymlink` により `~/.config/nvim` に直結されています（`switch` 不要で編集即時反映）．

* **スペースLeader**: `<Leader>` = `Space`
* **インサート脱出**: **`jk`**（ホームポジションを崩さずにNormalモードへ復帰）
* **クリップボード同期**: `clipboard = unnamedplus`（OSシステムクリップボードと自動同期）
* **背景透過とテーマ連携**:
  - メイン配色は **Kanagawa Dragon**，動的壁紙配色時は **Matugen** に追従します．
  - `ColorScheme` イベントにより，エディタ背景・フローティング窓・サインコラムを完全透過（`none`）し，WezTerm の透過背景と調和させます．
* **Treesitter パーサーの Nix 管理**:
  - C/C++ 等のコンパイル環境に依存せず高速かつ正確な構文解析を行うため，主要パーサーの `.so` は Nix 側でビルド済み共有ライブラリとして配置しています．

---

## 2. 独自カスタムマクロ・コマンド

Lua で独自実装された，開発・執筆を高速化するオリジナル機能です（[`vim-options.lua`](../modules/cli/neovim/nvim/lua/vim-options.lua)）．

| キーバインド / コマンド | 機能 | 動作内容 |
| :--- | :--- | :--- |
| **`<Leader>ip`** | **画像貼り付け** | クリップボード内の画像を保存し，現在編集中の Markdown に相対リンク `![](...)` を自動挿入 |
| **`<Leader>th`** / **`:ToHtmlSave`** | **コードHTML保存** | 現在のシンタックスハイライトを維持したまま HTML ファイルとして同階層にエクスポート |

---

## 3. 主要操作チートシート

### ウィンドウ・バッファ操作
| キーバインド | 動作内容 |
| :--- | :--- |
| **`Ctrl + H/J/K/L`** | 左 / 下 / 上 / 右のウィンドウへフォーカス移動 |
| **`Tab`** / **`Shift + Tab`** | 右 / 左のバッファタブへ切り替え ([heirline.nvim](../modules/cli/neovim/nvim/lua/plugins/heirline-tabline.lua)) |
| **`Q`** / **`<Leader>bd`** | 現在のバッファタブを閉じる |
| **`<Leader>bo`** | 現在のバッファ以外をすべて閉じる |

### 検索・ファイル操作
| キーバインド | 動作内容 | プラグイン |
| :--- | :--- | :--- |
| **`<Leader>ff`** / **`fg`** | ファイル名検索 / 全文検索 (grep) | [telescope.nvim](../modules/cli/neovim/nvim/lua/plugins/telescope.lua) |
| **`<Leader>e`** | ファイルツリー表示切り替え | [neo-tree.nvim](../modules/cli/neovim/nvim/lua/plugins/neo-tree.lua) |
| **`s`** | 画面内ジャンプ (ラベル指定で瞬間移動) | [flash.nvim](../modules/cli/neovim/nvim/lua/plugins/flash.lua) |
| **`<Leader>qs`** / **`ql`** | セッション復元 / 前回復元 | [persistence.nvim](../modules/cli/neovim/nvim/lua/plugins/persistence.lua) |

### Git 連携 (住み分け)
Neovim 内で Git 操作を完結させるため，用途別に4つのツールを使い分けています．

| ツール | キーバインド | 主な用途 |
| :--- | :--- | :--- |
| **Lazygit** | **`<Leader>lg`** | フローティング TUI による Git 操作全般 (ステージ・コミット・プッシュ) |
| **gitsigns** | **`]c`** / **`[c`**, **`<Leader>hs`** | エディタ内での Hunk（差分行）ジャンプ・部分ステージ |
| **diffview** | **`<Leader>ld`** / **`lh`** / **`lc`** | 2ペインでの本格差分レビュー・ファイル履歴閲覧 |
| **octo** | **`<Leader>gp`** / **`gi`** | GitHub PR・Issue の一覧閲覧・作成・インラインレビュー |

---

## 4. 関連ファイル

| パス | 役割 |
| :--- | :--- |
| [`modules/cli/neovim/default.nix`](../modules/cli/neovim/default.nix) | Nix パッケージ定義・LSP / フォーマッタ配置・パーサーリンク |
| [`modules/cli/neovim/nvim/init.lua`](../modules/cli/neovim/nvim/init.lua) | Lazy.nvim ブートストラップ・プラグイン読み込み |
| [`modules/cli/neovim/nvim/lua/vim-options.lua`](../modules/cli/neovim/nvim/lua/vim-options.lua) | 基本オプション・独自マクロ定義 |
| [`modules/cli/neovim/nvim/lua/plugins/`](../modules/cli/neovim/nvim/lua/plugins/) | 各プラグインの設定 |
| [`modules/cli/neovim/nvim/lua/matugen.lua`](../modules/cli/neovim/nvim/lua/matugen.lua) | Matugen 動的配色のフォールバックパレット |
