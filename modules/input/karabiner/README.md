# Karabiner-Elements キーリマップ設定・キー割り当て詳細

> **役割**: macOS (MacBook / Mac mini 共通) のキーボードリマップ。`~/.config/karabiner/karabiner.json` を Nix で生成する (Esc / Caps / Command / Control / Space レイヤー / Option レイヤー)
> **対象ホスト**: Mac
> **対になる実装**: [Kanata](../kanata/README.md) (NixOS / WSL。同じ `config.kbd`) / [AutoHotkey](../ahk/main.ahk) (WSL のフォールバック)。同じ役割の別実装なので、レイヤーを変えたら全部確認する
> **注意**: `karabiner.json` は Nix が配置する**読み取り専用リンク**。Karabiner の GUI では編集せず、[default.nix](default.nix) を直して `just switch` する。HHKB は**動作モード (Mac / Win) によって送るキーが変わる** (後述)

## 仕組み

[default.nix](default.nix) が、Karabiner の `complex_modifications` を組み立てて JSON にする。

- レイヤーは**変数**で表す (`alt_layer` = Option 押下中 / `altctrl` = その中で Control も押している間 / `nav` = Space 長押し中)。
- Karabiner は、**上に書いた規則が優先**される。並びは「上位のレイヤー → 下位のレイヤー → 単独のキー」にしてある。
- F1〜F12 は触らない (内蔵キーボードは macOS 標準で、メディアキーと、Fn 併用で素の F キーになる)。
- デバイスの抜き差し・再起動後の後付け接続は、Karabiner が自前で処理する。これが、Kanata から移行した理由 (Kanata は起動時にしかデバイスを掴まなかった)。

## キー割り当て

### 基本のキー

| キー | 単押し | 長押し・同時押し | 補足 |
| :--- | :--- | :--- | :--- |
| **Esc** | Esc + 英数 | (同じ) | 日本語入力中でも、Esc で確実に英数へ |
| **Caps Lock** (内蔵) | Esc + 英数 | **左 Control** | |
| **左 Command** | **英数** | 通常の Command | 単押しは、200 ミリ秒以内に離した場合だけ |
| **右 Command** | **かな** | 通常の Command | 同上 |
| **左下の Control** (内蔵) | (録音キー) | **右 Control** に変換 | Spokenly / Superwhisper の録音キー。Ctrl 操作は、Caps Lock の位置で行う |
| **左 Control** (外付け) | Esc + 英数 | 左 Control | 内蔵以外の全キーボードに適用。HHKB は Caps Lock の位置が Control のため |
| **変換 / 無変換** | 変換 → **かな** / 無変換 → **英数** | | HHKB の Windows モード用 (後述) |

### Space レイヤー (Space を押したまま)

Space 単押しは、普通のスペース。他のキーと一緒に押すとレイヤーになる (`tap-hold` と同じ判定)。

| キー | 動作 | キー | 動作 |
| :--- | :--- | :--- | :--- |
| **H / J / K / L** | ← ↓ ↑ → | **A** | Home |
| **E** | End | **U** | Undo (Cmd + Z) |
| **X** | Delete (前方削除) | **B** | Backspace |
| **D** | 右 Control (録音キー) | | |

### Option レイヤー (Option を押したまま。ウィンドウ操作)

Option 自体は OS に送らない。押したキーを **Ctrl + Cmd + (同じキー)** に変換して、[AeroSpace](../../wm/aerospace/README.md) に送る。

