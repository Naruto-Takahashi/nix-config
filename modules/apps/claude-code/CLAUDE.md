# グローバル指示 (Claude Code)

このファイルは `modules/apps/claude-code` が生成する `~/.claude/CLAUDE.md` のベース部分である。機能別の追加ルール（Obsidian外部脳連携など）は `programs.claudeCode.extraInstructions` 経由でこの下に自動追記される。

---

## 共通ルール

1. **言語と句読点**:
   - 常に日本語でやり取りする。
   - 日本語の句読点は標準の「、」と「。」を使用する。
2. **計画の提示方法**:
   - タスクを実行する前に計画を提示し、ユーザーの許可を得てから進行する。
   - 大掛かりな作業（大規模なリファクタリング、アーキテクチャ変更、不確実性の高い作業など）を除き、計画は `.md` ファイル（`implementation_plan.md`）として書き出さず、チャット上で簡潔にテキスト形式で提示して承諾を得る。
3. **対話と意思決定**:
   - タスク完遂のために追加情報が必要な場合は推測せず質問する。
   - 重要な技術的決定を行う場合は選択肢とトレードオフを簡潔に提示し、フィードバックを得る。
4. **Skills の自己申告**:
   - タスク実行や回答にあたって Skills を参照・使用した場合は、毎回どの Skill を使用したかを必ず明示・自己申告する。

---

## 設定ファイル・リポジトリ運用ルール

1. **dotfiles / 環境設定の一元管理 (`nix-config`)**:
   - 各種設定ファイル（WezTerm、Zsh、Neovim、Yazi、Lazygit、komorebi、YASB、AutoHotkey、Kanata、Hyprland、AeroSpace、AIエージェント設定等）は、すべて `~/ghq/github.com/Naruto-Takahashi/nix-config`（Nix Flakes / Home Manager）を正本として宣言的に管理する（旧 `~/dotfiles` や `home-manager-config` は編集しない）。
   - `~/.zshrc` や `~/.claude/CLAUDE.md`、`~/.gemini/GEMINI.md` 等を直接編集せず、`profiles/base.nix`（全ホスト共通）、`modules/`（機能別）、`hosts/`（ホスト固有）の該当ファイルを編集する。
2. **Nix Flakes のビルドと Windows 同期**:
   - ローカル flake は git 管理下（stage 済み）のファイルしか評価しないため、変更後は必ず **`git add` してから `home-manager switch`**（または `nix flake check`）を実行する。
   - WSL 環境で Windows 側アプリ（WezTerm、AutoHotkey、komorebi、YASB、Vivaldi、kanata）の設定を変更した際は、反映後に `sync-win` を実行して Windows 側へコピーする（Windows 側から WSL へのシンボリックリンクは使用しない）。
3. **Git コミット規約**:
   - コミットメッセージは `type(scope): 説明` 形式（例: `feat(nix): ...`, `fix(hosts): ...`）とする。
   - `modules/apps/git-hooks` の `prepare-commit-msg` フックが `type` から gitmoji を自動付与するため、AI 自身は先頭に絵文字を付けず `type(scope):` のみを記述する。
4. **リポジトリ管理 (`ghq`) と機密情報**:
   - すべてのリポジトリは `ghq` を用いて `~/ghq` 配下で一元管理する。
   - API キー等の機密情報は `~/.env` 等で管理し、Git には絶対にコミットしない。

---

## 開発指針

- **CLIツール・スクリプト**: 起動オーバーヘッドを避けるため、可能な限り **Shell Script + curl + jq + gum** で高速・シンプルに実装する。研究・機械学習用途では **Python (`uv`)** や **Rust** を適切に活用する。
