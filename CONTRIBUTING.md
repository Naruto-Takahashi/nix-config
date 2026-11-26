# CONTRIBUTING — 変更・追加・保守の手順

このリポジトリを変更するときのルールの正本。人も AI エージェントも、作業の前に読む ([AGENTS.md](AGENTS.md) から誘導している)。

## 1. 考え方

- **機能別に整理し、OS ごとの実装は並べて置く。** 例えばキーリマップは `modules/input/` に Kanata / Karabiner / AutoHotkey を並べ、窓管理は `modules/wm/` に AeroSpace / Hyprland / komorebi を並べる。対になる実装が隣り合っているので、直し忘れに気づける。
- **共通化を無理にしない。** 似ているというだけでは束ねない。同じ内容が実際に複数の場所にあり、片方だけ直すと事故になる場合だけ共通にする (その場合も、後から変えやすいかを優先する)。
- **「どこにあるか」は地図で答える。** ファイルを動かして整理するより、README の地図と各ホストの索引を正しく保つ。
- **ホスト別の入口は `hosts/<ホスト>/`。** そのホストが使うモジュールは `hosts/<ホスト>/default.nix` の imports を読めば全部分かる。

## 2. どこに置くか

| 追加するもの | 置き場所 |
| :--- | :--- |
| 新しいツール・アプリの設定 | `modules/<機能>/<ツール>/` (`default.nix` と、解説の `README.md`) |
| 特定のホストだけの設定 (システム設定、そのホスト固有のパッケージなど) | `hosts/<ホスト>/` |
| 複数ホストで使うモジュールの組み合わせ | `profiles/` |
| セットアップ手順書、複数ツールにまたがる文書 | `docs/` |
| 1つのツールの解説・キーバインド表 | そのツールのフォルダの `README.md` (`docs/` には置かない) |

手順:

1. `modules/<機能>/<ツール>/default.nix` を作る。
2. 使うホストの `hosts/<ホスト>/default.nix` (または共通なら `profiles/*.nix`) の `imports` に足す。
3. 同じフォルダに `README.md` を作り、冒頭に [3. ドキュメントの規約](#3-ドキュメントの規約) のヘッダーを書く。
4. [6. 更新が必要な場所](#6-追加削除改名したときに更新する場所) を確認する。

## 3. ドキュメントの規約

各ツールの `README.md` は、`# タイトル` の直後に、次の4行を必ず置く。

```markdown
> **役割**: 何のための設定か (1行)
> **対象ホスト**: Mac / NixOS / WSL / 全ホスト
> **対になる実装**: 同じ役割の別実装へのリンク。なければ「なし」
> **注意**: 他のファイルとの連動や、変更時に忘れやすいこと
```

- リンクは相対パスで書く。壊れていないかは `just check-links` が検査する。
- 設定から自動生成される文書ではない。**コードを直したら、同じフォルダの `README.md` も直す。**
- ドキュメントを追加・移動したら、[docs/README.md](docs/README.md) の索引も直す。

## 4. 対になる実装 (`SYNC-PAIR`)

OS ごとにツールが違うため、同じ役割の実装が複数ある (キーリマップ、WM のキーバインド、Matugen の適用スクリプト)。一覧は [README の「同じ役割の別実装」](README.md#同じ役割の別実装-どれかを直したら他も確認する) にある。

**片方を直したら、対になる実装も確認する。** 忘れないように、該当ファイルの先頭 (シバンがあればその次) に次のコメントを置く。

```text
# SYNC-PAIR: <相手のパス>, <相手のパス>
```

- コメント記号はそのファイルの言語に合わせる (`#`、`;;`、`;`、`--`、`/* ... */`)。
- パスはリポジトリのルートからの相対パス。相手が複数なら `,` で区切る。
- **相互に書く。** A が B を指すなら、B も A を指す。片方向だと `just check-sync` がエラーにする。
- 新しい対を作ったら、[README の一覧](README.md#同じ役割の別実装-どれかを直したら他も確認する) と、関係するホストの `README.md` の「対になる実装」にも書く。
- ファイルを移動・改名・削除したら、相手側のコメントも直す。
- 片方だけ直すのが正しい場合 (OS 固有の事情など) は、理由をコミットメッセージに書く。CI は PR で、対になる実装を触っていない変更を警告する (失敗にはしない)。

## 5. 変更の手順

1. ブランチを切る (`main` に直接コミットしない)。
2. 編集する。**新しいファイルは `git add` する** (flake は git が追跡するファイルしか評価しない)。
3. `just fmt` で整形する。
4. 検査する。**終了コードで成否を確認する** (出力を grep や tail で絞って判断しない)。
   - `just lint` — リンク切れ、`SYNC-PAIR` の整合性、シェルスクリプトなど
   - `just check` — 全構成の評価
   - 影響するホストのビルド: `nix build .#darwinConfigurations.mac.system --no-link` / `nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link` / `nix build '.#homeConfigurations."wsl".activationPackage' --no-link`
5. 対になる実装を触ったか確認する: `just check-sync-changed main` (警告が出たら、相手も直すか、理由を残す)。
6. コミットする。形式は `type(scope): 説明` (gitmoji は hook が自動で付けるので、手動で絵文字を付けない)。
7. `switch` (`just switch`) は、実機で人が実行する。反映後に必要な手動の許可がないか、[docs/setup-mac.md](docs/setup-mac.md) などを確認する。

## 6. 追加・削除・改名したときに更新する場所

| 変更 | 更新するもの |
| :--- | :--- |
| ホストの追加・削除 | `flake.nix`、`justfile` (`switch` のホスト判定)、`.github/workflows/check.yml`、`hosts/<ホスト>/README.md`、[README](README.md) の「対応表」、[docs/README.md](docs/README.md)、`docs/setup-*.md` |
| ツールの追加・削除 | そのツールの `README.md`、使うホストの `imports`、使うホストの `hosts/<ホスト>/README.md`、[README](README.md) の「対応表」 |
| 対になる実装の追加・削除 | 該当ファイル両方の `SYNC-PAIR`、[README](README.md) の一覧、関係するホストの `README.md` |
| ファイル・フォルダの移動 | 他のファイルからのリンクとコメント (`git grep -n <旧パス>` で確認)、`SYNC-PAIR` |

## 7. 検査コマンド

| コマンド | 内容 |
| :--- | :--- |
| `just lint` | リンク切れ・`SYNC-PAIR`・シェルスクリプト・starship の同期 (CI と同等) |
| `just check-links` | 全 `*.md` の相対リンクが実在するか |
| `just check-sync` | `SYNC-PAIR` の参照先が実在し、相互参照になっているか |
| `just check-sync-changed [比較元]` | 変更したファイルの対になる実装が、同じ変更に含まれているか (警告のみ) |
| `just check` | 全構成の評価 (`nix flake check`) |
| `just fmt` | Nix コードの整形 |

## 8. やってはいけないこと

- `~/.zshrc` などの設定ファイルを直接編集する (正本はこのリポジトリ)。
- 秘密情報 (API キー、認証情報) をコミットする。
- 自動生成のファイル (`hardware-configuration.nix`、`flake.lock` の手書き) を手で直す。
- 確認なしに `main` へマージ・`push`・`switch` する (AI エージェントは、ユーザーの指示があるまで実行しない)。
- シェルで `cp` / `rm` を使うとき、対話式のエイリアスで止まらないよう注意する (`command cp -f` など)。消す前に、対象を確認する。
