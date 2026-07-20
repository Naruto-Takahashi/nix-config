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

一覧は [gitmoji.dev](https://gitmoji.dev) 準拠。実装は
`modules/apps/git-hooks/hooks/prepare-commit-msg` の `MAP` 連想配列。

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
[commitizen](https://commitizen-tools.github.io/commitizen/) (`pkgs.commitizen`) を使う。

```
cz commit
```

質問内容(type一覧+絵文字、scope一覧、subject)はリポジトリ直下の `.cz.toml`
(`cz_customize`アダプタ)で定義している。typeは絵文字付きでリストから選べ、
scopeは `modules/apps/*` `modules/shell/*` などこのリポジトリのモジュール名の
一覧から選べる(`deps`/`deps-dev`も含む)。回答を組み立てると
`✨ feat(nvim): subject` のような形で先頭に絵文字が付いた状態でコミットされるため、
後段の`prepare-commit-msg`フックは「既に絵文字がある」と判定してスキップし、
二重付与にはならない。

lazygit内では `E` (Emojiの連想) に `cz commit` を割り当て済み
(stage済みの変更がある状態、Filesパネルで使う)。
(`<c-e>` はdiffingMenu-alt、`x`はconfirmDiscardと衝突するため使わない)

`.cz.toml`はこのリポジトリ固有のscope一覧を前提にしているため、
他の個人リポジトリでは自前で `.cz.toml` を用意しない限り
デフォルトのConventional Commits形式(絵文字なし)で聞かれる点に注意。

使い分けの目安:
- 型を意識せず素早くコミットしたい / AIエージェント経由 → 何もせず通常通りコミット(自動推定)
- type/scopeをきちんと選びたい → `cz commit`

## エスケープハッチ

- 絵文字や `:shortcode:` を自分で先頭に書けば自動付与はスキップされる
- `git commit --no-verify` でフック自体をスキップできる(rebase途中など特殊なケース向け)
- `commit-msg` フックは絵文字が無くても警告のみでコミットは通す(拒否しない)

## 適用範囲

`~/.gitconfig` の `[includeIf "gitdir:~/ghq/github.com/Naruto-Takahashi/**"]` で
個人リポジトリ配下のみに限定している。会社リポジトリや他人のOSSクローンなど
配下外では自動適用されない。個人リポジトリでも特定の1つだけ外したい場合は、
そのリポジトリ内で以下を実行する。

```
git config --local core.hooksPath ""
```
