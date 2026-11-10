# Hammerspoon (macOS トラックパッドジェスチャー)

macOS 専用。Hammerspoon でトラックパッドのジェスチャーを拾い，AeroSpace の操作や
コピー・ペーストなどに割り当てています。右利き向けに，左半分や中央の誤爆しやすい操作は外してあります。

## 設定の場所

- 実体: [`modules/wm/hammerspoon/init.lua`](../modules/wm/hammerspoon/init.lua)
- 配置: [`modules/wm/hammerspoon/default.nix`](../modules/wm/hammerspoon/default.nix) が
  `~/.hammerspoon/init.lua` へ直結リンク（`mkOutOfStoreSymlink`）で置く．
  Home Manager の switch は不要で，Hammerspoon の `Reload Config` で即時反映できる．
- アプリ本体: [`hosts/mac/darwin.nix`](../hosts/mac/darwin.nix) の `casks` に `hammerspoon` を宣言（Homebrew 経由）．

## ジェスチャー一覧

| 操作 | 動作 |
| :--- | :--- |
| 3本指スワイプ 左 / 右 | AeroSpace のワークスペースを前 / 次へ移動 |
| 4本指スワイプ 左 / 右 | フォーカス中のウィンドウを連れて前 / 次のワークスペースへ移動 |
| 4本指スワイプ 下 | ウィンドウ / タブを閉じる（`Cmd+W`，閉じなければ AeroSpace の close） |
| 右上の角をタップ | コピー（`Cmd+C`，`Copied` を表示） |
| 右下の角をタップ | ペースト（`Cmd+V`，`Pasted` を表示） |
| 右端を指1本で上下になぞる | 音量調整（macOS 標準の HUD 付き） |

挙動の詳細（しきい値・判定）は `init.lua` の冒頭コメントとコードが正本です。

## 注意

- **権限**: 初回は「システム設定 > プライバシーとセキュリティ」の「アクセシビリティ」で Hammerspoon を許可する
  （手動．詳しくは [setup-mac.md](setup-mac.md) の「手動作業が残る理由」）．
- AeroSpace の実行ファイルは `/opt/homebrew/bin/aerospace` を直接呼ぶ．AeroSpace 側の設定は
  [aerospace.md](aerospace.md) を参照．