- **そのまま Ctrl + Cmd + キー**: 数字 `1`〜`9`、`` ` ``、`W E R Y U I O P`、`A S F`、`H J K L`、`C V B N M`、`,`、`/`、`Enter`、矢印キー
- **例外**:

  | キー | 送る信号 | 備考 |
  | :--- | :--- | :--- |
  | **Q** | Ctrl + Cmd + Shift + **W** | 閉じる。Cmd + Shift + Q はログアウトなので、避けて W にずらしている |
  | **T** | Ctrl + Cmd + Shift + Space | 浮動 / タイル切替 |
  | **D** | Ctrl + Cmd + **T** | タイリング復元 |
  | **Tab** | Option + Tab | AltTab アプリ連携 |
  | **Space** | Option + Space | Raycast など |

- Shift など他の修飾キーは、そのまま通す。
- 実際に、どの信号が、どの動作になるかは、[AeroSpace の README](../../wm/aerospace/README.md) を参照。

### Option + Control レイヤー

Option を先に押し続けて、Control (Caps Lock の位置、または内蔵の左下) を押している間。

| キー | 送る信号 | 用途 |
| :--- | :--- | :--- |
| **H / J / K / L** | Ctrl + Cmd + Option + (同じキー) | ウィンドウの結合 (join-with) |
| **Q** | Ctrl + Option + Shift + Q | Moonlight の切断 |

## デバイスごとの扱い

基本は、**全キーボードに同じ設定**を適用する。例外は次のとおり。

| 例外 | 内容 |
| :--- | :--- |
| 内蔵キーボード限定 | 左下の Control → 右 Control (`device_if`) |
| 内蔵キーボード以外 | 左 Control の単押しで Esc + 英数 (`device_unless`) |
| **Keychron Q11** | キーボードとポインティングデバイスを**兼ねる**ため、Karabiner が既定では掴まない。`devices` に `ignore = false` を明示している |

**Keychron Q11 で効かない接続方法があるとき**: 接続方法 (Bluetooth / USB / 2.4GHz) ごとに `product_id` が違う。次のコマンドで調べて、`default.nix` の `keychronProductIds` に足す。

```bash
"/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --list-connected-devices | jq -c '.[] | {product, vid: .device_identifiers.vendor_id, pid: .device_identifiers.product_id}'
```

## HHKB の注意

HHKB (Professional HYBRID / Type-S) は、**動作モード**によって、同じキーが送る信号が変わる。

| 動作モード | 左右の ◇ キー | Karabiner の規則 |
| :--- | :--- | :--- |
| **Mac モード** | Command | 「左右 Command」の規則 (左 = 英数、右 = かな) |
| **Win モード** | 左 = 無変換、右 = 変換 | 「変換 / 無変換」の規則 (無変換 → 英数、変換 → かな) |

どちらのモードでも、**左 = 英数、右 = かな**になる。

- モードは、底面の **DIP スイッチ** (電源を切って変更) で決まる。**Fn + Control + W / M** で、その場で切り替えることもできる。
- キーマップ変更ツールは、DIP スイッチのモードと違うモードには、書き込めない。
- CapsLock の位置を Control にしている場合、そのキーは `caps_lock` ではなく `left_control` として届く。このため、外付けキーボードの左 Control の規則が必要。
- 公式の取扱説明書: [Professional HYBRID (英語配列)](https://origin.pfultd.com/downloads/hhkb/manual/P3PC-6641-04.pdf) / [(日本語配列)](https://origin.pfultd.com/downloads/hhkb/manual/P3PC-6651-01.pdf)

## 変更の手順

1. [default.nix](default.nix) を編集する (新しいファイルを作ったら `git add`)。
2. `just lint` で検査する (終了コードで確認する)。
3. `just switch` で反映する。**Karabiner は、設定を自動で再読み込みする** (再起動は不要)。
4. **対になる実装を確認する**: [Kanata の `config.kbd`](../kanata/config.kbd) と [AutoHotkey](../ahk/main.ahk)。レイヤーの意味を変えたら、このドキュメントと [Kanata の README](../kanata/README.md) も直す。

初回の権限許可 (ドライバの機能拡張・入力監視・バックグラウンド項目) は、[docs/setup-mac.md](../../../docs/setup-mac.md) を参照。

## トラブルシュート

| 確認したいこと | 方法 |
| :--- | :--- |
| 設定が読み込まれたか | `grep "Load /" /var/log/karabiner/core_service.log \| tail -3` |
| キーボードを掴んでいるか | `grep grabbed /var/log/karabiner/core_service.log \| tail` |
| 接続中のキーボード | 上の `karabiner_cli --list-connected-devices` |
| 何のキーが届いているか | **Karabiner-EventViewer** (アプリ) の「Capture Input Events」 (Karabiner を通った**後**の出力) |
| 同じ結果になる経路の区別 | ◇ など1つのキーを、**他のキーと同時に押して**、フラグ (Command など) が付くかを見る。単押しだけでは区別できない |

### 設計上の落とし穴 (過去に踏んだもの)

- **Command の単押しは `lazy: true` が必須。** 無いと、単押しでも先に Command が押され、Cmd + 英数として届いて、macOS が IME を切り替えない。
- **Caps / Control の `from` は、他の修飾キーを許可する** (`modifiers.optional = ["any"]`)。許可しないと、Shift を先に押したときに、規則に当たらず、本物の Caps Lock が入る。
- **Keychron Q11 は `ignore = false` を明示しないと掴まれない** (上記)。
- **全キーボードに適用すると困るキーがある。** 左 Control → 右 Control を全キーボードに適用していたとき、HHKB の Control (Caps の位置) が右 Control になり、Spokenly が勝手に録音を始めた。
- **単押しの判定は 200 ミリ秒** (`basic.to_if_alone_timeout_milliseconds`)。これより長く押すと、単押しとして扱われない。
