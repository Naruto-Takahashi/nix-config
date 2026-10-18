# Obsidian External Brain v2 (外部脳連携)

**全OS共通 (WSL2 / macOS / NixOS / Distrobox)** です。[modules/services/obsidian-mcp.nix](../modules/services/obsidian-mcp.nix) および [modules/apps/claude-code/default.nix](../modules/apps/claude-code/default.nix) で管理されている、Obsidian の Vault を日常・研究・開発すべての一元管理基盤および AI エージェントの「外部脳」として使う仕組みです。

---

## アーキテクチャ (v2: 自己完結型 Vault ＋ 軽量 OS 配線)

従来の Node.js MCP サーバー (`@bitbonsai/mcpvault`) や専用起動ラッパー (`agy-brain` / `gemini-brain`) を廃止し、**「自己完結型 Vault リポジトリ ＋ AI 標準ファイル操作 ＋ 共通 Skill ＋ 軽量 CLI `ob`」** の構成に刷新しています。

1. **責務の分離 (`obsidian-vault` vs `nix-config`)**:
   - **`obsidian-vault` リポジトリ側 (データ ＋ 自己記述スキーマ)**:
     - ルートに `AGENTS.md` / `CLAUDE.md`、詳細規約として `.agents/skills/obsidian-brain/SKILL.md` を保持。
     - リポジトリ単体でルールとディレクトリ仕様が完結しているため、ローカル CLI エージェントだけでなく **Web チャット (Claude.ai / ChatGPT の GitHub コネクタや Claude Code Web)** から接続した際にも全く同じルールで参照・編集できる。
   - **`nix-config` リポジトリ側 (OS インフラ・配線のみ)**:
     - `~/.claude/CLAUDE.md` と `~/.gemini/GEMINI.md` を単一ソースから宣言的に生成。
     - `~/.claude/skills/obsidian-brain/SKILL.md` と `~/.gemini/config/skills/obsidian-brain/SKILL.md` を Vault 内の `SKILL.md` へ out-of-store シンボリックリンクで直結（Vault 側でルールを書き換えると `home-manager switch` 不要で即時反映）。
     - 専用 CLI `ob` と、30分おきの双方向 Git 自動同期タイマー (`obsidian-vault-sync`) を提供。

2. **OS ごとの Vault パス (`services.obsidianBrain.vaultPath`)**:
   - **WSL2**: `/mnt/c/Users/tnaru/Obsidian/Vault`（Windows 側の Obsidian デスクトップアプリが直接開くパス）
   - **macOS / NixOS / Distrobox**: `~/ghq/github.com/Naruto-Takahashi/obsidian-vault`
   - 環境変数 `$OBSIDIAN_VAULT_PATH`（または `ob path`）でどの OS でも透過的に参照できる。

3. **双方向 Git 自動同期 (`obsidian-vault-sync`)**:
   - Linux / WSL では `systemd --user` タイマー (`obsidian-vault-sync.timer`)、macOS では `launchd.agents.obsidian-vault-sync` が30分おきに起動。
   - `git pull --rebase --autostash` → `git add -A` → `git commit` → `git push` を自動実行するため、Web チャット（GitHub 経由）や別 OS から書き込んだ内容も自動でローカル Vault に取り込まれる。

---

## Vault ディレクトリ構成（6フォルダ・ゼロ迷い設計）

| ディレクトリ | 役割 |
| :--- | :--- |
| `00_Inbox/` | 分類に迷う思いつき・一時メモを即座に放り込む場所 |
| `01_Daily/` | **1日1ファイル (`YYYY/MM/YYYY-MM-DD.md`)**。日常メモ・ToDo・AI セッション要約を時系列集約（Obsidian デイリーノートと完全一致） |
| `02_Projects/` | 明確なゴールがある研究・開発プロジェクト (`<repo-name>/Status.md`) |
| `03_Areas/` | 終わりがない継続的な日常・大学・生活領域 (`university-lab.md`, `life-routines.md` 等) |
| `04_Knowledge/` | `mistakes.md`（再発防止教訓）、`Tech/`（技術知見）、`Decisions/`（設計判断） |
| `05_Meta/` | `PICKUP.md`（AI が最初に読む現在地ダッシュボード）、`profile.md`（ユーザー情報）、`Templates/` |

---

## 専用 CLI `ob` コマンド

AI エージェントおよび人間がターミナルから高速に Vault を操作するための CLI です。

| コマンド | 動作 |
| :--- | :--- |
| `ob` / `ob pickup` | `05_Meta/PICKUP.md` と今日のデイリーノートを表示 |
| `ob path` | 現在の環境の Vault パスを表示 |
| `ob today [--print]` | 今日のデイリーノート (`01_Daily/YYYY/MM/YYYY-MM-DD.md`) を生成して `$EDITOR` で開く（`--print` で標準出力） |
| `ob memo <text...>` | 今日のデイリーノートに `- HH:MM <text>` を1行即追記 |
| `ob journal <title> [summary...]` | 今日のデイリーノートに AI セッション要約を追記（標準入力も可） |
| `ob note <type> <slug> <title> [proj]` | 規約フロントマター付きノートを作成 (`type`: `tech` / `decision` / `project` / `area` / `inbox`) |
| `ob search <query>` | `ripgrep` で Vault 内を高速全文検索 |
| `ob list [subdir]` | Vault 内のノート一覧を表示 |
| `ob sync` | 手動で即座に双方向 Git 同期を実行 |

---

## 関連ファイル

| ファイル | 役割 |
| :--- | :--- |
| `modules/services/obsidian-mcp.nix` | `services.obsidianBrain` オプション定義・`ob` CLI・Skill シンボリックリンク・自動同期タイマー |
| `modules/apps/claude-code/default.nix` | `~/.claude/CLAUDE.md` と `~/.gemini/GEMINI.md` の単一ソース生成 |
| `modules/apps/claude-code/CLAUDE.md` | 全 AI エージェント共通のグローバルベース指示 |
