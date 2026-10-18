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

  # --- CLAUDE.md / GEMINI.md に注入する最小限の外部脳ポインタ ---
  # フォルダ構成やルール詳細は Vault 側の正本 (AGENTS.md / SKILL.md) に一元化し、
  # グローバル指示には「場所」と「発火タイミング」の3行だけを持たせて二重管理・競合を防ぐ。
  obsidianBrainInstructions = ''
    ---

    ## Obsidian External Brain 連携

    - **外部脳 (Vault) の場所**: `${cfg.vaultPath}`（唯一の入り口・構成定義: `${cfg.vaultPath}/AGENTS.md`、詳細手順スキル: `obsidian-brain`、専用CLI: `ob`）
    - **セッション開始時**: まず `ob pickup`（または `${cfg.vaultPath}/04-todo/PICKUP.md` の読み取り）を実行し、現在の最優先事項と直近の文脈を把握する。
    - **セッション中・終了時**: 新しい知識・設計判断・プロジェクト進捗変化・再発防止教訓は、`obsidian-brain` スキル（`${cfg.vaultPath}/.agents/skills/obsidian-brain/SKILL.md`）の規約に従ってその場で Vault に書き込み（`ob note` 等）、セッションの区切り・終了時は `ob journal "<タイトル>" "<要点>"` で日誌に記録して、読み書きした対象をユーザーへ簡潔に伝えること。
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

    # Claude Code と Gemini/Antigravity 両方のグローバル指示に最小ポインタを注入
    programs.claudeCode.extraInstructions = [ obsidianBrainInstructions ];
    programs.geminiCli.extraInstructions = [ obsidianBrainInstructions ];

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
