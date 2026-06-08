{ config, pkgs, lib, ... }:

let
  agy-brain = pkgs.writeShellApplication {
    name = "agy-brain";
    runtimeInputs = [ pkgs.gum pkgs.ripgrep pkgs.jq pkgs.coreutils pkgs.findutils ];
    text = ''
      VAULT_PATH="$HOME/Obsidian/Vault"
      mkdir -p "$VAULT_PATH"

      echo "=== Obsidian 外部脳連携 Antigravity CLI ==="
      
      # 1. 参照するメモの選択
      SELECTED_NOTE=""
      NOTE_CONTENT=""
      
      # Vaultが存在し、中にMarkdownファイルがあるか確認
      if [ -d "$VAULT_PATH" ] && [ "$(find "$VAULT_PATH" -name "*.md" | wc -l)" -gt 0 ]; then
        if gum confirm "Obsidianのメモをコンテキストとして参照しますか？"; then
          SELECTED_NOTE=$(find "$VAULT_PATH" -name "*.md" | sed "s|$VAULT_PATH/||" | gum filter --placeholder "参照するメモを選択してください...")
          if [ -n "$SELECTED_NOTE" ] && [ -f "$VAULT_PATH/$SELECTED_NOTE" ]; then
            echo "-> メモ「$SELECTED_NOTE」をコンテキストとして読み込みました．"
            NOTE_CONTENT=$(cat "$VAULT_PATH/$SELECTED_NOTE")
          fi
        fi
      fi

      # 2. Antigravity CLIの起動
      # 対話セッションをバックグラウンド実行して終了時にログを保存するため、セッション実行前の最新IDを記録
      BRAIN_DIR="$HOME/.gemini/antigravity-cli/brain"
      PREV_LATEST=""
      if [ -d "$BRAIN_DIR" ]; then
        PREV_LATEST=$(ls -td "$BRAIN_DIR"/*/ 2>/dev/null | head -n 1)
      fi

      if [ -n "$NOTE_CONTENT" ]; then
        # 初期プロンプトにメモ内容を含めて対話起動
        INITIAL_PROMPT="以下のObsidianメモの内容をコンテキスト（参照情報）として理解してください．\n\n=== メモ: $SELECTED_NOTE ===\n$NOTE_CONTENT\n=======================\n\n上記メモのコンテキストを踏まえて，回答を開始してください．"
        antigravity-cli --prompt-interactive "$INITIAL_PROMPT"
      else
        antigravity-cli
      fi

      # 3. セッション終了後のログ保存
      echo "対話セッションが終了しました．会話履歴をObsidianに保存します..."
      sleep 1 # ファイル書き込み同期待ち
      
      if [ -d "$BRAIN_DIR" ]; then
        NEW_LATEST=$(ls -td "$BRAIN_DIR"/*/ 2>/dev/null | head -n 1)
        # セッションが新規作成された、または更新された場合
        if [ -n "$NEW_LATEST" ] && [ "$NEW_LATEST" != "$PREV_LATEST" ]; then
          SESSION_ID=$(basename "$NEW_LATEST")
          DATE_STR=$(date "+%Y-%m-%d_%H-%M-%S")
          LOG_DIR="$VAULT_PATH/AI-Brain/Logs"
          mkdir -p "$LOG_DIR"
          LOG_FILE="$LOG_DIR/Chat-$SESSION_ID-$DATE_STR.md"

          # transcript.jsonl から対話内容をMarkdownにパース
          TRANSCRIPT_PATH="$NEW_LATEST/transcript.jsonl"
          if [ -f "$TRANSCRIPT_PATH" ]; then
            {
              echo "# Antigravity CLI 会話ログ"
              echo "Session ID: \`$SESSION_ID\`"
              echo "Date: $DATE_STR"
              echo ""
              echo "---"
              echo ""
              # JSONLからユーザーとアシスタントの発言を抽出してMarkdown化
              jq -r 'select(.type=="USER_INPUT" or .type=="PLANNER_RESPONSE") | 
                     (if .type=="USER_INPUT" then "\n## 👤 ユーザー\n" else "\n## 🤖 アシスタント\n" end) + 
                     (.content // "") + "\n"' "$TRANSCRIPT_PATH"
            } > "$LOG_FILE"
            echo "-> 会話ログを保存しました: $LOG_FILE"
          else
            echo "警告: 会話ログファイルが見つかりませんでした．"
          fi
        else
          echo "新しいセッション履歴は見つかりませんでした．"
        fi
      fi
    '';
  };
in
{
  home.packages = [
    agy-brain
  ];

  # ~/.gemini/config/mcp_config.json の生成
  home.file."${config.home.homeDirectory}/.gemini/config/mcp_config.json".text = builtins.toJSON {
    mcpServers = {
      obsidian = {
        command = "npx";
        args = [ "-y" "mcpvault" ];
        env = {
          OBSIDIAN_VAULT = "${config.home.homeDirectory}/Obsidian/Vault";
        };
      };
    };
  };

  # ObsidianのVaultディレクトリを初期作成するフック
  home.activation = {
    createObsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$HOME/Obsidian/Vault"
    '';
  };
}
