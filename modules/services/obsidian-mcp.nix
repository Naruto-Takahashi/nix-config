# =========================================================================
# Obsidian External Brain (Medallion × Lightweight Johnny.Decimal) 連携モジュール
# =========================================================================
# 責務の分離:
# - Vault構造・ルール・Skill本体 (AGENTS.md, .agents/skills/obsidian-brain/SKILL.md) は
#   obsidian-vault リポジトリ側が正本として自己完結保持する。
# - 本モジュール (nix-config) は OS レイヤーの配線のみを担う:
#   1. 全OS共通の軽量操作CLI `ob` と gitleaks 検査付き双方向Git同期 `obsidian-vault-sync` の提供
#   2. Claude Code / Antigravity CLI の skills ディレクトリから Vault 内 SKILL.md への結線
#   3. グローバル指示 (CLAUDE.md / GEMINI.md) への最小ポインタ注入
#   4. 30分おきの自動同期タイマー (Linux: systemd.user / macOS: launchd.agents)
{ config, pkgs, lib, ... }:

let
  cfg = config.services.obsidianBrain;

  # --- 双方向Git自動同期スクリプト (pull --rebase + gitleaks検査 + commit + push) ---
  obsidian-vault-sync = pkgs.writeShellApplication {
    name = "obsidian-vault-sync";
    runtimeInputs = [
      pkgs.git
      pkgs.openssh
      pkgs.coreutils
      pkgs.gitleaks
    ];
    text = ''
      VAULT_PATH="''${OBSIDIAN_VAULT_PATH:-${cfg.vaultPath}}"

      if [ ! -d "$VAULT_PATH/.git" ]; then
        echo "obsidian-vault-sync: $VAULT_PATH はgitリポジトリではないためスキップ"
        exit 0
      fi

      cd "$VAULT_PATH"

      # Webチャット (GitHub連携) や他OSからの変更を先に取り込む
      git pull --rebase --autostash -q || echo "obsidian-vault-sync: pull --rebase に失敗 (オフラインまたは競合)" >&2

      git add -A

      if ! git diff --cached --quiet; then
        # コミット直前に gitleaks でステージング済みの変更に機密情報が含まれていないか機械検査する
        if ! gitleaks protect --staged --no-banner --redact; then
          echo "obsidian-vault-sync: [ERROR] gitleaks が機密情報を検知したためコミットをブロックしました。90-private/ へ移動してください。" >&2
          git reset -q
          exit 1
        fi
        git commit -q -m "auto: vault sync $(date '+%Y-%m-%d %H:%M:%S')"
      fi

      # ローカルに未pushのコミットがあればpushする
      if [ -n "$(git status -sb 2>/dev/null | grep '\[ahead ' || true)" ]; then
        git push -q || echo "obsidian-vault-sync: pushに失敗 (次回リトライされます)" >&2
      fi
    '';
  };

  # --- 軽量外部脳操作CLI (ob) ---
  ob-cli = pkgs.writeShellApplication {
    name = "ob";
    runtimeInputs = [
      pkgs.ripgrep
      pkgs.git
      pkgs.coreutils
      pkgs.findutils
      pkgs.gitleaks
      obsidian-vault-sync
    ];
    text = ''
      VAULT_PATH="''${OBSIDIAN_VAULT_PATH:-${cfg.vaultPath}}"

      ensure_daily() {
        local year month day daily_dir daily_file
        year="$(date +%Y)"
        month="$(date +%m)"
        day="$(date +%Y-%m-%d)"
        daily_dir="$VAULT_PATH/04-todo/daily/$year/$month"
        daily_file="$daily_dir/$day.md"
        mkdir -p "$daily_dir"
        if [ ! -f "$daily_file" ]; then
          cat <<EOF > "$daily_file"
      ---
      date: $day
      tags: [daily]
      ---
      # $day

      ## Tasks / Focus
      - [ ] 

      ## Memo / Life Log

      ## AI Sessions
      EOF
        fi
        printf '%s\n' "$daily_file"
      }

      cmd="''${1:-pickup}"
      if [ "$#" -gt 0 ]; then
        shift
      fi

      case "$cmd" in
        pickup|status)
          echo "=== [04-todo/PICKUP.md] ==="
          if [ -f "$VAULT_PATH/04-todo/PICKUP.md" ]; then
            cat "$VAULT_PATH/04-todo/PICKUP.md"
          else
            echo "(PICKUP.md が見つかりません: $VAULT_PATH/04-todo/PICKUP.md)"
          fi
          today_file="$VAULT_PATH/04-todo/daily/$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d).md"
          if [ -f "$today_file" ]; then
            echo ""
            echo "=== [Today: 04-todo/daily/$(date +%Y/%m/%Y-%m-%d).md] ==="
            cat "$today_file"
          fi
          ;;

        path)
          printf '%s\n' "$VAULT_PATH"
          ;;

        search|rg)
          if [ "$#" -eq 0 ]; then
            echo "Usage: ob search <query>" >&2
            exit 1
          fi
          rg --smart-case --line-number --heading \
            -g '!.git' -g '!.obsidian' -g '!.agents' \
            -g '!90-private/**' -g '!91-storage/**' -g '!99-trash/**' \
            "$*" "$VAULT_PATH" || true
          ;;

        list|ls)
          target_dir="$VAULT_PATH/''${1:-}"
          find "$target_dir" \
            -path '*/.git' -prune -o \
            -path '*/.obsidian' -prune -o \
            -path '*/99-trash' -prune -o \
            -type f -name '*.md' -print | sed "s|^$VAULT_PATH/||" | sort
          ;;

        today|daily)
          daily_file="$(ensure_daily)"
          if [ "''${1:-}" = "--print" ] || [ ! -t 1 ]; then
            echo "File: $daily_file"
            cat "$daily_file"
          else
            "''${EDITOR:-nvim}" "$daily_file"
          fi
          ;;

        memo|add)
          if [ "$#" -eq 0 ]; then
            echo "Usage: ob memo <text...>" >&2
            exit 1
          fi
          daily_file="$(ensure_daily)"
          time_str="$(date +%H:%M)"
          printf '\n- %s %s\n' "$time_str" "$*" >> "$daily_file"
          echo "-> 追記しました: $daily_file (- $time_str $*)"
          ;;

        journal|log)
          if [ "$#" -eq 0 ]; then
            echo "Usage: ob journal <title> [summary...]" >&2
            exit 1
          fi
          title="$1"
          shift
          daily_file="$(ensure_daily)"
          time_str="$(date +%H:%M)"
          body=""
          if [ "$#" -gt 0 ]; then
            body="$*"
          elif [ ! -t 0 ]; then
            body="$(cat)"
          fi
          {
            echo ""
            echo "### $time_str $title"
            if [ -n "$body" ]; then
              echo "$body"
            fi
          } >> "$daily_file"
          echo "-> デイリーノートにセッション要約を記録しました: $daily_file"
          ;;

        note|new)
          if [ "$#" -lt 2 ]; then
            echo "Usage: ob note <10|11|12|13|14|15|16|output|resource|todo|private> <title> [project] [tags]" >&2
            exit 1
          fi
          ntype="$1"
          title="$2"
          proj="''${3:-}"
          tags="''${4:-}"
          day="$(date +%Y-%m-%d)"

          case "$ntype" in
            10|self|decision|decisions)
              rel_dir="01-knowledge/10-self/decisions"
              default_tags="decision"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            11|cs|network)
              rel_dir="01-knowledge/11-cs-fundamentals"
              default_tags="knowledge, cs"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            12|lang|languages)
              rel_dir="01-knowledge/12-languages"
              default_tags="knowledge, lang"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            13|ai|sec|security)
              rel_dir="01-knowledge/13-ai-security"
              default_tags="knowledge, ai-security"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            14|dev|infra|tech)
              rel_dir="01-knowledge/14-devtools-infra"
              default_tags="knowledge, devtools"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            15|academic|career)
              rel_dir="01-knowledge/15-academic-career"
              default_tags="knowledge, academic"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            16|life|general)
              rel_dir="01-knowledge/16-life-general"
              default_tags="knowledge, life"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            output|project|projects|gold)
              rel_dir="02-output/$title"
              default_tags="output, project, status"
              target_file="$VAULT_PATH/$rel_dir/Status.md"
              ;;
            resource|resources|bronze)
              rel_dir="03-resources"
              default_tags="resource"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            todo)
              rel_dir="04-todo"
              default_tags="todo"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            private)
              rel_dir="90-private"
              default_tags="private"
              target_file="$VAULT_PATH/$rel_dir/$title.md"
              ;;
            *)
              echo "Unknown category: $ntype (expected: 10|11|12|13|14|15|16|output|resource|todo|private)" >&2
              exit 1
              ;;
          esac

          mkdir -p "$(dirname "$target_file")"
          use_tags="''${tags:-$default_tags}"
          body=""
          if [ ! -t 0 ]; then
            body="$(cat)"
          fi

          {
            echo "---"
            echo "date: $day"
            echo "tags: [$use_tags]"
            if [ -n "$proj" ]; then
              echo "project: $proj"
            fi
            echo "---"
            echo "# $title"
            echo ""
            if [ -n "$body" ]; then
              echo "$body"
            fi
          } > "$target_file"
          echo "-> ノートを作成しました: $target_file"
          ;;

        sync)
          obsidian-vault-sync
          echo "-> Vault の Git 同期が完了しました ($VAULT_PATH)"
          ;;

        help|--help|-h|*)
          cat <<EOF
      ob - Obsidian External Brain CLI (Vault: $VAULT_PATH)

      Usage:
        ob [pickup]                              04-todo/PICKUP.md と今日の日誌を表示
        ob path                                  Vault のパスを表示
        ob search <query>                        Vault 内を ripgrep で高速検索
        ob list [subdir]                         Vault 内のノート一覧を表示
        ob today [--print]                       今日の日誌 (04-todo/daily/YYYY/MM/YYYY-MM-DD.md) を開く/表示
        ob memo <text...>                        今日の日誌に時刻付き1行メモを即追記
        ob journal <title> [summary...]          今日の日誌にAIセッション要約を追記 (stdin対応)
        ob note <cat> <title> [proj] [tags]      日本語タイトルのノートを作成 (cat: 10..16|output|resource|todo|private)
        ob sync                                  gitleaks 検査付き双方向 Git 同期
      EOF
          ;;
      esac
    '';
  };

  # --- CLAUDE.md / GEMINI.md に注入するコンパクトな外部脳ルール ---
  obsidianBrainInstructions = ''
    ---

    ## Obsidian External Brain (Medallion × Lightweight Johnny.Decimal)

    Obsidian Vault（パス: `${cfg.vaultPath}`、唯一の入り口: `${cfg.vaultPath}/AGENTS.md`）を日常・大学・研究・開発すべてを一元化する「外部脳」として扱い、セッションを跨いで文脈と知識を維持する。
    操作には重いMCPサーバーは使わず、**AIの標準ファイル操作ツール（Read/Edit/Write/Grep）** または **専用CLI `ob` コマンド** を直接使用する。詳細な規約は `obsidian-brain` スキル（`${cfg.vaultPath}/.agents/skills/obsidian-brain/SKILL.md`）を参照すること。

    ### 1. 読み取り（セッション開始時）
    - **最小読み込み**: セッション開始時はまず `${cfg.vaultPath}/04-todo/PICKUP.md` を読む（または `ob pickup` を実行する）だけでよい。
    - **オンデマンド参照**: タスクに関連する場合のみ、`PICKUP.md` 内のリンク（`02-output/*/Status.md`、`00-rules/mistakes.md`、`01-knowledge/` 等）を辿るか、`ob search <query>` で必要な箇所だけを読む。

    ### 2. フォルダ構造と書き込み先（気づいた・決まったその場で書く）
    - **`00-rules/`**: AI・人間が守るべき運用ルール・再発防止教訓（訂正を受けた際は `00-rules/mistakes.md` に即追記）
    - **`01-knowledge/`【シルバー層：事実・整理した知識】**（ノート名は**日本語タイトル**、例: `LANとWANの違い.md`）
      - `10-self/`: 自分に関する事実（`profile.md`）および設計・方針の意思決定（`decisions/<日本語タイトル>.md`）
      - `11-cs-fundamentals/`: CS基礎・ネットワーク・OS・DB（`ob note 11 "<タイトル>"`）
      - `12-languages/`: プログラミング言語（`ob note 12 "<タイトル>"`）
      - `13-ai-security/`: AI・機械学習・セキュリティ・パスワード研究知識（`ob note 13 "<タイトル>"`）
      - `14-devtools-infra/`: 開発ツール・OS環境設定・トラブル解決知見（`ob note 14 "<タイトル>"`）
      - `15-academic-career/`: 大学・研究室・キャリア（`ob note 15 "<タイトル>"`）
      - `16-life-general/`: 日常生活・ライフ管理・一般教養（`ob note 16 "<タイトル>"`）
    - **`02-output/`【ゴールド層：成果物】**: 研究・開発プロジェクトの進捗（`02-output/<project>/Status.md`）や最終成果物
    - **`03-resources/`【ブロンズ層：原本】**: 調べた記録・外部資料の原本（書き換えない一次データ）
    - **`04-todo/`**: 現在地（`PICKUP.md`）、未着手タスク、1日1ファイルの日誌（`daily/YYYY/MM/YYYY-MM-DD.md`）
    - **`90-private/`・`91-storage/`・`99-trash/`**: `.gitignore` 管理外（機密情報・大容量ファイル・削除代わりの退避先）

    ### 3. セッション区切り・終了時の行動
    - 意味のある作業を行ったセッションの区切り・終了時には、`ob journal "<タイトル>" "<要点>"` でその日の日誌（`04-todo/daily/YYYY/MM/YYYY-MM-DD.md`）に簡潔な要約を追記し、注力事項に変化があれば `04-todo/PICKUP.md` を更新する。
    - Vault を読み書きした際は、参照・更新したノートを簡潔にユーザーへ伝えること。
  '';
