# グローバル指示 (Antigravity CLI)

このファイルは `modules/ai/antigravity` が生成する `~/.gemini/GEMINI.md` のベース部分である。全エージェント共通の行動規範 (`common-rules.md`) および機能別の追加ルール（Obsidian外部脳連携など）がこの下に自動結合される。

---

## 開発指針・補助ワークフロー (Antigravity 固有)

- **クリップボード・スクリーンショット画像連携 (`/c` コマンド / `agy-ss`)**:
  - ユーザーが `/c` コマンドを実行し出力に `"Image captured."` が含まれていた場合、またはスクリーンショットを確認する場合は、指定の一時画像パス（`.gemini/tmp/clipboard_image.png`）や `~/screenshots/`（または `~/Pictures/Screenshots/`）内の最新画像を画像対応のファイル読み取りツールで即座に確認する。
