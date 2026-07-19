# 🧰 CLI ユーティリティ 使い方チートシート

`profiles/base.nix` で全ホスト共通に導入している小物 CLI/TUI ツールの基本操作集です。
atuin / btop / tealdeer の配色は Matugen 連携 (壁紙由来 + kanagawa-dragon フォールバック) です ([matugen-palette.md](matugen-palette.md) 参照)。

---

## 🔍 atuin — シェル履歴の検索・記録

`Ctrl+R` が atuin の全文検索 UI に置き換わっています。**↑キーは従来の zsh 履歴のまま**です。

| 操作 | 動作 |
| :--- | :--- |
| **`Ctrl+R`** | 履歴検索 UI を開く (fuzzy 検索。打つだけで絞り込み) |
| **`↑` / `↓`** | 候補の移動 |
| **`Enter`** | 選択したコマンドを即実行 |
| **`Tab`** | 実行せずプロンプトに挿入 (編集してから実行したいとき) |
| **`Ctrl+R` (UI 内)** | フィルタ切替 (global → host → session → directory) |
| **`Esc`** | 閉じる |

- 実行ディレクトリ・終了コード・所要時間も記録されます
- `atuin stats` でよく使うコマンドの統計が見られます
- フィルタの「directory」は「今のディレクトリで実行したものだけ」— 特定プロジェクトの履歴を掘るのに便利
- レイアウトは検索バー上・結果下 (`invert = true`)。キーヘルプとプレビュー行は非表示
- 配色は fzf (ghq 検索等) と同じ文法: 選択行 = accent 太字 (fzf のポインタ相当)、検索一致文字 = fzf の hl と同色 (matugen tertiary)
- 実行時間列 (例: `20ms`) は成功=緑・失敗=赤 (zsh syntax-highlighting と同じ固定色)。隣の `◯m ago` は「いつ実行したか」で matugen の tertiary 色
- 注: atuin v18 は本来「失敗した実行時間」と「選択行」が同じ色スロットを共有するため、`modules/patches/atuin-separate-selection-color.patch` で選択行を別スロット (Important) に分離している (atuin はソースから再ビルドされる)

## 📖 tealdeer (tldr) — コマンドの使用例を引く

| コマンド | 動作 |
| :--- | :--- |
| **`tldr <コマンド>`** | よく使う実用例を数行で表示 (例: `tldr tar`) |
| **`tldrj <コマンド>`** | 日本語訳ページで表示 (コミュニティ翻訳。無いページは英語のまま) |
| **`tldr --list`** | ページがあるコマンドの一覧 |

- キャッシュは自動更新 (`auto_update`) なので手動の `tldr --update` は不要
- 細かいオプションの正確な仕様は従来どおり `man <コマンド>` で

## 📁 fd — find の現代版

| コマンド | 動作 |
| :--- | :--- |
| **`fd <パターン>`** | カレント以下を再帰検索 (`.gitignore` を自動で尊重) |
| **`fd -e md`** | 拡張子で絞る (.md ファイルだけ) |
| **`fd -H <パターン>`** | 隠しファイルも含める |
| **`fd <パターン> /path`** | 検索場所を指定 |
| **`fd -x <cmd> {}`** | ヒットした各ファイルにコマンド実行 (例: `fd -e log -x rm {}`) |

## 🎨 delta — git diff の美しい表示

インストールするだけで `git diff` / `git log -p` / `lazygit` の差分がシンタックスハイライト付きになります (`~/.gitconfig` の `core.pager` が delta を指定済み)。

| 操作 | 動作 |
| :--- | :--- |
| **`n` / `N`** | (ページャ内) 次 / 前のファイルへジャンプ (`navigate` 有効) |
| **`git diff --no-pager`** | 素の diff が欲しいとき |

## 📊 btop — システムモニタ

`btop` で起動。CPU / メモリ / ネットワーク / プロセスを一望できます。

| 操作 | 動作 |
| :--- | :--- |
| **`j` / `k`** | プロセス選択の上下移動 (vim_keys 有効) |
| **`f`** | プロセス名でフィルタ |
| **`t`** | ツリー表示切替 |
| **`+` / `-`** | 選択プロセスの詳細を開閉 |
| **`k`(詳細内) / `T`** | プロセスを kill / terminate |
| **`m` / `1`〜`4`** | 表示ボックスのプリセット切替 / 個別トグル |
| **`Esc`** | メニュー (オプション・テーマ等) |
| **`q`** | 終了 |

- テーマは `matugen` 固定 (壁紙変更で自動追従)。アプリ内でテーマを変えても次の home-manager 適用では戻らないが、`btop.conf` は書き換え可能なので他のアプリ内設定は自由に保存できる

## ⌨️ smassh — タイピング練習

`smassh` で起動する MonkeyType 風タイピング練習 TUI。

| 操作 | 動作 |
| :--- | :--- |
| **`Ctrl+L`** | 言語パレット (↑/↓で合わせた瞬間に即適用・**Enter 不要**、`Esc` で閉じる) |
| **`Ctrl+T`** | テーマパレット (同上) |
| **`Ctrl+S`** | 設定画面 |
| **`Tab`** | テスト再スタート |
| **`Ctrl+C`** | 終了 |

- 言語パックは `smassh add <名前>` で MonkeyType のパック名を指定して追加 (ユーザーデータ扱いで Nix 管理外)

---

## 🛠️ 関連ファイル

| ファイル | 役割 |
| :--- | :--- |
| `profiles/base.nix` | 各ツールの導入宣言・atuin 設定・テーマのシード処理 |
| `modules/theming/matugen/templates/{atuin-theme.toml,btop.theme}` | Matugen テンプレート (@@KEY@@ 置換) |
| `modules/theming/matugen/fallbacks/` | kanagawa-dragon フォールバックテーマ |
| `modules/theming/matugen/lib/tealdeer-config.py` | tealdeer 用配色生成 (hex→rgb 変換) |
| `modules/shell/zsh/default.nix` | `tldrj` エイリアス定義 |
