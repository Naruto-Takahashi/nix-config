# hosts/sandbox — 実データ非共有のコンテナ

> **役割**: wslc (WSL Containers) など、ホストのファイルシステムを見えないコンテナ内で、普段と同じ CLI ツールと Neovim 設定を使うための最小プロファイル。Home Manager のスタンドアロン構成 (`homeConfigurations.sandbox`)。使い捨てを前提に、root のまま動かす
> **適用**: コンテナ内で `just switch`

## このホストが使うもの

| 区分 | 内容 | 場所 |
| :--- | :--- | :--- |
| ユーザー設定の入口 | `profiles/core.nix` だけを読み込む。ユーザー名とホームは固定 | [default.nix](default.nix) |
| 共通の土台 | 最小の CLI・シェル | [profiles/core.nix](../../profiles/core.nix) |

## 補足

GUI・systemd ユーザーサービス・カーネルのキー入力リマップは対象外。ホストとのシームレスな統合を前提にした [distrobox](../distrobox/README.md) とは、コンテナの作り方そのものが違う。
