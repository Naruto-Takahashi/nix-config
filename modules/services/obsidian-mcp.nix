# =========================================================================
# Obsidian External Brain (Medallion × Lightweight Johnny.Decimal) 連携モジュール
# =========================================================================
# 責務の分離:
# - Vault構造・ルール・Skill (.agents/skills/obsidian-brain/SKILL.md) および
#   機械実行スクリプト本体 (scripts/ob.sh, scripts/sync.sh, scripts/check-secrets.sh) は
#   すべて obsidian-vault リポジトリ側が正本として自己完結保持する。
# - 本モジュール (nix-config) は純粋な OS インフラ配線のみを担う:
#   1. ripgrep / git / gitleaks 等の依存を PATH に保証して Vault 内の scripts/*.sh を呼ぶラッパー
#   2. Claude Code / Antigravity CLI の skills ディレクトリから Vault 内 SKILL.md への結線
#   3. グローバル指示 (CLAUDE.md / GEMINI.md) への最小ポインタ注入
#   4. 30分おきの自動同期タイマー (Linux: systemd.user / macOS: launchd.agents)
{ config, pkgs, lib, ... }:

let
  cfg = config.services.obsidianBrain;

  # --- 双方向Git自動同期ラッパー (実体は Vault 内の scripts/sync.sh) ---
  obsidian-vault-sync = pkgs.writeShellApplication {
    name = "obsidian-vault-sync";
    runtimeInputs = [
      pkgs.bash
      pkgs.git
      pkgs.openssh
      pkgs.coreutils
      pkgs.gitleaks
    ];
    text = ''
      export OBSIDIAN_VAULT_PATH="''${OBSIDIAN_VAULT_PATH:-${cfg.vaultPath}}"
      if [ ! -f "$OBSIDIAN_VAULT_PATH/scripts/sync.sh" ]; then
        echo "obsidian-vault-sync: $OBSIDIAN_VAULT_PATH/scripts/sync.sh が見つからないためスキップ"
        exit 0
      fi
      exec bash "$OBSIDIAN_VAULT_PATH/scripts/sync.sh" "$@"
    '';
  };

  # --- 外部脳操作CLI `ob` ラッパー (実体は Vault 内の scripts/ob.sh) ---
  ob-cli = pkgs.writeShellApplication {
    name = "ob";
    runtimeInputs = [
      pkgs.bash
      pkgs.ripgrep
      pkgs.git
      pkgs.openssh
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnused
      pkgs.gitleaks
    ];
    text = ''
      export OBSIDIAN_VAULT_PATH="''${OBSIDIAN_VAULT_PATH:-${cfg.vaultPath}}"
      if [ ! -f "$OBSIDIAN_VAULT_PATH/scripts/ob.sh" ]; then
        echo "ob: $OBSIDIAN_VAULT_PATH/scripts/ob.sh が見つかりません" >&2
        exit 1
      fi
      exec bash "$OBSIDIAN_VAULT_PATH/scripts/ob.sh" "$@"
    '';
  };

  # --- CLAUDE.md / GEMINI.md に注入するコンパクトな外部脳ルール ---
  obsidianBrainInstructions = ''
    ---

    ## Obsidian External Brain (Medallion × Lightweight Johnny.Decimal)

    Obsidian Vault（パス: `${cfg.vaultPath}`、唯一の入り口: `${cfg.vaultPath}/AGENTS.md`）を日常・大学・研究・開発すべてを一元化する「外部脳」として扱い、セッションを跨いで文脈と知識を維持する。
    操作には重いMCPサーバーは使わず、**AIの標準ファイル操作ツール（Read/Edit/Write/Grep）** または **専用CLI `ob` コマンド（実体: `${cfg.vaultPath}/scripts/ob.sh`）** を直接使用する。詳細な規約は `obsidian-brain` スキル（`${cfg.vaultPath}/.agents/skills/obsidian-brain/SKILL.md`）を参照すること。

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
