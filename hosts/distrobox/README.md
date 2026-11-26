# hosts/distrobox — sudo 無しの共有 Linux (rootless podman)

> **役割**: sudo が使えない共有 Linux ホスト上の、distrobox コンテナ内の CLI 環境。Home Manager のスタンドアロン構成 (`homeConfigurations.distrobox`)。GUI・systemd ユーザーサービス・カーネルのキー入力リマップは対象外
> **適用**: コンテナ内で `just switch`
> **初回セットアップ**: [docs/setup-distrobox.md](../../docs/setup-distrobox.md)

## このホストが使うもの

| 区分 | 内容 | 場所 |
| :--- | :--- | :--- |
| ユーザー設定の入口 | `profiles/core.nix` と `profiles/ai-agent.nix` だけを読み込む。ホームのパスはコンテナ起動時の `$HOME` から動的に読む | [default.nix](default.nix) |
| 初期化 | コンテナ内の準備スクリプト | [bootstrap.sh](bootstrap.sh) |
| 共通の土台 | 最小の CLI・シェル | [profiles/core.nix](../../profiles/core.nix) |
| AI エージェント環境 | Claude Code / Antigravity / agent-skills / Obsidian Brain | [profiles/ai-agent.nix](../../profiles/ai-agent.nix) |

## 補足

ホストの `$HOME` とは共有しない設計 (共有すると、ホストが直接読む `.zshrc` などと Home Manager 管理のファイルが同じパスで衝突し、switch のたびに壊れるため)。実データを持たないコンテナ用の [sandbox](../sandbox/README.md) とは、コンテナの作り方が違う。
