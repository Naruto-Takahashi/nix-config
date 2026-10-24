# Yazi 設計・拡張機能・操作ガイド

このドキュメントでは，[modules/cli/yazi/default.nix](../modules/cli/yazi/default.nix) で管理されている Rust 製高速ファイラー **Yazi** の独自拡張，配色連携，および代表的な操作について解説します．

> [!TIP]
> **内蔵ヘルプ機能**:
> Yazi の画面上で **`~`** を押すと，現在利用可能な全キーバインド一覧がポップアップ表示されます．

---

## 1. 本環境の基本特徴

* **シェル CWD 連携 (`ya` / `yazi`)**:
  - `enableZshIntegration = true` により，Yazi を終了（`q`）すると，**Yazi 内で開いていたディレクトリへ自動的にシェルのカレントディレクトリが移動**します（CWDを更新せず終了したい場合は `Q`）．
* **Kanagawa Dragon & Matugen 動的配色**:
  - 既定は `kanagawa-dragon` フレーバー．壁紙配色（Matugen）実行時は，フォルダ色・ファイル種別・ステータスバーが自動連動します．
  - ステータスバーのグラデーション配色は，Neovim と共通の [`modules/theming/lib/blend.lua`](../modules/theming/lib/blend.lua) による 2 色補間で描画されます．
* **リッチプレビュー (`rich-preview`)**:
  - Markdown, CSV, JSON, Jupyter Notebook は `rich-cli` を通じて装飾付きで美麗にレンダリング表示されます．

---

## 2. 独自拡張・プラグイン操作チートシート

### アーカイブ圧縮・解凍 (compress.yazi / ouch.yazi)
| キーバインド | 動作内容 |
| :--- | :--- |
| **`c` `a` `a`** | 選択中のファイル / ディレクトリを zip 圧縮 |
| **`c` `a` `p`** | パスワード付きでアーカイブ圧縮 |
| **`Enter`** (アーカイブ上) | `ouch` を呼び出し，その場にアーカイブを展開・解凍 |

### ディレクトリジャンプ (zoxide)
| キーバインド | 動作内容 |
| :--- | :--- |
| **`c` `d`** / **`Z`** | Zsh と共有している `zoxide` の移動履歴から，fzf 絞り込みで素早くジャンプ |

### クリップボード・パス取得
| キーバインド | 動作内容 |
| :--- | :--- |
| **`y` `n`** | 選択ファイルの**ファイル名**をクリップボードにコピー |
| **`y` `p`** | 選択ファイルの**絶対パス**をクリップボードにコピー |
| **`y` `d`** | 選択ファイルが属する**親ディレクトリパス**をクリップボードにコピー |

### 基本ナビゲーション (Vim ライク)
| キーバインド | 動作内容 |
| :--- | :--- |
| **`h` / `j` / `k` / `l`** | 親へ戻る / 下 / 上 / 入る（ファイルを開く） |
| **`Space`** / **`v`** | 1件選択 / ビジュアル範囲選択 |
| **`a`** | 新規作成（末尾に `/` を付けるとディレクトリ作成） |
| **`r`** | ファイル名変更（リネーム） |
| **`d`** / **`D`** | ゴミ箱へ送る / 完全削除 |
| **`J`** / **`K`** | プレビュー画面のスクロール (下 / 上) |

---

## 3. 関連ファイル

| パス | 役割 |
| :--- | :--- |
| [`modules/cli/yazi/default.nix`](../modules/cli/yazi/default.nix) | Yazi 本体定義・プラグイン設定・キーマップ割り当て |
| [`modules/cli/yazi/init.lua`](../modules/cli/yazi/init.lua) | UI レイアウト・ステータスバー・配色ロジック |
| [`modules/cli/yazi/theme-template.toml`](../modules/cli/yazi/theme-template.toml) | Matugen 動的配色のプレースホルダーテンプレート |
| [`modules/theming/lib/blend.lua`](../modules/theming/lib/blend.lua) | ステータスバーグラデーション描画用の色補間ライブラリ |
