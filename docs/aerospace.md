# AeroSpace ウィンドウマネージャ キーバインド・設定詳細

**macOS専用**です．[modules/wm/aerospace/default.nix](../modules/wm/aerospace/default.nix) で宣言的に管理されているタイル型ウィンドウマネージャ **AeroSpace** の操作・配色連携・自動化まわりを解説します．NixOSの[Hyprland](hyprland.md)，Windows/WSLの[komorebi](komorebi.md)に相当する役割です．

物理キーは全て `Option` 長押しですが，Kanataがそれを `Ctrl+Cmd` (`ctrl-cmd-*`) に変換してAeroSpaceへ送っています（macOS標準のCmd単体ショートカットと衝突しないようにするため）．変換の仕組みは [kanata.md](kanata.md) の「対象OS・実装方式の違い」を参照してください．

---

## キーバインド (Main Mode)

すべて `Option + <キー>` （実際に送信されるのは `Ctrl+Cmd + <キー>`）です．

### フォーカス・ウィンドウ移動

| キー | 動作 |
| :---: | :--- |
| `H` / `J` / `K` / `L` | フォーカスを 左/下/上/右 へ移動 |
| `Shift + H/J/K/L` | フォーカスウィンドウを 左/下/上/右 へ移動 |
| `Ctrl + H/J/K/L` | 隣のウィンドウとコンテナを結合 (`join-with`) |

### サイズ調整

| キー | 動作 |
| :---: | :--- |
| `U` / `P` | 幅を -50 / +50 |
| `O` / `I` | 高さを +50 / -50 |
| `R` | service モードへ移行 (下記参照) |

### レイアウト

| キー | 動作 |
| :---: | :--- |
| `/` | 分割方向をタイル横⇄縦に切り替え (AeroSpaceデフォルトの `alt-slash` と同じ) |
| `,` | アコーディオンレイアウトの横⇄縦切り替え (AeroSpaceデフォルトの `alt-comma` と同じ) |
| `E` | ゴーストウィンドウ（空ノード）の解消・ツリー平坦化 (`flatten-workspace-tree`) |
| `F` | フルスクリーン切り替え |
| `M` | ウィンドウを最小化 (macOSネイティブ) |
| `Q` | ウィンドウを閉じる (実送信は `ctrl-cmd-shift-w`．Cmd+Shift+Q のログアウトと衝突させないため) |

AeroSpace自体の一時停止/再開はキーに割り当てていません．停止中は全バインド（`enable` を含むものも）が無効になりキーから再開できないためで，必要なときはターミナルから `aerospace enable off` / `aerospace enable on` を実行します．

### service モード (`Option + R` で入る)

AeroSpaceデフォルトの `service` モードと同じ考え方で，「たまに使う調整系の操作」を修飾キーなしの1キーに集約しています．`H/J/K/L` 以外は実行後に自動でメインモードへ戻ります．

| キー | 動作 |
| :---: | :--- |
| `H` / `J` / `K` / `L` | 幅 -50 / 高さ -50 / 高さ +50 / 幅 +50 でリサイズ (モードに留まり連続操作可) |
| `F` | フローティング⇄タイリング切り替え (フロート中の枠線は補色に変わる) |
| `B` | ワークスペース内の全ウィンドウサイズを均等化 (`balance-sizes`) |
| `C` | 設定再読み込み (`reload-config`) + ゴースト枠解消 + 開いている全窓へのルール遡及適用 |
| `Esc` / `Enter` | 何もせずメインモードへ戻る |

### ワークスペース

| キー | 動作 |
| :---: | :--- |
| `S` / `A` | 次 / 前のワークスペースへ |
| `D` (実送信は `ctrl-cmd-t`) | 直近のワークスペースと切り替え |
| `1`〜`9` | 該当ワークスペースへ直接ジャンプ |
| `Shift + 1`〜`9` | フォーカスウィンドウを該当ワークスペースへ移動しつつ追従 |

