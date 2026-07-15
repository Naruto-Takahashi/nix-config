# Matugen パレット — 色の名前と用途

壁紙から matugen で抽出・生成される動的パレットの一覧。
`matugen-apply` (WSL: `~/.local/bin/matugen-apply`) が壁紙変更のたびに
`~/.cache/matugen/colors.lua` へ書き出し、各アプリがそこから読む。

## 色の定義

| 名前 | 由来 | 説明 |
| :--- | :--- | :--- |
| `accent` | Material **primary** | メインハイライト。最も目立つ色 |
| `secondary` | Material **secondary** | 2番めの色。accent より落ち着いた同系統 |
| `tertiary` | Material **tertiary** | 3番めの色。旧名 `accent_sub` |
| `complement` | accent の**色相 180° 回転** (計算生成) | 補色。どんな壁紙でも accent から最も遠い色相になる。旧名 `visual` |
| `triad` | accent の**色相 120° 回転** (計算生成) | トライアド。accent / complement と色相環上で均等に散らばる |
| `text` | Material on_surface | 本文の文字色 (落ち着いた白) |
| `muted` | Material on_surface_variant | 控えめな文字色 (薄いグレー系) |
| `surface` | Material surface_container_high | 暗色セグメントの地 (黒ブロック) |
| `on_accent` | Material surface | accent 等の明色地に載せる暗い文字色 |

- 色相回転 (`complement` / `triad`) は HLS の H だけ回して計算する
  (彩度は accent の 0.75 倍に抑える)。明度は accent と同じなのでパレットに馴染む。
  NixOS は `modules/theming/matugen/lib/derive-colors.py` に実装が集約されている
  (WSL は現状 `matugen-apply.sh` 内に同じ式が独立実装として残っている。後述)。
- 各設定にはファイルが無い環境用のフォールバック値がハードコードされている
  (`nvim/lua/matugen.lua`, wezterm.nix の colors テーブルなど)。
- **既知の未解消ドリフト** (今回のNixOS側共通化では未着手):
  - `accent_pale`（装飾ブロック用のパステル色）の定義が WSL と NixOS で異なる。
    WSL は accent を白へ 40% ブレンドした Python 計算値、NixOS の starship
    テンプレートは Material `primary_container` をそのまま使っている。別の色になる。
  - wezterm 配色パレットのキー数が WSL (11キー、colors.lua と同一) と NixOS
    (`[templates.wezterm]`、7キーのみ) でズレている。現状 wezterm.lua は7キー
    しか読んでいないため症状は出ていないが、将来 complement/error 等を使う
    設定を足すと NixOS だけ nil になる。

## 用途の割り当て

| 場所 | accent | secondary | tertiary | complement | triad |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Starship** | ディレクトリ地 / git 文字 | 左端ブロック (OSロゴ/PS) | — | — | — |
| **WezTerm タブ** | アクティブタブ | — | カーソル色 | — | — |
| **lualine** | Normal モード | 左端ブロック (Normal時) | Insert モード | Visual モード | — |
| **yazi ステータスバー** | Normal モード | 左端ブロック (Normal時) | — | Select モード | — |
| **yazi ファイル色** | — | フォルダ名/アイコン | ドキュメント・テキスト系 | スクリプト・メディア系 | Web・データ系 |
| **nvim タブライン** | アクティブタブ | — | — | — | — |
| **nvim ダッシュボード** | メニューアイコン | ロゴ / 起動メッセージ | キー割当 (f, r...) | — | — |
| **Neo-tree** | — | フォルダ名/アイコン | — | — | — |
| **komorebi 枠** | single / floating | — | monocle (ALT+F) | — | — |
| **lazygit** | アクティブ枠 | — | 検索枠 / オプション文字 | チェリーピック文字 | — |
| **YASB** | フォーカス島 / アクティブWS | — | cava 波形 / 空WSドット | — | — |

補足:
- Insert/Visual などモード変化時、lualine / yazi の左端ブロックは
  「モード色を白へ 40% 寄せたパステル版」になる (Normal の secondary と同じ関係)。
- 赤系 (Replace モード、yazi のコンパイル言語/アーカイブ、lazygit の未ステージ、Quit) は
  matugen の `error` 色 (colors.lua にも出力) または固定 `#c4746e` を使用。
- komorebi の unfocused 枠は matugen の outline トーン、yazi のフルボーダーは
  muted と surface の中間色 (実行時合成)、nvim のメニュー文字は text。

## 反映の仕組み

同じパレットを 2 つのホストで別の経路で反映している。

### WSL (Windows / komorebi + YASB)

中核は `modules/wm/yasb/matugen/matugen-apply.sh`
(home-manager が `~/.local/bin/matugen-apply` として mkOutOfStoreSymlink 配置。
リポジトリを編集すればそのまま反映され、switch は不要)。

