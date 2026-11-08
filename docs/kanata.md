# Kanata キーボードリマッパー設定・キーマップ詳細

このドキュメントでは、[modules/input/kanata/config.kbd](../modules/input/kanata/config.kbd) に定義されている Kanata デーモンの独自キーレイヤー設定および IME 統合動作について詳細に解説します。

## 対象OS・実装方式の違い (重要)

**Windows/WSL2環境では、kanataはWindows側でネイティブに動く別バイナリとして稼働します**（WSL上のプロセスはWindows側のキーボード入力を物理的に捕まえられないため、WSL内でkanataを動かすのではなく、Windows用にビルドされたkanataバイナリをWindows側で直接起動する構成)。従来はWindows専用の [AutoHotkeyスクリプト](../modules/input/ahk/main.ahk) がSandS/CapsLock/Alt-IME切り替えを独自実装していたが、AHKの `Key & Key` コンボ実装がキー状態を稀に取りこぼし「押されっぱなし」になる不具合があったため、その部分をkanataへ移行した(`modules/input/kanata/wsl.nix` / `wsl-config.nix`)。AHK側の実装は削除せず、kanata稼働中は自動的に無効化される形で残してあり(`main.ahk`の`KanataActive()`)、kanataのプロセスを終了するだけで即座にAHK実装へロールバックできる。komorebi固有のWMショートカット(Alt+文字)は元々AHK側で素のAlt修飾として直接実装されているため変更していない。

Kanataを使う3ホストの間で、レイヤー定義 (`config.kbd`) は共通の1ファイルです。ホストごとに変わる「信号」(WM修飾子・Alt+Space/Tab・Undo など) は、`config.kbd` 内の `(platform (macos) ...)` / `(platform (linux) ...)` / `(platform (win winiov2 wintercept) ...)` と `deftemplate` (`wm-aliases`) で **kanata 自身が実行時に解決**します。Nix 側の文字列置換は、物理配列など構造そのものが違う部分にだけ残しています。

| ホスト | WM修飾子 (`wm-aliases` の `p`) | 連携するWM | 備考 |
| :--- | :--- | :--- | :--- |
| **NixOS** | `M-` (Super単体) | Hyprland ([hyprland.md](hyprland.md)) | `modules/input/kanata/linux-config.nix` は `eisu`/`kana` → `muhenkan`/`henkan` のみ置換 |
| **macOS** | `C-M-` (Ctrl+Cmd) | AeroSpace ([aerospace.nix](../modules/wm/aerospace/default.nix)) | macOS標準の`Cmd`単体ショートカットと衝突しないよう二重修飾にしている |
| **WSL** | `A-` (Alt単体) | komorebi ([komorebi.md](komorebi.md)) | `modules/input/kanata/wsl-config.nix`。既存のAHK側 `!` (Alt) ホットキー群と同じ信号になるためkomorebi.ahk側は無変更で動く |

`wm-aliases` の引数 (`p close dact tabact cp`) のホスト別の値:

