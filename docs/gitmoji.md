# gitmoji 自動付与

`modules/apps/git-hooks` が、個人リポジトリ (`~/ghq/github.com/Naruto-Takahashi/**`) での
`git commit` にgitmojiを自動で付与する。git CLI直接実行、lazygit(nvim内/外)、
Claude CodeなどのAIエージェント経由のコミットも `git commit` を呼ぶ限り対象になる。

## 使い方

`type: subject` または `type(scope): subject` のConventional Commits風に書けば、
先頭に対応する絵文字が自動で付く。

```
feat: add sample file
→ ✨ feat: add sample file
```

型を推定できない自由文には `💬` が付く。すでに絵文字や `:shortcode:` が
先頭にある場合は何もしない(手動で選びたい時はそのまま書けばよい)。

## マッピング表

| 接頭辞 | 絵文字 | 意味 |
|---|---|---|
| `feat` | ✨ | 新機能 |
| `fix` | 🐛 | バグ修正 |
| `docs` | 📝 | ドキュメント |
| `style` | 🎨 | 構造/フォーマット改善 |
| `refactor` | ♻️ | リファクタリング |
| `perf` | ⚡️ | パフォーマンス改善 |
| `test` | ✅ | テスト追加/更新 |
| `chore` | 🔧 | 設定/雑務 |
| `build` | 📦️ | ビルド成果物/パッケージ |
| `ci` | 👷 | CI |
| `revert` | ⏪️ | リバート |
| `wip` | 🚧 | 作業中 |
| `remove` | 🔥 | コード/ファイル削除 |
| `security` | 🔒️ | セキュリティ修正 |
| `init` | 🎉 | プロジェクト開始 |
| `debug` | 🔍️ | ログ調査/デバッグ |
| `merge` | 🔀 | ブランチマージ |
| (該当なし) | 💬 | デフォルト |

一覧は [gitmoji.dev](https://gitmoji.dev) 準拠。type→絵文字の対応は
`modules/apps/git-hooks/gitmoji-types.txt` が単一ソースで、以下の3箇所は
全てここから生成/参照する(新しいtypeを足す時はこのファイルだけ直せばよい)。

- `prepare-commit-msg`フックの`MAP`(実行時にこのファイルを読んで構築)
- `cz commit`の静的フォールバック(`~/.config/commitizen/cz.toml`、
  Nixがビルド時に`cz.toml.tmpl`の`@@GITMOJI_CZ_CHOICES@@`に埋め込む)
- `cz commit`のmatugenテーマ版(`~/.cache/matugen/cz.toml`、
  `matugen-apply.sh`が`render-gitmoji-choices.sh`で埋め込む)

### 依存関係更新 (scopeベース)

独自typeは作らず、Renovate/Dependabot慣例に合わせて `scope` が
`deps` / `deps-dev` のときに絵文字を上書きする。

```
chore(deps): bump nixpkgs to 24.11
→ ⬆️ chore(deps): bump nixpkgs to 24.11

fix(deps): downgrade broken package
→ ⬇️ fix(deps): downgrade broken package
```

メッセージに `downgrade` の文字列が含まれる場合のみ⬇️、それ以外は⬆️になる。

## 対話的に選びたい場合: commitizen (cz)

自動推定に任せず、type/scope/subjectを対話的に選んでコミットしたい場合は
`cz commit` を使う。

```
cz commit
```

`cz`は`modules/apps/git-hooks`が提供するラッパーコマンドで、実体は
[commitizen](https://commitizen-tools.github.io/commitizen/)を
`~/.config/commitizen/cz.toml` (`cz_customize`アダプタ、ソースは
`modules/apps/git-hooks/cz.toml`) で常に起動する。**リポジトリごとに
`.cz.toml`を用意する必要はなく、どのリポジトリでも同じ体験になる。**

- type: 絵文字付きでリストから選択(feat/fix/docs/style/refactor/perf/test/
  chore/build/ci/revert/wip/remove/security/init/debug/merge)
- scope: 自由入力(空でもよい)。リポジトリごとに意味が違うため固定リストにしていない
- subject: 自由入力

回答を組み立てると`✨ feat(nvim): subject`のような形で先頭に絵文字が付いた
状態でコミットされるため、後段の`prepare-commit-msg`フックは「既に絵文字が
ある」と判定してスキップし、二重付与にはならない。

lazygit内では **`c`** (通常のcommitChangesを上書き) に `cz commit` を
割り当て済み(stage済みの変更がある状態、Filesパネルで使う)。
素のメッセージ入力に戻したい場合は `C`(commitChangesWithEditor)、
フックごとスキップしたい場合は `w`(commitChangesWithoutHook)を使う。

使い分けの目安:
- 型を意識せず素早くコミットしたい / AIエージェント経由 → 何もせず通常通りコミット(自動推定)
- type/subjectをきちんと選びたい → `cz commit` (lazygitなら `c`)

## エスケープハッチ

- 絵文字や `:shortcode:` を自分で先頭に書けば自動付与はスキップされる
- **絵文字を付けたくない1回だけのコミット**は、フックそのものをスキップすればよい:
  - lazygit: `c`ではなく **`w`**(commitChangesWithoutHook)を押す
  - CLI: `git commit --no-verify -m "..."`
- `commit-msg` フックは絵文字が無くても警告のみでコミットは通す(拒否しない、
  上記の`--no-verify`/`w`を使わなくても`prepare-commit-msg`が💬を付けるので
  実際には常に絵文字が付く)

## 適用範囲

`~/.gitconfig` の `[includeIf "gitdir:~/ghq/github.com/Naruto-Takahashi/**"]` で
個人リポジトリ配下のみに限定している。会社リポジトリや他人のOSSクローンなど
配下外では自動適用されない。個人リポジトリでも特定の1つだけ外したい場合は、
そのリポジトリ内で以下を実行する。

```
git config --local core.hooksPath ""
```
