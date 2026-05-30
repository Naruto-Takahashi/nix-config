# 🗔 GlazeWM ウィンドウマネージャ設定・キーバインド詳細

このドキュメントでは，Windows環境においてタイル型ウィンドウマネージャを実現する **GlazeWM** の基本設計，こだわり設定，および詳細なキーバインドについて解説します．

---

## 🎨 特徴とこだわり設定 (Design & Features)

* **Windowsでのタイル型環境の実現**: Linuxの `i3wm` の思想をWindows上でシームレスに再現し，マウスフリーな超高速キーボード駆動環境を提供します．
* **Zebarとのシームレスな統合**: ステータスバーとして `Zebar`（カスタム仕様のvanilla-clearテーマ）を組み合わせ，無駄のない洗練されたアイランドスタイルの美しいデスクトップを構築しています．
* **自動スペース確保**: Zebarの表示領域を考慮し，自動で画面上部のスペースを確保する高度なレイアウト設計となっています．
* **一時停止モードの完備**: ゲームや特定のWindowsネイティブアプリを使用する際，GlazeWMのキーバインドを一時的に無効化できる「一時停止モード」を搭載しています．

---

## ⌨️ キーバインド・操作ショートカット

GlazeWMの操作は，主に **`Alt`** キーをベースにした直感的かつ機能的なショートカットで制御します．

### 1. 一般操作 (General Control)

| キーバインド | コマンド | 動作内容 |
| :--- | :--- | :--- |
| **`Alt + H`** / **`Alt + Left`** | `focus --direction left` | 左のウィンドウにフォーカス移動 |
| **`Alt + L`** / **`Alt + Right`** | `focus --direction right` | 右のウィンドウにフォーカス移動 |
| **`Alt + K`** / **`Alt + Up`** | `focus --direction up` | 上のウィンドウにフォーカス移動 |
| **`Alt + J`** / **`Alt + Down`** | `focus --direction down` | 下のウィンドウにフォーカス移動 |
| **`Alt + Shift + H`** / **`Alt + Shift + Left`** | `move --direction left` | アクティブウィンドウを左へ移動 |
| **`Alt + Shift + L`** / **`Alt + Shift + Right`** | `move --direction right` | アクティブウィンドウを右へ移動 |
| **`Alt + Shift + K`** / **`Alt + Shift + Up`** | `move --direction up` | アクティブウィンドウを上へ移動 |
| **`Alt + Shift + J`** / **`Alt + Shift + Down`** | `move --direction down` | アクティブウィンドウを下へ移動 |
| **`Alt + U`** | `resize --width -2%` | ウィンドウの横幅を縮小 (-2%) |
| **`Alt + P`** | `resize --width +2%` | ウィンドウの横幅を拡大 (+2%) |
| **`Alt + O`** | `resize --height +2%` | ウィンドウの縦幅を拡大 (+2%) |
| **`Alt + I`** | `resize --height -2%` | ウィンドウの縦幅を縮小 (-2%) |
| **`Alt + R`** | `wm-enable-binding-mode --name resize` | **リサイズモード**に移行 |
| **`Alt + Shift + P`** | `wm-enable-binding-mode --name pause` | **一時停止モード**に移行 (全キーバインド無効化) |
| **`Alt + V`** | `toggle-tiling-direction` | タイリング方向の切り替え (水平 / 垂直) |
| **`Alt + Shift + Space`** | `toggle-floating --centered` | フローティングモード切り替え (中央配置) |
| **`Alt + T`** | `toggle-tiling` | タイリングモード切り替え |
| **`Alt + F`** | `toggle-fullscreen` | フルスクリーン切り替え |
| **`Alt + M`** | `toggle-minimized` | ウィンドウの最小化 |
| **`Alt + Shift + Q`** | `close` | アクティブウィンドウを閉じる |
| **`Alt + Shift + E`** | `wm-exit` | GlazeWMを終了 |
| **`Alt + Shift + R`** | `wm-reload-config` | 設定ファイルをリロード |
| **`Alt + Shift + W`** | `wm-redraw` | 全ウィンドウを再描画 |

---

### 2. ワークスペース管理 (Workspace Management)

仮想デスクトップをシームレスに行き来し，複数のタスクを効率よく整理するためのショートカットです．

| キーバインド | コマンド | 動作内容 |
| :--- | :--- | :--- |
| **`Alt + S`** | `focus --next-workspace` | 次のワークスペースへ移動 |
| **`Alt + A`** | `focus --prev-workspace` | 前のワークスペースへ移動 |
| **`Alt + D`** | `focus --recent-workspace` | 直前に開いていたワークスペースへ移動 |
| **`Alt + [1-9]`** | `focus --workspace [1-9]` | 指定した番号 (1〜9) のワークスペースへ切り替え |
| **`Alt + Shift + A`** | `move-workspace --direction left` | ワークスペースを左のモニターへ移動 |
| **`Alt + Shift + F`** | `move-workspace --direction right` | ワークスペースを右のモニターへ移動 |
| **`Alt + Shift + D`** | `move-workspace --direction up` | ワークスペースを上のモニターへ移動 |
| **`Alt + Shift + S`** | `move-workspace --direction down` | ワークスペースを下のモニターへ移動 |
| **`Alt + Shift + [1-9]`** | `move --workspace [1-9]` | ウィンドウを指定番号のワークスペースへ移動し追従 |

---

### 3. 特殊バインディングモード (Binding Modes)

特定の操作を効率的に行うための切り替えモードです．

#### A. リサイズモード (`Alt + R`)

リサイズモードに移行すると，以下のキーを単体で入力するだけで，ウィンドウサイズを細かく調整できます．**`Escape`** または **`Enter`** でリサイズモードを終了します．

| キー | コマンド | 動作内容 |
| :---: | :--- | :--- |
| **`H`** / **`Left`** | `resize --width -2%` | 幅を縮小する |
| **`L`** / **`Right`** | `resize --width +2%` | 幅を拡大する |
| **`K`** / **`Up`** | `resize --height +2%` | 高さを拡大する |
| **`J`** / **`Down`** | `resize --height -2%` | 高さを縮小する |
| **`Escape`** / **`Enter`** | `wm-disable-binding-mode` | リサイズモードを終了 |

#### B. 一時停止モード (`Alt + Shift + P`)

一時停止モードに入ると，GlazeWMのすべてのキーバインドが一時的に無効化され，Windows本来の標準ショートカット操作が行えるようになります．ゲームのプレイ中や，特定のネイティブアプリと競合する際に非常に便利です．

* **解除方法**: もう一度 **`Alt + Shift + P`** を入力することで一時停止モードを終了し，GlazeWMのタイル型環境へ戻ります．
