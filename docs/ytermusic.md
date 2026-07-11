# ytermusic — TUI YouTube Music プレイヤー

Rust 製の YouTube Music 用 TUI プレイヤー。`ytermusic` コマンドで起動する。
配色は Matugen パレットに追従する (docs/matugen-palette.md 参照)。

## 初回セットアップ (認証)

YouTube Music の Cookie をブラウザから取り出して配置する。

1. ブラウザで https://music.youtube.com を開いてログインする
2. F12 (開発者ツール) → Network タブ → ページを再読み込みし，
   最初の document リクエストを選択する
3. Request Headers から `Cookie` の値を丸ごとコピーする
   (Firefox の場合は「Raw」スイッチを ON にしてからコピーする)
4. `~/.config/ytermusic/headers.txt` を作成して以下の形式で保存する:

   ```
   Cookie: <コピーした値>
   User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
   ```

- Cookie は認証情報そのものなので **リポジトリにはコミットしない** (機微情報)。
- Cookie の有効期限が切れたら同じ手順で更新する。

## テーマ (Matugen 連携)

- `~/.config/ytermusic/config-template.toml` (home-manager 管理) の
  プレースホルダを `yasb-theme` が置換して `config.toml` を生成する。
- 割り当て: 再生中 = accent / 一時停止 = tertiary / 待機・次曲 = muted /
  ダウンロード中 = secondary / 検索中 = complement / エラー = 赤系。
- 壁紙変更や `sync-win` (--reapply) のたびに再生成される。
  起動中の ytermusic には反映されないので開き直す。

## 主なキー操作

| キー | 動作 |
| :---: | :--- |
| `f` | 検索 |
| `Space` | 再生 / 一時停止 |
| `Enter` | 選択 |
| `>` / `<` | 次の曲 / 前の曲 |
| `+` / `-` | 音量 |
| `←` / `→` | シーク |
| `Esc` / `q` | 戻る / 終了 |
