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

## 対話的に選びたい場合: gitmoji-cli

自動推定に任せず、type/scope/subjectを対話的に選んでコミットしたい場合は
[gitmoji-cli](https://github.com/carloscuesta/gitmoji-cli) (`pkgs.gitmoji-cli`) を使う。

```
gitmoji -c
```

公式gitmoji一覧(60種類以上)から選べるため、自作の`MAP`連想配列より網羅的。
gitmoji-cliが先に絵文字を付けるので、後段の`prepare-commit-msg`フックは
「既に絵文字がある」と判定してスキップし、二重付与にはならない。

lazygit内では `E` (Emojiの連想) に `gitmoji -c` を割り当て済み
(stage済みの変更がある状態、Filesパネルで使う)。
(`<c-e>` はdiffingMenu-alt、`x`はconfirmDiscardと衝突するため使わない)

使い分けの目安:
- 型を意識せず素早くコミットしたい / AIエージェント経由 → 何もせず通常通りコミット(自動推定)
- じっくり選びたい / 公式一覧から細かい絵文字(🚑️緊急修正など)を使いたい → `gitmoji -c`

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