| 引数 | macOS | NixOS | WSL | 意味 |
| :--- | :--- | :--- | :--- | :--- |
| `p` | `C-M-` | `M-` | `A-` | 通常のWM修飾子 |
| `close` | `S-w` | `S-w` | `S-q` | Alt+q の信号 (macOSは Cmd+Shift+Q=ログアウト衝突回避で w にずらす) |
| `dact` | `A-spc` | `M-d` | `A-spc` | Alt+Space (macOS/WindowsはOS標準のAlt+Spaceを通す) |
| `tabact` | `A-tab` | `M-tab` | `_` | Alt+Tab ([Alt-Tab](https://alt-tab-macos.netlify.app/)連携 / WindowsはOS標準) |
| `cp` | `C-M-A-` | `M-A-` | `C-A-` | alt-ctrl-layer (join-with) 用 |

Ctrl長押しは全ホスト共通で素の `lctl` です (以前 macOS にあった Ctrl→Cmd 変換レイヤー `ctrl-layer` は、ターミナルの Ctrl+C 等を潰すため廃止)。Nav レイヤーの `U` (Undo) は macOS だけ `M-z` (Cmd+Z)、他は `C-z` です。

WSLはさらに以下の点が個別の置換で上書きされています（`wsl-config.nix`）:
- `caps` → `f13` (本機はレジストリのScancode MapでCapsLock物理キーをF13として送出する設定にしているため)
- `eisu`/`kana` → `@ime-off`/`@ime-on` (Win32 API (`ImmSetOpenStatus`) 経由のIME制御はkanata単体ではWindows上で直接行えないため、`cmd`アクションで実績のあるAHKの`ime_functions.ahk` (`ime-off.ahk`/`ime-on.ahk`) へ委譲する。`danger-enable-cmd`が必要)
- Alt長押しのhold動作を `(multi 実キー (layer-while-held alt-layer))` に変更 (OS標準のAlt+Tab連続切り替えのため)

macOSはさらに以下の点が個別の置換で上書きされています（`modules/input/kanata/mac-config.nix`）。いずれも物理配列の列数が違うための構造差分です:
- デバイス指定に内蔵キーボード・Keychronを追加
- `defsrc` と各レイヤーに左右Command (`lmet`/`rmet`) の列を追加し、Command単押しで英数/かな、左右Option長押しで `alt-layer`
- 最下段の物理左Controlを `@whisper` (`rctl`) に割り当て、Superwhisper 録音キーとして使用 (CapsLockは通常の `lctl` のまま維持され録音は反応しない。FnキーはmacOS標準機能として開放。Nav レイヤーの Space+D とも併用可能)

検証手順: `kanata --check --cfg <生成した設定>` で構文を確認できます (WSL用は `cmd` 機能付きのkanataが必要)。`platform` は一致しないOSの枝を評価しないため、NixOS/WSL向けの変更は各ホストで確認してください。

下記の「2. 窓操作の最適化」セクションの表は `Super + ...` の**NixOS向けの表記**です。macOSでは同じキー入力が `Ctrl+Cmd + ...` に変換されます。

---

## 特徴的な独自仕様 (Core Concepts)

Kanata をバックグラウンドサービスとして稼働させることで、**OS依存・WM依存のない、あらゆる環境で完全に統一されたキー体験** を実現します。
特に、**「キーボードのホームポジション（手を置く基本位置）から一切手を動かさない」** ことを極限まで追求したキーマッピング設計になっています。

---

## 1. ホームポジション専用：SandS & Vimナビゲーション (Nav-Layer)

スペースキー長押しによって、キーボードが瞬時に「超高速カーソル操作・テキスト編集レイヤー」へと変貌します（SandS: Space and Shift）。

* **スペース単押し**: 通常通り `スペース` を入力します。
* **スペース長押し (Hold) + 他のキー**: ナビゲーションレイヤーへ移行します。

### スペース長押し中のキーマッピング一覧

| キー | 割り当てられた操作 | 説明 |
| :---: | :---: | :--- |
| **`H`** | **`Left` (←)** | 左に1文字移動 (Vimスタイル) |
| **`J`** | **`Down` (↓)** | 下に1行移動 (Vimスタイル) |
| **`K`** | **`Up` (↑)** | 上に1行移動 (Vimスタイル) |
| **`L`** | **`Right` (→)** | 右に1文字移動 (Vimスタイル) |
| **`A`** | **`Home`** | 行頭（一番左）にジャンプ |
| **`E`** | **`End`** | 行末（一番右）にジャンプ |
| **`U`** | **`Ctrl + Z`** (macOSは `Cmd + Z`) | 直前の操作を取り消す (**Undo / 元に戻す**) |
| **`B`** | **`Backspace`** | 1文字左側を削除する (**バックスペース**) |
| **`X`** | **`Delete`** | 1文字右側（カーソル上）を削除する (**デリート**) |

---

## 2. 窓操作の最適化：Alt長押し連携 (Alt-Layer)

左右の `Alt` キーを長押ししながらアルファベットを押すことで、ウィンドウ操作機能を `Alt` キー単体の修飾で発動させることができます（裏側で自動的に `Super`／macOSでは`Ctrl+Cmd`と組み合わせた信号に変換しています。変換ルールは前述の「対象OS・実装方式の違い」参照）。

* **Alt単押し**: IMEのオン/オフ切り替え（以下参照）。
* **Alt長押し (Hold) + 他のキー**: Altレイヤー（ウィンドウ操作層）へ移行します。

### Alt長押し中のキーマッピング一覧

このレイヤーが送信する**信号自体**は3ホスト共通ですが、その信号にWM側が何を割り当てるかはホストごと・時期によって独立して変わりうるため、**発動するアクションの正はホストごとのドキュメントを見てください**：NixOSは[hyprland.md](hyprland.md)、macOSは[aerospace.md](aerospace.md)、WSLは[komorebi.md](komorebi.md) (WSLはKanataではなくAutoHotkeyの独自実装なので、下表の信号とは無関係にキーが割り当てられています)。

起動系のキー (`N`=Neovim、`Y`=Yazi、`V`=Vivaldi) は3ホストで意味が揃うように統一済みです。`D`と`B`は逆に「無理に意味を揃えない」方針にしており、`B`はどのホストでも未使用，`D`はホストごとに個別の(既存の別キーと重複する)動作のままにしています。

| キー | 実際に送信される信号 |
| :---: | :--- |
| **`SPACE`** | `Super + D` |
| **`T`** | `Super + Shift + Space` |
| **`D`** | `Super + T` |
| **`Return`** | `Super + Enter` |
| **`TAB`** | `Super + Tab` |
| **`Q`** | `Super + Shift + W` |
| **`F`** | `Super + F` |
| **`V`** | `Super + V` |
| **`M`** | `Super + M` |
| **`H / J / K / L`** | `Super + HJKL` |
| **`U / I / O / P`** | `Super + UIOP` |
| **`S / A`** | `Super + S / A` |
| **`[1~9]`** | `Super + [1~9]` |

---

## 3. Mac風・快適日本語入力 (IME Integration)

左右のキー単押し（タップ）に、快適な日本語入力切り替え（英数 / かな）をバインドしています。

* **macOS実機 (US配列)**:
  * **左Command単押し (Tap)**: IMEを **オフ（英語入力: eisu）** に変更します。
  * **右Command単押し (Tap)**: IMEを **オン（日本語入力: kana）** に変更します。
  * **Command長押し・同時押し (Hold)**: 通常の **Command** キー（コピペ等のmacOS標準ショートカット）として機能します。
  * **左右Option (Alt) 長押し**: `Alt-Layer`（AeroSpaceウィンドウ操作層）として機能します。
* **WSL / Linux環境**:
  * **左Alt単押し (Tap)**: IMEを **オフ（英語入力）** に変更します。
  * **右Alt単押し (Tap)**: IMEを **オン（日本語入力）** に変更します。
  * **長押し時 (Hold)**: `Alt-Layer` ウィンドウ操作ショートカット用の修飾キーとして機能します。

これにより、現在の入力状態を気にすることなく、「日本語を書きたいときは右Altを叩いてから打つ」「英語を書きたいときは左Altを叩いてから打つ」という無意識かつストレスフリーなタイピングが可能です。

---

## 4. CapsLockの徹底改修 (Caps-to-Control)

普段ほとんど使用しないにもかかわらず、Aの横という特等席に配置されている `CapsLock` キーを、最も頻繁に使うキーへと変更します。

* **CapsLock単押し (Tap)**: **`Escape` (エスケープ)** として機能します。
* **CapsLock長押し (Hold)**: **`Left Control`** として機能します。

これによって、Vim などのノーマルモード移行（Escキー）がホームポジションから離れることなく行えるようになり、さらに `Ctrl + C` などのショートカットの入力負荷が劇的に低減します。

---

## 4.5 ファンクション行 (macOS のメディアキー)

macOS 内蔵キーボードの F1〜F12 は、単独押しで輝度・音量などのメディア機能を送ります。kanata が入力を横取りして仮想キーボード経由で再送すると、これが「素の F キー」になりメディア機能が失われる (F11 でデスクトップ表示になる) ため、macOS だけ明示的に割り当てています (`config.kbd` の `fkeys` テンプレート)。

| キー | macOS | Linux / WSL |
| :---: | :--- | :--- |
| F1 / F2 | 輝度 下げ / 上げ (`brdn` / `brup`) | 素の F1 / F2 |
| F3 / F4 | Mission Control / Launchpad (`mctl` / `lpad`) | 素の F3 / F4 |
| F5 / F6 | 素の F5 / F6 | 素の F5 / F6 |
| F7 / F8 / F9 | 前の曲 / 再生・停止 / 次の曲 (`prev` / `pp` / `next`) | 素の F7 / F8 / F9 |
| F10 / F11 / F12 | ミュート / 音量 下げ / 上げ (`mute` / `vold` / `volu`) | 素の F10 / F11 / F12 |

**Fn 併用で本来の F キー (macOS)**: Fn を押している間だけ `fnrow` レイヤーが有効になり、F1〜F12 が素の F キーを送ります (`config.kbd` 末尾の `(platform (macos) ...)`)。Fn キー自体も `(multi fn (layer-while-held fnrow))` で素通しします。

- 物理配列の差分なので、`fn` 列は `mac-config.nix` が defsrc と各レイヤーの F 行末尾に追加します (`config.kbd` の `;; frow-*` コメントが置換の目印)。
- **実機確認が必要**: kanata が Apple 内蔵キーボードの Fn を検知・再送できるかは設定の検証だけでは分かりません。Fn+F11 が効かない場合は検知できていないので、`fn` 列の追加を外してください。Globe キー単体 (絵文字ピッカー等) が効かなくなる場合も同様です。

---

## 5. Windows専用の補完: AutoHotkey (modules/input/ahk)

kanataはクロスプラットフォームだが，WezTermとの連携やExplorer統合(Everything検索)等，kanataだけでは実現できない機能があるため，`modules/input/ahk/main.ahk` をAutoHotkeyの実行ファイルとして併用している。役割としてはkanataと同じ「キーボードリマップ」層に属するため`modules/input/`配下に置いているが，実装はWindows専用。

* エントリポイントは `main.ahk` の1つのみ。komorebi固有のホットキー定義 (`modules/wm/komorebi/komorebi.ahk`、[komorebi.md](komorebi.md) 参照) はここから絶対パスで `#Include` される
* IME制御関数 (`ImmGetDefaultIMEWnd` 等のWin32 API呼び出し) は `modules/input/ahk/lib/ime_functions.ahk` に切り出している。kanataからも `cmd` アクション経由で `ime-off.ahk`/`ime-on.ahk` (同ライブラリを使う一発実行スクリプト) が呼ばれる
* `sync-win` が `~/.config/ahk` 配下をまるごと Windows の `Tools\Customization\` へコピーする
* SandS/CapsLock/Alt-IME切り替えの実装自体は上記の通りkanataへ移行済みだが、main.ahk側にも同等のコードを残してあり、kanataが起動していない間は自動的に有効化される (`KanataActive()`)。ロールバックはkanataのプロセスを終了するだけでよい

---

## 関連ファイル

| ファイル | 役割 |
| :--- | :--- |
| `modules/input/kanata/config.kbd` | レイヤー定義本体 (3ホスト共通) |
| `modules/input/kanata/linux-config.nix` | NixOS向け`eisu`/`kana`置換ロジック |
| `modules/input/kanata/mac-config.nix` | macOS向け物理配列まわりの置換ロジック |
| `modules/input/ahk/main.ahk` | WSL/Windows向けの別実装 |
