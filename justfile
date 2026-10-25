# =========================================================================
# nix-config コマンドランナー (justfile)
# =========================================================================
# 使い方:
#   just --list      利用可能なタスク一覧を表示
#   just switch [host]  現在の環境に合わせて switch を実行 (host で明示指定も可。新規ファイルは git add -N)
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

# 現在の OS / 環境を自動判別して設定を適用 (host で明示指定も可)
switch host="":
    #!/usr/bin/env bash
    set -euo pipefail
    # Mac は内部で sudo darwin-rebuild を呼ぶ。just ごと sudo すると git 操作も root で走り、
    # .git に root 所有のファイルができうるため止める (sandbox は root 前提なので対象外)
    if [[ "$OSTYPE" == darwin* && $EUID -eq 0 ]]; then
        echo "::error:: Mac では sudo を付けずに 'just switch' を実行してください (必要な箇所だけ sudo を求めます)。" >&2
        exit 1
    fi
    # flake は git が追跡するファイルしか評価しないため、新規ファイルを追跡対象に加える。
    # 中身は stage せず (-N)、意図しないファイル (秘密情報等) に気づけるよう一覧を表示する。
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "⚠ 未追跡ファイルを評価対象に加えます (git add -N):"
        git ls-files --others --exclude-standard | sed 's/^/    /'
        git ls-files -z --others --exclude-standard | xargs -0 git add -N --
    fi
    host="{{host}}"
    # 判定順の注意:
    #   - wslc 等のコンテナは WSL カーネル上で動き /proc/version に microsoft を含むため、
    #     コンテナ判定は WSL 判定より前に置く。
    #   - distrobox も CONTAINER_ID / /run/.containerenv を持つため、sandbox 判定より前に置く。
    #   - どれにも当てはまらない場合は誤った構成を適用しないようエラーで止める。
    if [ -z "$host" ]; then
        if [[ "$OSTYPE" == darwin* ]]; then
            host=mac
        elif [ -f /etc/NIXOS ]; then
            host=nixos
        elif [ -n "${DISTROBOX_ENTER_PATH:-}" ]; then
            host=distrobox
        elif [ -n "${CONTAINER_ID:-}" ] || [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
            host=sandbox
        elif grep -qi microsoft /proc/version 2>/dev/null; then
            host=wsl
        else
            echo "::error:: 環境を判別できません。'just switch <mac|nixos|wsl|distrobox|sandbox>' で明示してください。" >&2
            exit 1
        fi
    fi
    echo "▶ host=$host の構成を適用します..."
    case "$host" in
        mac)
            sudo darwin-rebuild switch --flake .#mac ;;
        nixos)
            sudo nixos-rebuild switch --flake .#nixos ;;
        wsl)
            home-manager switch --flake .#wsl
            if command -v sync-win >/dev/null 2>&1; then
                echo "Windows 側へ設定を同期します..."
                sync-win
            fi ;;
        distrobox)
            # home.homeDirectory を $HOME から読むため --impure が必須 (hosts/distrobox 参照)
            home-manager switch --flake .#distrobox --impure ;;
        sandbox)
            home-manager switch --flake .#sandbox ;;
        *)
            echo "::error:: 未知のホストです: $host" >&2
            exit 1 ;;
    esac

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