マルチモニタ接続時は，Komorebi（Windows側）と同様にワークスペースを分割固定しています（`workspace-to-monitor-force-assignment`）．
- **メインモニタ**: `1` 〜 `5`
- **サブモニタ**: `6` 〜 `9`（未接続時はメインモニタへ自動フォールバック）

### アプリのクイック起動

起動系キーはNixOS/WSLと同じく「アプリ名の頭文字」に統一しています (`N`=Neovim，`Y`=Yazi，`V`=Vivaldi)．

| キー | 起動するもの |
| :---: | :--- |
| `Enter` | WezTerm (新規ウィンドウ) |
| `Y` | WezTerm内でYazi |
| `N` | WezTerm内でNeovim |
| `V` | Vivaldi (以前は`B`だったが，起動系キーの統一のため変更) |
| `W` | 壁紙ピッカー ([matugen-palette.md](matugen-palette.md#壁紙ファイルの配置場所) 参照) |

---

## ポップアップ・ゴーストウィンドウ対策の運用工夫

タイリングWM特有のmacOSでの不満点を以下の設定で解消しています：

1. **ポップアップ・コンテキストメニューの消失防止**
   - `focus-follows-mouse` (マウス追従) は有効化していますが，キー操作時にマウスを中央へジャンプさせるカーソルワープ (`move-mouse window-lazy-center`) は無効化しています．これにより，フォーカス移動時にカーソルが勝手に吹っ飛んでポップアップが消滅する事故を防ぎつつ，マウス追従の軽快さを維持しています．
2. **ゴーストウィンドウ（空の分割枠）の即座解消**
   - マウスの「×」ボタン等でウィンドウを閉じた際に空の分割枠が残った場合，`Option + E` (`flatten-workspace-tree`) を押すと一瞬で余白が詰められます．
3. **固定サイズアプリの自動フローティング**
   - 純正の「システム設定」やFinderは自動でフローティング化されます．それ以外のアプリも `Option + R` → `F` (service モード) でいつでも手動でタイリング⇄フローティングをトグルできます．

---

## 配色連携 (Matugen) と枠線 (JankyBorders)

アクティブウィンドウの枠線ハイライトは Homebrew の `borders` (JankyBorders) が担当します．色は壁紙から抽出した [Matugen](matugen-palette.md) のパレット (`~/.cache/matugen/colors.lua` の `triad`/`complement`/`accent`) に自動追従します．非アクティブウィンドウの枠線 (`inactive_color`) は完全透明 (`0x00000000`) にしています（AeroSpaceが別ワークスペースのウィンドウを画面右下に1px残して退避させる仕様のため，非アクティブ枠線を描画すると画面右下に枠線の角が飛び出して見えるのを防ぐため）．

- **フローティング中は枠線が補色 (`complement`) に変わります**．タイリング中は `triad` のままです．AeroSpaceにはレイアウト変更通知がないため，`on-focus-changed` とservice モードのフロート切替 (`Option + R` → `F`) から `aerospace-launch-borders` を都度呼び，フォーカス中ウィンドウの `%{window-layout}` が `floating` かどうかで色を切り替えます．
- 起動スクリプトは [`launch-borders.sh`](../modules/wm/aerospace/launch-borders.sh)．**`borders` は起動中に同じコマンドを再実行するとIPC経由で設定を生きたまま更新する仕様**なので，`pkill`して再起動する必要はありません（`pkill`すると次のインスタンスが上がるまでの一瞬，枠ハイライトが消えるため意図的に避けています）．
- matugenキャッシュが無い場合は，WSL/NixOS側と同じ青ベースのフォールバック配色を使います．
- ギャップ (`[gaps]`) は `inner.horizontal/vertical = 10`，`outer.left/bottom/right = 8`，`outer.top = 4`．WSL側komorebiの値 (`default_container_padding=6` / `default_workspace_padding=1`) と揃える案も試しましたが，見た目の好みでMac独自の値に戻しています．

---

## 壁紙ピッカー

`Option + W` (`ctrl-cmd-w`) で [`wallpaper-pick-popup.sh`](../modules/theming/matugen/mac/wallpaper-pick-popup.sh) が起動し，Raycast のサムネイルグリッド拡張機能（`raycast-wallpaper-picker`）が呼び出されます．選択すると即座に壁紙変更とMatugen配色反映（このAeroSpaceの枠線色を含む）が走ります．詳細は [matugen-palette.md](matugen-palette.md) を参照してください．

```toml
on-window-detected = [
  { if = 'test %{window-title} ~= "wallpaper picker"', run = 'layout floating' }
]
```

---

## ログイン時の自動リカバリ (LaunchAgent)

AeroSpace自身の `start-at-login = true` はmacOSのログインアイテムとして働きますが，**ログインセッションが完全に立ち上がる前に起動してしまうことがあります**．その場合，カスタム設定 (キーバインド・gaps・`on-window-detected`等) を読み込めずAeroSpaceの初期値 (ギャップ0・独自バインド無し) のまま起動してしまい，`after-startup-command` (borders起動) も取りこぼされます．

`after-startup-command` はAeroSpace自身の起動時に一度しか実行されず，`reload-config` では再実行されない仕様のため，取りこぼした場合は手動で気づいて直すしかありませんでした．これを防ぐため，ログイン20秒後に `aerospace reload-config` と `aerospace-launch-borders` の両方を確実に実行するLaunchAgent (`launchd.agents.aerospace-reload-config`) を登録しています．

`darwin-rebuild switch` の直後にすぐ変更を見たい場合（次回ログインを待たない場合）は，手動で以下を実行してください．

```bash
aerospace reload-config
```

---

## 設定変更時の注意

`aerospace.toml` は `modules/wm/aerospace/aerospace.toml` から `mkOutOfStoreSymlink` で直結されているため，`darwin-rebuild switch` を叩かなくてもファイルを編集するだけで即座に反映可能です．ファイルを書き換えた後は，`aerospace reload-config`（または `Option + R` → `C`）を実行してください．

---

## メニューバーのワークスペース表示 (AeroSpaceBar)

ワークスペース表示には [AeroSpaceBar](https://github.com/rdrkr/AeroSpaceBar) (cask `aerospacebar`，tap `rdrkr/tap`) を使います．標準メニューバーの左半分を透明パネルで覆って描画するため，メニューバーが2段になりません．

- **モニタ**: `Settings → Spaces → Show Spaces On` を `All Displays` にすると全モニタに出ます．ただしワークスペースをモニタごとに絞る機能はなく，全バーが同じ一覧を表示します．選択は TOML ではなく UUID でローカル保存されます．
- **アプリメニューが隠れる件**: `fn` (Globe) を押しながらメニューバーにマウスを乗せている間だけ表示が消えて，標準のアプリメニューが見えます (Quick Hide，`quick-hide-trigger-key = 'fn'`)．
- **設定の置き場**: アプリ自身が `~/.config/aerospacebar/aerospacebar.toml` を書き換えるため，Nix の読み取り専用リンクにはせず手動管理にしています．
- **自動起動**: AeroSpace 側からは起動されないので，AeroSpaceBar の `Launch at Login` はオンにしておきます (macOS は同一アプリを二重起動しません)．
- 以前使っていた SketchyBar は，メニューバーの下に1行増えて画面を圧迫するため廃止しました．

---

## 関連ファイル

| ファイル | 役割 |
| :--- | :--- |
| `modules/wm/aerospace/default.nix` | LaunchAgentの定義とシンボリックリンク配線 |
| `modules/wm/aerospace/aerospace.toml` | AeroSpace の設定ファイル本体 (キーマップ・レイアウト・gaps) |
| `modules/wm/aerospace/launch-borders.sh` | JankyBordersの起動・matugen配色連携スクリプト |
| `modules/theming/matugen/mac/wallpaper-pick-popup.sh` | Raycast 壁紙ピッカーの起動スクリプト |
| `modules/theming/matugen/mac/raycast-wallpaper-picker/` | Raycast グリッド拡張機能本体 |
