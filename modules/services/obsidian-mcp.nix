# =========================================================================
# Obsidian External Brain (v2) 連携モジュール
# =========================================================================
# 責務の分離:
# - Vault構造・ルール・Skill本体 (.agents/skills/obsidian-brain/SKILL.md, AGENTS.md) は
#   obsidian-vault リポジトリ側が正本として自己完結保持する。
# - 本モジュール (nix-config) は OS レイヤーの配線のみを担う:
#   1. 全OS共通の軽量操作CLI `ob` と双方向Git同期 `obsidian-vault-sync` の提供
#   2. Claude Code / Antigravity CLI の skills ディレクトリから Vault 内 SKILL.md への結線
#   3. グローバル指示 (CLAUDE.md / GEMINI.md) への最小ポインタ注入
#   4. 30分おきの自動同期タイマー (Linux: systemd.user / macOS: launchd.agents)
{ config, pkgs, lib, ... }:

let
  cfg = config.services.obsidianBrain;

  # --- 双方向Git自動同期スクリプト (pull --rebase --autostash + commit + push) ---
  obsidian-vault-sync = pkgs.writeShellApplication {
    name = "obsidian-vault-sync";
    runtimeInputs = [ pkgs.git pkgs.openssh pkgs.coreutils ];
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
      obsidian-vault-sync
    ];
    text = ''
      VAULT_PATH="''${OBSIDIAN_VAULT_PATH:-${cfg.vaultPath}}"

      ensure_daily() {
        local year month day daily_dir daily_file
        year="$(date +%Y)"
        month="$(date +%m)"
        day="$(date +%Y-%m-%d)"
        daily_dir="$VAULT_PATH/01_Daily/$year/$month"
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
          echo "=== [05_Meta/PICKUP.md] ==="
          if [ -f "$VAULT_PATH/05_Meta/PICKUP.md" ]; then
            cat "$VAULT_PATH/05_Meta/PICKUP.md"
          else
            echo "(PICKUP.md が見つかりません: $VAULT_PATH/05_Meta/PICKUP.md)"
          fi
          today_file="$VAULT_PATH/01_Daily/$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d).md"
          if [ -f "$today_file" ]; then
            echo ""
            echo "=== [Today: 01_Daily/$(date +%Y/%m/%Y-%m-%d).md] ==="
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
            -g '!.git' -g '!.obsidian' -g '!.trash' -g '!.agents' \
            "$*" "$VAULT_PATH" || true
          ;;

        list|ls)
          target_dir="$VAULT_PATH/''${1:-}"
          find "$target_dir" \
            -path '*/.git' -prune -o \
            -path '*/.obsidian' -prune -o \
            -path '*/.trash' -prune -o \
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
          if [ "$#" -lt 3 ]; then
            echo "Usage: ob note <tech|decision|project|area|inbox> <slug> <title> [project] [tags]" >&2
            exit 1
          fi
          ntype="$1"
          slug="$2"
          title="$3"
          proj="''${4:-}"
          tags="''${5:-}"
          day="$(date +%Y-%m-%d)"

          case "$ntype" in
            tech|knowledge)
              rel_dir="04_Knowledge/Tech"
              default_tags="knowledge, tech"
              target_file="$VAULT_PATH/$rel_dir/$slug.md"
              ;;
            decision|decisions)
              rel_dir="04_Knowledge/Decisions"
              default_tags="decision"
              target_file="$VAULT_PATH/$rel_dir/$slug.md"
              ;;
            project|projects)
              rel_dir="02_Projects/$slug"
              default_tags="project, status"
              target_file="$VAULT_PATH/$rel_dir/Status.md"
              ;;
            area|areas)
              rel_dir="03_Areas"
              default_tags="area"
              target_file="$VAULT_PATH/$rel_dir/$slug.md"
              ;;
            inbox)
              rel_dir="00_Inbox"
              default_tags="inbox"
              target_file="$VAULT_PATH/$rel_dir/$slug.md"
              ;;
            *)
              echo "Unknown note type: $ntype (expected: tech|decision|project|area|inbox)" >&2
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
        ob [pickup]                              05_Meta/PICKUP.md と今日のデイリーノートを表示
        ob path                                  Vault のパスを表示
        ob search <query>                        Vault 内を ripgrep で高速検索
        ob list [subdir]                         Vault 内のノート一覧を表示
        ob today [--print]                       今日のデイリーノート (01_Daily/YYYY/MM/YYYY-MM-DD.md) を開く/表示
        ob memo <text...>                        今日のデイリーノートに時刻付き1行メモを即追記
        ob journal <title> [summary...]          今日のデイリーノートにAIセッション要約を追記 (stdin対応)
        ob note <type> <slug> <title> [proj]     規約フロントマター付きノートを作成 (type: tech|decision|project|area|inbox)
        ob sync                                  双方向 Git 同期 (pull --rebase --autostash + commit + push)
      EOF
          ;;
      esac
    '';
  };

  # --- CLAUDE.md / GEMINI.md に注入するコンパクトな外部脳ルール ---
  # 詳細なフォーマットやフォルダ仕様は Vault 内の Skill (.agents/skills/obsidian-brain/SKILL.md)
  # に集約し、常時プロンプトには最小限のトリガー条件のみを持たせてトークン消費を抑える。
  obsidianBrainInstructions = ''
    ---

    ## Obsidian External Brain (The Context Garden v2)

    Obsidian Vault（パス: `${cfg.vaultPath}`）を日常・研究・開発すべてを一元化する「外部脳」として扱い、セッションを跨いで文脈と知識を維持する。
    操作には重いMCPサーバーは使わず、**AIの標準ファイル操作ツール（Read/Edit/Write/Grep）** または **専用CLI `ob` コマンド** を直接使用する。詳細な規約は `obsidian-brain` スキル（`${cfg.vaultPath}/.agents/skills/obsidian-brain/SKILL.md`）を参照すること。

    ### 1. 読み取り（セッション開始時）
    - **最小読み込み**: セッション開始時はまず `${cfg.vaultPath}/05_Meta/PICKUP.md` を読む（または `ob pickup` を実行する）だけでよい。
    - **オンデマンド参照**: タスクに関連する場合のみ、`PICKUP.md` 内のリンク（`02_Projects/*/Status.md`、`03_Areas/*.md`、`04_Knowledge/mistakes.md` 等）を辿るか、`ob search <query>` で必要な箇所だけを読む。

    ### 2. 書き込み（気づいた・決まったその場で書く。「後で書く」はしない）
    - **バグ解決・ハマり対策・技術知見** → `04_Knowledge/Tech/<slug>.md`（`ob note tech <slug> "<title>"`）
    - **設計・方針の意思決定（なぜそう決めたか）** → `04_Knowledge/Decisions/<slug>.md`（`ob note decision <slug> "<title>"`）
    - **研究・開発プロジェクトの進捗変化** → `02_Projects/<project>/Status.md`
    - **大学・日常生活・継続領域の記録** → `03_Areas/<topic>.md`
    - **ユーザーの好み・属性の発見** → `05_Meta/profile.md`
    - **ユーザーからの訂正で再発しうる教訓** → `04_Knowledge/mistakes.md` に即追記
    - **分類に迷う一時メモ** → `00_Inbox/<slug>.md` または `ob memo "<text>"`
    - ※新規作成前には必ず `ob search` で既存ノートを確認し、重複テーマがあれば既存ノートへ統合・追記する。

    ### 3. セッション区切り・終了時の行動
    - 意味のある作業を行ったセッションの区切り・終了時には、`ob journal "<タイトル>" "<要点>"` でその日のデイリーノート（`01_Daily/YYYY/MM/YYYY-MM-DD.md`）に簡潔な要約を追記し、注力事項に変化があれば `05_Meta/PICKUP.md` を更新する。
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
    ];

    home.sessionVariables = {
      OBSIDIAN_VAULT_PATH = cfg.vaultPath;
    };

    # Claude Code と Antigravity/Gemini 両方のグローバル指示に外部脳ポインタを注入
    programs.claudeCode.extraInstructions = [ obsidianBrainInstructions ];

    # Vault 自体が持つ .agents/skills/obsidian-brain/SKILL.md を
    # Claude Code と Antigravity CLI の両方のグローバルスキルへ直結する。
    # Out-of-store symlink にすることで、Vault 側で SKILL.md を編集した瞬間に
    # home-manager switch 無しで両エージェントに即時反映される。
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
        Unit.Description = "Obsidian Vault の双方向 git sync (pull --rebase & commit & push)";
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
