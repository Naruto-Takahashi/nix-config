# Hammerspoon (macOS トラックパッドジェスチャー)

> **役割**: macOS の Hammerspoon によるトラックパッドジェスチャー (ワークスペース移動・ウィンドウ操作・コーナータップ)
> **対象ホスト**: Mac
> **対になる実装**: なし (Mac 専用)
> **注意**: AeroSpace のコマンドを呼ぶので、AeroSpace のキーバインドやワークスペース名を変えたら確認する

macOS 専用。Hammerspoon でトラックパッドのジェスチャーを拾い，AeroSpace の操作や
コピー・ペーストなどに割り当てています。右利き向けに，左半分や中央の誤爆しやすい操作は外してあります。

## 設定の場所

- 実体: [`modules/wm/hammerspoon/init.lua`](init.lua)
- 配置: [`modules/wm/hammerspoon/default.nix`](default.nix) が
  `~/.hammerspoon/init.lua` へ直結リンク（`mkOutOfStoreSymlink`）で置く．
  Home Manager の switch は不要で，Hammerspoon の `Reload Config` で即時反映できる．
- アプリ本体: [`hosts/mac/darwin.nix`](../../../hosts/mac/darwin.nix) の `casks` に `hammerspoon` を宣言（Homebrew 経由）．

## ジェスチャー一覧

| 操作 | 動作 |
| :--- | :--- |
| 3本指スワイプ 左 / 右 | AeroSpace のワークスペースを前 / 次へ移動 |
| 4本指スワイプ 左 / 右 | フォーカス中のウィンドウを連れて前 / 次のワークスペースへ移動 |
| 4本指スワイプ 下 | ウィンドウ / タブを閉じる（`Cmd+W`，閉じなければ AeroSpace の close） |
| 右上の角を押し込む | コピー（`Cmd+C`，`Copied` を表示） |
| 右下の角を押し込む | ペースト（`Cmd+V`） |
| 左下の角を押し込む | 取り消し（`Cmd+Z`） |
| 左上の角を押し込む | やり直し（`Cmd+Shift+Z`） |
| 上中央を押し込む | 範囲指定スクショ（`Cmd+Shift+4`） |
| 右端を指1本で上下になぞる | 音量調整（macOS 標準の HUD 付き。カーソル静止中のみ開始） |

補足:

- 角・上中央の判定は、指1本で物理クリック（押し込み）したときだけ有効．タップでは発火しない．
- コピー時のみ HUD（半透明の黒いカプセル）を表示する．
- 3本指以上が触れている間だけスクロールをアプリに渡さない（ブラウザの「横スクロール=戻る」の誤爆防止）．
  この監視は3本指が触れたときだけ有効になり，普段のスクロールは通らない．

挙動の詳細（しきい値・判定）は `init.lua` の冒頭コメントとコードが正本です。

## 注意

- **権限**: 初回は「システム設定 > プライバシーとセキュリティ」の「アクセシビリティ」で Hammerspoon を許可する
  （手動．詳しくは [setup-mac.md](../../../docs/setup-mac.md) の「手動作業が残る理由」）．
- AeroSpace の実行ファイルは `/opt/homebrew/bin/aerospace` を直接呼ぶ．AeroSpace 側の設定は
  [aerospace.md](../aerospace/README.md) を参照．
