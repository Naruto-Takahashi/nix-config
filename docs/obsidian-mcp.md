# Obsidian External Brain (メダリオン構造 × 軽量 Johnny.Decimal)

**全OS共通 (WSL2 / macOS / NixOS / Distrobox)** です。[modules/services/obsidian-mcp.nix](../modules/services/obsidian-mcp.nix) および [modules/apps/claude-code/default.nix](../modules/apps/claude-code/default.nix) で管理されている、Obsidian の Vault を日常・大学・研究・開発すべての一元管理基盤および AI エージェントの「外部脳」として使う仕組みです。

---

## 1. 設計思想

1. **入り口の一本化 (`AGENTS.md`)**:
   - Vault ルートの `AGENTS.md` を唯一の入り口とし、`CLAUDE.md` は `@AGENTS.md` を参照します。
   - 詳細な手順書は `.agents/skills/obsidian-brain/SKILL.md` に格納され、`nix-config` が `~/.claude/skills/obsidian-brain/SKILL.md` と `~/.gemini/config/skills/obsidian-brain/SKILL.md` へシンボリックリンクで直結します。
2. **メダリオン3層 × 番号固定構造**:
   - GitHub でマシン間共有される領域を **`00`〜`04` の連番**、Git 管理外（`.gitignore`）の領域を **`90`番台** に分離しています。
   - **ブロンズ層 (`03-resources/`)**: 調べた記録・外部資料の原本（書き換えない一次データ）。
   - **シルバー層 (`01-knowledge/`)**: 自分に関する事実と、理解・再構成した知識（**`10`〜`16` の軽量 Johnny.Decimal 分類 ＋ 日本語タイトル**）。
   - **ゴールド層 (`02-output/`)**: 研究・開発プロジェクトや最終成果物。
3. **安全性 (`90-private/`・`91-storage/` の Git 除外 ＋ `gitleaks` 検査)**:
   - 認証情報・個人情報 (`90-private/`) や大容量ファイル (`91-storage/`)、削除代わりの退避先 (`99-trash/`) は `.gitignore` で保護されます。
   - さらに `obsidian-vault-sync`（および `_scripts/check-secrets.sh`）がコミット直前に **`gitleaks protect --staged`** を実行し、万一 `00`〜`04` に API キー等の機密情報が紛れ込んでいた場合は自動でコミットをブロックします。

---

## 2. Vault ディレクトリ構成

```text
obsidian-vault/
├── AGENTS.md                        # 唯一の入り口ファイル (CLAUDE.md は @AGENTS.md 参照)
├── .agents/skills/obsidian-brain/   # エージェントの手順書 (SKILL.md)
├── _scripts/                        # 機械で動かすスクリプト (ob.sh, sync.sh, check-secrets.sh)
│
│  === [Git管理領域: 00〜04 の連番] ===
├── 00-rules/                        # ルール・再発防止教訓 (mistakes.md)
├── 01-knowledge/                    # 【シルバー層】事実・整理した知識 (1X 大分類 × 1X.YZ 小分類 × 日本語タイトル)
│   ├── 10-self/                     #   10.11-profile / 10.21-decisions
│   ├── 11-cs-fundamentals/          #   11.11-architecture / 11.21-network / 11.31-security-theory
│   ├── 12-languages/                #   12.11-python / 12.12-nix / 12.21-cpp / 12.22-rust / 12.31-verilog
│   ├── 13-ai-security/              #   13.11-llm-dl / 13.21-hcp
│   ├── 14-devtools-infra/           #   14.11-nix-env / 14.21-neovim / 14.22-terminal-cli / 14.23-wm-input / 14.31-remote-vpn / 14.32-data-extraction / 14.41-keyboards-devices
│   ├── 15-academic-career/          #   15.11-sakurai-lab / 15.21-career-grad / 15.22-atcoder
│   └── 16-life-general/             #   16.11-routines / 16.21-tax-admin / 16.31-side-projects
├── 02-output/                       # 【ゴールド層】成果物・進行中プロジェクト (<project>/Status.md)
├── 03-resources/                    # 【ブロンズ層】調べた記録・外部資料の原本 (書き換えない)
├── 04-daily/                        # 日誌 (YYYY/MM/YYYY-MM-DD.md)・現在地 (PICKUP.md)・テンプレート (_templates/)
│
│  === [Git管理外領域 (.gitignore): 90番台] ===
├── 90-private/                      # 認証・個人情報・機密メモ (Git管理外)
├── 91-storage/                      # 大容量ファイル：動画・PDF・エクスポート原本等 (Git管理外)
└── 99-trash/                        # 削除の代わりの退避先 (Git管理外)
```

---

## 3. 専用 CLI `ob` コマンド

| コマンド | 動作 |
| :--- | :--- |
| `ob` / `ob pickup` | `04-daily/PICKUP.md` と今日の日誌を表示 |
| `ob path` | 現在の環境の Vault パスを表示 |
| `ob today [--print]` | 今日の日誌 (`04-daily/YYYY/MM/YYYY-MM-DD.md`) を生成して `$EDITOR` で開く |
| `ob memo <text...>` | 今日の日誌に `- HH:MM <text>` を1行即追記 |
| `ob journal <title> [summary...]` | 今日の日誌に AI セッション要約を追記（標準入力も可） |
| `ob note <cat> <title> [proj]` | 日本語タイトル＋フロントマター付きノートを作成 (`cat`: `10`〜`16` / `output` / `resource` / `daily` / `private`) |
| `ob search <query>` | `ripgrep` で Vault 内を高速全文検索 |
| `ob list [subdir]` | Vault 内のノート一覧を表示 |
| `ob sync` | `gitleaks` 検査付きの双方向 Git 同期を実行 |

---

## 4. 関連ファイル

| ファイル | 役割 |
| :--- | :--- |
| `<Vault>/AGENTS.md` | Vault 全体の唯一の入り口ファイル (`CLAUDE.md` は `@AGENTS.md` 参照) |
| `<Vault>/.agents/skills/obsidian-brain/SKILL.md` | 外部脳運用の手順書 (Claude Code / Antigravity 共通 Skill 正本) |
| `<Vault>/_scripts/ob.sh`, `sync.sh`, `check-secrets.sh` | `ob` CLI 本体・双方向 Git 同期・`gitleaks` 機密検査スクリプトの正本 |
| `modules/services/obsidian-mcp.nix` | `services.obsidianBrain` オプション・Nix 依存解決ラッパー・Skill 配線・自動同期タイマー |
| `modules/apps/claude-code/default.nix`, `CLAUDE.md` | `~/.claude/CLAUDE.md` の生成・Claude Code 設定 |
| `modules/apps/gemini/default.nix`, `GEMINI.md` | `~/.gemini/GEMINI.md` の生成・Antigravity CLI / Gemini CLI 設定 |
