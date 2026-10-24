# =========================================================================
# nix-config コマンドランナー (justfile)
# =========================================================================
# 使い方:
#   just --list      利用可能なタスク一覧を表示
#   just switch      現在の環境に合わせて自動で switch を実行
#   just check       全構成の静的評価・構文検証 (CI と同等)
#   just fmt         全 Nix ファイルを nixfmt で自動整形
#   just sync-win    Windows 側へ設定を同期 (WSL 専用)
#   just restore-secrets [item] [path]  Bitwarden から ~/.env を復元

set shell := ["bash", "-cu"]

# デフォルト: タスク一覧を表示
default:
    @just --list

# 全構成の静的評価・Flake 検証 (CI と同等)
check:
    nix flake check --no-build

# 全 Nix ファイルの自動フォーマット
fmt:
    nix fmt

# 現在の OS / 環境を自動判別して設定を適用
switch:
    #!/usr/bin/env bash
    set -euo pipefail
    git add .
    if [[ "$OSTYPE" == darwin* ]]; then
        echo "🍎 macOS (darwin) を検出しました。darwin-rebuild switch を実行します..."
        darwin-rebuild switch --flake .#mac
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "🪟 WSL2 を検出しました。home-manager switch を実行します..."
        home-manager switch --flake .#wsl
        if command -v sync-win >/dev/null 2>&1; then
            echo "Windows 側へ設定を同期します..."
            sync-win
        fi
    elif [ -f /etc/NIXOS ]; then
        echo "❄️ NixOS を検出しました。nixos-rebuild switch を実行します..."
        sudo nixos-rebuild switch --flake .#nixos
    elif [ -n "${CONTAINER_ID:-}" ] || [ -f /run/.containerenv ]; then
        echo "📦 コンテナ環境を検出しました。home-manager switch を実行します..."
        home-manager switch --flake .#sandbox
    else
        echo "🐧 Linux 環境を検出しました。home-manager switch を実行します..."
        home-manager switch --flake .#wsl
    fi

# Windows 側へ設定を同期 (WSL 環境専用)
sync-win:
    #!/usr/bin/env bash
    if command -v sync-win >/dev/null 2>&1; then
        sync-win
    else
        echo "::error:: sync-win コマンドが見つかりません。WSL 環境でのみ利用可能です。" >&2
        exit 1
    fi

# Bitwarden CLI から ~/.env を復元
restore-secrets item="developer-env" target="$HOME/.env":
    ./modules/shell/zsh/scripts/restore-secrets.sh "{{item}}" "{{target}}"

# ドキュメント内リンクの死活チェック
check-links:
    #!/usr/bin/env bash
    fail=0
    while IFS= read -r file; do
      dir=$(dirname "$file")
      while IFS= read -r link; do
        path="${link%%#*}"
        [ -z "$path" ] && continue
        case "$path" in
          http://*|https://*|mailto:*|"...") continue ;;
        esac
        target="$dir/$path"
        if [ ! -e "$target" ]; then
          echo "broken link in $file -> $link"
          fail=1
        fi
      done < <(grep -oE "\]\([^)]+\)" "$file" | sed -E "s/^\]\((.*)\)$/\1/")
    done < <(git ls-files "docs/*.md" README.md)
    if [ "$fail" -eq 0 ]; then
      echo "✅ すべてのドキュメント内リンクが正常です。"
    fi
    exit $fail