in
{
  options.services.obsidianBrain = {
    enable = lib.mkEnableOption "Obsidian External Brain 連携 (ob CLI / Skill配線 / 自動git sync)";

    vaultPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/obsidian-vault";
      description = ''
        Obsidian Vault (obsidian-vault リポジトリ) のローカルパス。
        WSL では /mnt/c/Users/tnaru/Obsidian/Vault、Mac/NixOS では
        ~/ghq/github.com/Naruto-Takahashi/obsidian-vault を指す。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      ob-cli
      obsidian-vault-sync
      pkgs.gitleaks
    ];

    home.sessionVariables = {
      OBSIDIAN_VAULT_PATH = cfg.vaultPath;
    };

    # Claude Code と Antigravity/Gemini 両方のグローバル指示に外部脳ポインタを注入
    programs.claudeCode.extraInstructions = [ obsidianBrainInstructions ];

    # Vault 自体が持つ .agents/skills/obsidian-brain/SKILL.md を
    # Claude Code と Antigravity CLI の両方のグローバルスキルへ直結する。
    home.file.".claude/skills/obsidian-brain/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.vaultPath}/.agents/skills/obsidian-brain/SKILL.md";
    home.file.".gemini/config/skills/obsidian-brain/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.vaultPath}/.agents/skills/obsidian-brain/SKILL.md";

    # 旧 @bitbonsai/mcpvault 設定を空にして不要な Node.js MCP 起動を防ぐ
    home.file.".gemini/config/mcp_config.json".text = builtins.toJSON {
      mcpServers = { };
    };

    # Vault ディレクトリ初期化 & ~/.claude.json に残存する旧 obsidian MCP 定義の自動クリーンアップ
    home.activation.setupObsidianBrain = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${cfg.vaultPath}"
      if [ -f "$HOME/.claude.json" ] && ${pkgs.jq}/bin/jq -e '.mcpServers.obsidian' "$HOME/.claude.json" >/dev/null 2>&1; then
        $DRY_RUN_CMD ${pkgs.jq}/bin/jq 'del(.mcpServers.obsidian)' "$HOME/.claude.json" > "$HOME/.claude.json.tmp"
        $DRY_RUN_CMD mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
      fi
    '';

    # --- Linux / WSL: systemd --user タイマー (30分おきに双方向sync) ---
    systemd.user.services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      obsidian-vault-sync = {
        Unit.Description = "Obsidian Vault の双方向 git sync (pull --rebase & gitleaks & commit & push)";
        Service = {
          Type = "oneshot";
          ExecStart = "${obsidian-vault-sync}/bin/obsidian-vault-sync";
        };
      };
    };
    systemd.user.timers = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      obsidian-vault-sync = {
        Unit.Description = "obsidian-vault-sync を30分おきに実行";
        Timer = {
          OnStartupSec = "5m";
          OnUnitActiveSec = "30m";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };

    # --- macOS: launchd エージェント (30分おきに双方向sync) ---
    launchd.agents = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      obsidian-vault-sync = {
        enable = true;
        config = {
          ProgramArguments = [ "${obsidian-vault-sync}/bin/obsidian-vault-sync" ];
          StartInterval = 1800;
          RunAtLoad = true;
          StandardOutPath = "/tmp/obsidian-vault-sync.log";
          StandardErrorPath = "/tmp/obsidian-vault-sync.err";
        };
      };
    };
  };
}
