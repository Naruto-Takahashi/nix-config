{ config, pkgs, lib, ... }:

let
  agy-brain = pkgs.writeShellApplication {
    name = "agy-brain";
    runtimeInputs = [ pkgs.gum pkgs.ripgrep pkgs.jq pkgs.coreutils pkgs.findutils ];
    excludeShellChecks = [ "SC2012" ];
    text = ''
      VAULT_PATH="/mnt/c/Users/tnaru/Obsidian/Vault"
      mkdir -p "$VAULT_PATH"

      echo "=== Obsidian 外部脳連携 Antigravity CLI ==="
      
      # 0. 初期セットアップ (フォルダ・ファイルの作成チェック)
      CREATED_ANY=false
      for folder in "Knowledge" "Decisions" "Projects" "Preferences"; do
        if [ ! -d "$VAULT_PATH/$folder" ]; then
          mkdir -p "$VAULT_PATH/$folder"
          touch "$VAULT_PATH/$folder/.gitkeep"
          echo "-> ディレクトリを作成しました: $folder/"
          CREATED_ANY=true
        fi
      done
      
      if [ ! -f "$VAULT_PATH/Knowledge/mistakes.md" ]; then
        touch "$VAULT_PATH/Knowledge/mistakes.md"
        echo "-> ファイルを作成しました: Knowledge/mistakes.md"
        CREATED_ANY=true
      fi

      if [ "$CREATED_ANY" = true ]; then
        echo "=========================================="
        echo "初期セットアップが完了しました．"
        echo "自己紹介を Preferences/profile.md に書いておくと，AIがあなたのことを覚えやすくなります．"
        echo "=========================================="
      fi

      # 1. 参照ルールの定義とインジェクション
      RULE_PROMPT="あなたは私のAIアシスタントです．
ObsidianのVaultを「外部脳」として扱い，セッションを跨いで知識を引き継いでください．
MCP経由（obsidianツール）でObsidianを読み書きできます．

---

【行動ルール】
1. 読み取り（セッション開始時に必ず実行）：
   - 行動ルール（Knowledge/mistakes.md）と，Preferences/ 配下のユーザープロファイルを最初に必ず読み込んでください．
   - 私の質問に関連するキーワードでVaultを検索し，ヒットしたノートを読んでその内容を踏まえて回答してください（※無関係な単発質問はスキップ可）．

2. 書き込み（その場でVaultに書き込む。「後で書く」はしない）：
   - バグ解決，設定ハマり対策，新しい発見などは「Knowledge/」に書き込む．
   - 判断・設計の方針決定は「Decisions/」に書き込む．
   - プロジェクトの状態変更は「Projects/」に書き込む．
   - ユーザーの好みの発見は「Preferences/」に書き込む．

3. 書き込みフォーマット：
   ノートには必ず以下のYAMLフロントマターを付与してください：
   ---
   date: YYYY-MM-DD
   tags: [relevant, tags]
   project: project-name
   related: [[Other Note]]
   ---
   タイトル
   本文。関連ノートには [[wiki link]] でリンクする．

4. ファイル命名規則：
   - Knowledge: topic-subtopic.md （例: nextjs-auth-cookie.md）
   - Decisions: YYYY-MM-DD-topic.md （例: 2026-05-16-database-choice.md）
   - Preferences: category.md （例: coding-style.md）
   - Projects: project-name.md

5. mistakes.md への追記ルール：
   ユーザーから明示的な訂正を受け，かつ「繰り返し起こり得るパターン」「具体的な『する/しない』で書ける」を満たす場合，即座に Knowledge/mistakes.md に追記してください．
   形式：
   YYYY-MM-DD: [一言で何を間違えたか]
   **NG Action**: 実際にやってしまった間違い
   **Correct Action**: 次回からの正しい対応
   **Trigger**: このルールが適用される状況

6. 報告：
   Obsidianを読み書きしたら，必ず「Obsidian: [ファイルパス] を読みました/書き込みました」と明示的にユーザーに伝えてください．サイレントで読み書きしないこと．

7. 作業スタイル：
   - シンプルで読みやすいものを優先する．
   - 不要な装飾・冗長な説明は省く．
   - 既存のパターン・命名規則に合わせる．
   - デプロイや動作確認は自分で完結させ，ユーザーに頼まない．

---
それでは，まずは指示通り『Knowledge/mistakes.md』と『Preferences/』配下のファイルを読み込んでから回答を開始してください．"

      # 2. Antigravity CLIの起動
      # 対話セッションをバックグラウンド実行して終了時にログを保存するため、セッション実行前の最新IDを記録
      BRAIN_DIR="$HOME/.gemini/antigravity-cli/brain"
      PREV_LATEST=""
      if [ -d "$BRAIN_DIR" ]; then
        PREV_LATEST=$(ls -td "$BRAIN_DIR"/*/ 2>/dev/null | head -n 1)
      fi

      # ルールプロンプトを初期値として引き渡して起動
      antigravity-cli --prompt-interactive "$RULE_PROMPT"

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
          OBSIDIAN_VAULT = "/mnt/c/Users/tnaru/Obsidian/Vault";
        };
      };
    };
  };

  # ObsidianのVaultディレクトリを初期作成するフック
  home.activation = {
    createObsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "/mnt/c/Users/tnaru/Obsidian/Vault"
    '';
  };
}
