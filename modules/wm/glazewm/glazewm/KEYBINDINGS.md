# GlazeWM キーバインド一覧

## 一般 (General)

| キー | コマンド | 説明 |
| :--- | :--- | :--- |
| `alt+h`, `alt+left` | `focus --direction left` | 左のウィンドウにフォーカス |
| `alt+l`, `alt+right` | `focus --direction right` | 右のウィンドウにフォーカス |
| `alt+k`, `alt+up` | `focus --direction up` | 上のウィンドウにフォーカス |
| `alt+j`, `alt+down` | `focus --direction down` | 下のウィンドウにフォーカス |
| `alt+shift+h`, `alt+shift+left` | `move --direction left` | ウィンドウを左に移動 |
| `alt+shift+l`, `alt+shift+right` | `move --direction right` | ウィンドウを右に移動 |
| `alt+shift+k`, `alt+shift+up` | `move --direction up` | ウィンドウを上に移動 |
| `alt+shift+j`, `alt+shift+down` | `move --direction down` | ウィンドウを下に移動 |
| `alt+u` | `resize --width -2%` | 幅を縮小 (-2%) |
| `alt+p` | `resize --width +2%` | 幅を拡大 (+2%) |
| `alt+o` | `resize --height +2%` | 高さを拡大 (+2%) |
| `alt+i` | `resize --height -2%` | 高さを縮小 (-2%) |
| `alt+r` | `wm-enable-binding-mode --name resize` | リサイズモードに入る |
| `alt+shift+p` | `wm-enable-binding-mode --name pause` | 一時停止モードに入る (全ショートカット無効化) |
| `alt+v` | `toggle-tiling-direction` | タイリング方向の切り替え (水平/垂直) |
| `alt+shift+space` | `toggle-floating --centered` | フローティングモード切替 (中央配置) |
| `alt+t` | `toggle-tiling` | タイリングモード切替 |
| `alt+f` | `toggle-fullscreen` | フルスクリーン切替 |
| `alt+m` | `toggle-minimized` | ウィンドウを最小化 |
| `alt+shift+q` | `close` | ウィンドウを閉じる |
| `alt+shift+e` | `wm-exit` | GlazeWMを終了 |
| `alt+shift+r` | `wm-reload-config` | 設定をリロード |
| `alt+shift+w` | `wm-redraw` | 全ウィンドウを再描画 |

## ワークスペース管理 (Workspace Management)

| キー | コマンド | 説明 |
| :--- | :--- | :--- |
| `alt+s` | `focus --next-workspace` | 次のワークスペースへ |
| `alt+a` | `focus --prev-workspace` | 前のワークスペースへ |
| `alt+d` | `focus --recent-workspace` | 直前のワークスペースへ |
| `alt+1` ... `alt+9` | `focus --workspace 1` ... | ワークスペース 1-9 へ切り替え |
| `alt+shift+a` | `move-workspace --direction left` | ワークスペースを左のモニターへ移動 |
| `alt+shift+f` | `move-workspace --direction right` | ワークスペースを右のモニターへ移動 |
| `alt+shift+d` | `move-workspace --direction up` | ワークスペースを上のモニターへ移動 |
| `alt+shift+s` | `move-workspace --direction down` | ワークスペースを下のモニターへ移動 |
| `alt+shift+1` ... `alt+shift+9` | `move --workspace 1`, `focus ...` | ウィンドウをワークスペース 1-9 へ移動して追従 |

## モード (Binding Modes)

### リサイズモード (`alt+r`)

| キー | コマンド | 説明 |
| :--- | :--- | :--- |
| `h`, `left` | `resize --width -2%` | 幅を縮める |
| `l`, `right` | `resize --width +2%` | 幅を広げる |
| `k`, `up` | `resize --height +2%` | 高さを広げる |
| `j`, `down` | `resize --height -2%` | 高さを縮める |
| `escape`, `enter` | `wm-disable-binding-mode ...` | リサイズモードを終了 |

### 一時停止モード (`alt+shift+p`)

| キー | コマンド | 説明 |
| :--- | :--- | :--- |
| `alt+shift+p` | `wm-disable-binding-mode ...` | 一時停止モードを終了 |