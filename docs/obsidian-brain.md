# Obsidian External Brain (メダリオン構造 × 軽量 Johnny.Decimal)

**全OS共通 (WSL2 / macOS / NixOS / Distrobox)** です。[modules/services/obsidian-brain.nix](../modules/services/obsidian-brain.nix) および [modules/ai/claude-code/default.nix](../modules/ai/claude-code/default.nix) で管理されている、Obsidian の Vault を日常・大学・研究・開発すべての一元管理基盤および AI エージェントの「外部脳」として使う仕組みです。

---

## 1. 設計思想

1. **入り口の一本化 (`AGENTS.md`)**:
   - Vault ルートの `AGENTS.md` を唯一の入り口とし、`CLAUDE.md` は `@AGENTS.md` を参照します。
   - 詳細な手順書は `.agents/skills/obsidian-brain/SKILL.md` に格納され、`nix-config` が `~/.claude/skills/obsidian-brain/SKILL.md` と `~/.gemini/config/skills/obsidian-brain/SKILL.md` へシンボリックリンクで直結します。
2. **メダリオン3層 × Johnny.Decimal**:
   - 最上位フォルダは Johnny.Decimal の領域として10刻みの番号を持ちます。GitHub でマシン間共有される領域は `00`〜`40`、Git 管理外（`.gitignore`）の領域は **`90`番台** です。
   - **ブロンズ層 (`30-resources/`)**: 調べた記録・外部資料の原本（書き換えない一次データ）。
   - **シルバー層 (`10-knowledge/`)**: 自分に関する事実と、理解・再構成した知識（**分類 `11`〜`17` × ID `1X.YZ` ＋ 日本語タイトル**。ノート間のリンクはファイル名だけで書く）。
   - **ゴールド層 (`20-output/`)**: 研究・開発プロジェクトや最終成果物。
3. **安全性 (`90-local/` の Git 除外 ＋ `gitleaks` 検査)**:
   - 領域 `90-local/` の認証情報・個人情報 (`91-private/`)、大容量ファイル (`92-storage/`)、削除代わりの退避先 (`99-trash/`) は `.gitignore` で保護されます。
   - さらに `obsidian-vault-sync`（および `_scripts/check-secrets.sh`）がコミット直前に **`gitleaks protect --staged`** を実行し、万一 Git 管理領域に API キー等の機密情報が紛れ込んでいた場合は自動でコミットをブロックします。

---

## 2. Vault ディレクトリ構成

```text
obsidian-vault/
├── AGENTS.md                        # 唯一の入り口ファイル (CLAUDE.md は @AGENTS.md 参照)
├── .agents/skills/obsidian-brain/   # エージェントの手順書 (SKILL.md)
├── _scripts/                        # 機械で動かすスクリプト (ob.sh, sync.sh, check-secrets.sh)
│
│  === [Git管理領域: 00〜40 の領域] ===
├── 00-rules/                        # 運用ルールの正本 (行動原則・キュレーション・記述規約・教訓)
├── 10-knowledge/                    # 【シルバー層】事実・整理した知識 (分類 1X × ID 1X.YZ × 日本語タイトル。一覧の正本は Vault の AGENTS.md §2)
│   ├── 11-self/  12-cs-fundamentals/  13-languages/  14-ai-security/
│   └── 15-devtools-infra/  16-academic-career/  17-life-general/
├── 20-output/                       # 【ゴールド層】成果物・進行中プロジェクト (<project>/Status.md)
├── 30-resources/                    # 【ブロンズ層】調べた記録・外部資料の原本 (<project>/ か 1X-<分類>/ に置く。書き換えない)
├── 40-daily/                        # 日誌 (YYYY/MM/YYYY-MM-DD.md)・現在地 (PICKUP.md)・テンプレート (_templates/)
│
│  === [Git管理外領域 (.gitignore): 領域 90] ===
└── 90-local/                        # 領域 90-99 (Git管理外)
    ├── 91-private/                  #   認証・個人情報・機密メモ
    ├── 92-storage/                  #   大容量ファイル：動画・PDF・エクスポート原本等
    └── 99-trash/                    #   削除の代わりの退避先
```

---

## 3. 専用 CLI `ob` コマンド

| コマンド | 動作 |
| :--- | :--- |
| `ob` / `ob pickup` | `40-daily/PICKUP.md` と今日の日誌を表示 |
| `ob path` | 現在の環境の Vault パスを表示 |
| `ob today [--print]` | 今日の日誌 (`40-daily/YYYY/MM/YYYY-MM-DD.md`) を生成して `$EDITOR` で開く |
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
| `modules/services/obsidian-brain.nix` | `services.obsidianBrain` オプション・Nix 依存解決ラッパー・Skill 配線・自動同期タイマー |
| `modules/ai/claude-code/default.nix`, `CLAUDE.md` | `~/.claude/CLAUDE.md` の生成・Claude Code 設定 |
| `modules/ai/gemini/default.nix`, `GEMINI.md` | `~/.gemini/GEMINI.md` の生成・Antigravity CLI / Gemini CLI 設定 |