```
壁紙変更 (YASB wallpapers ウィジェットの run_after)
  → matugen-apply <image>
     1. matugen image <壁紙> -c ~/.config/yasb/matugen/config.toml
        → テンプレート palette.css から ~/.cache/matugen/yasb-palette.css を生成
          (matugen が作るのはこの CSS 1枚だけ)
     2. matugen-apply が palette.css を読み、各アプリ向けに自前で展開する:
        - YASB styles.css   : MATUGEN マーカー間を差し替えて /mnt/c へ配置
        - cava              : config.yaml 内の色を sed (inode 保持で watch_config を維持)
        - starship          : palettes.matugen ブロックを awk で差し替え
                              (~/.cache 用と、os_logo を除去した Windows 用の2種)
        - colors.lua        : nvim / yazi / wezterm 共通の Lua パレット
                              (complement / triad はここで Python により色相回転で計算)
        - lazygit / fzf     : 設定ファイルを丸ごと生成
        - yazi theme.toml   : theme-template.toml の @@プレースホルダ@@ を sed で置換
        - komorebi.json     : 枠色 (single/floating/monocle) を sed → reload
```

- 各アプリの反映タイミング: YASB はファイル監視 (watch_config/watch_stylesheet) で即時、
  WezTerm は自動リロードで即時、nvim / yazi / starship / lazygit / fzf は次回起動時。
- `sync-win` は設定コピー後に必ず `matugen-apply --reapply` を呼ぶ。
  raw コピーはフォールバック色に戻ってしまうため、**手動で /mnt/c へコピーした場合も
  必ず reapply を実行する**こと。
- `--reapply` は `~/.cache/matugen/last-wallpaper` に記録された前回の壁紙から
  フル再生成する (テンプレート更新も反映される)。

### NixOS (Hyprland)

matugen の**テンプレート機能と post_hook**で完結するもの
(`modules/wm/hyprland/config/matugen/config.toml`) と、色相回転が必要で
matugen 単体では作れないものを分けている。後者は WSL/NixOS 共通モジュール
`modules/theming/matugen/`（後述）に実装が集約されている。

```
壁紙変更 (rofi の壁紙ピッカー wppicker.sh)
  → matugen image <壁紙>
     - [config.wallpaper] で awww により壁紙も matugen が設定
     - [templates.*] で各アプリの設定を直接生成 + post_hook で即時リロード:
       waybar (SIGUSR2) / kitty (SIGUSR1) / hyprland (hyprctl reload) /
       cava (SIGUSR1) / gtk3・gtk4 / rofi / spicetify / vesktop /
       starship / wezterm / colors.lua (nvim・yazi の基本7キー) / fzf
  → wppicker.sh が modules/theming/matugen/lib/ の共通スクリプトを呼ぶ:
     1. derive-colors.py が colors.lua に complement/triad を追記
     2. render-template.sh が yazi theme.toml と lazygit-config.yml を
        (colors.lua の値で @@プレースホルダ@@ を埋めて) 生成する
```

### 共通モジュール `modules/theming/matugen/`

派生色計算 (`lib/derive-colors.py`) とテンプレート後処理
(`lib/render-template.sh`、汎用の `@@KEY@@` 置換エンジン) を1箇所にまとめた
WM非依存のモジュール。`profiles/base.nix` から全ホスト共通で import され、
`~/.config/matugen-common/{lib,templates}` に mkOutOfStoreSymlink 配置される
(python3 の依存もこのモジュール自身が `home.packages` で宣言する)。

- 対象は yazi theme.toml / lazygit-config.yml の生成のみ（`@@プレースホルダ@@`
  + 色相回転が両方必要なもの）。fzf は matugen 本体のテンプレート機能だけで
  完結しているため対象外。starship / wezterm も対象外（上記の既知ドリフト参照）。
- **現状 NixOS 側 (`wppicker.sh`) のみがこの共通モジュールを呼んでいる。
  WSL 側 (`matugen-apply.sh`) はまだ独自実装（複製元と同じ式）のまま**で、
  この共通モジュールへの移行は未着手。新しいアプリを yazi/lazygit 的な
  「色相回転＋テンプレート」で追従させたいときは、
  `modules/theming/matugen/templates/` にテンプレートを足し、
  `wppicker.sh` (と将来的には `matugen-apply.sh`) から
  `render-template.sh` を1行呼べばよい。

### 2経路の違いまとめ

| | WSL | NixOS |
| :--- | :--- | :--- |
| matugen の役割 | palette.css を1枚生成するだけ | 全テンプレート生成 + post_hook |
| 展開ロジック | matugen-apply.sh (bash) に集約 | matugen config.toml + 共通モジュール |
| 色相回転・プレースホルダ後処理 | matugen-apply 内で独自実装 | `modules/theming/matugen/lib/` (共通) |
| 反映先が Windows | あり (/mnt/c へ配置 + sed) | なし |

新しいアプリを追従させたいときは、Material role の参照だけで足りるなら
WSL は matugen-apply.sh に palette.css からの抽出を足し、NixOS は
`config.toml` にネイティブ `[templates.x]` を足すだけでよい。色相回転が
必要なら、NixOS は `modules/theming/matugen/` にテンプレートを足すだけで
済む（WSL は今のところ手動で追従が必要）。
