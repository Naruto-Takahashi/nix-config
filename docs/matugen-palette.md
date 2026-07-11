# Matugen パレット — 色の名前と用途

壁紙から matugen で抽出・生成される動的パレットの一覧。
`yasb-theme` (WSL: `~/.local/bin/yasb-theme`) が壁紙変更のたびに
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

- 色相回転 (`complement` / `triad`) は `yasb-theme.sh` 内の Python (colorsys) で
  HLS の H だけ回して計算する。明度・彩度は accent と同じなのでパレットに馴染む。
- 各設定にはファイルが無い環境用のフォールバック値がハードコードされている
  (`nvim/lua/matugen.lua`, wezterm.nix の colors テーブルなど)。

## 用途の割り当て

| 場所 | accent | secondary | tertiary | complement | triad |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Starship** | ディレクトリ地 / git 文字 | 左端ブロック (OSロゴ/PS) | — | — | — |
| **WezTerm タブ** | アクティブタブ | — | カーソル色 | — | — |
| **lualine** | Normal モード | 左端ブロック (Normal時) | Insert モード | Visual モード | — |
| **yazi ステータスバー** | Normal モード | 左端ブロック (Normal時) | — | Select モード | — |
| **yazi ファイル色** | — | フォルダ名/アイコン | ドキュメント・テキスト系 | スクリプト・メディア系 | Web・データ系 |
| **nvim タブライン** | アクティブタブ | — | — | — | — |
| **nvim ダッシュボード** | メニューアイコン | ロゴ / メニュー文字 / 起動メッセージ | キー割当 (f, r...) | — | — |
| **Neo-tree** | — | フォルダ名/アイコン | — | — | — |
| **komorebi 枠** | single / floating | — | monocle (ALT+F) | — | — |
| **YASB** | フォーカス島 / アクティブWS | — | cava 波形 / 空WSドット | — | — |

補足:
- Insert/Visual などモード変化時、lualine / yazi の左端ブロックは
  「モード色を白へ 40% 寄せたパステル版」になる (Normal の secondary と同じ関係)。
- 赤系 (Replace モード、yazi のコンパイル言語/アーカイブ、Quit) は matugen の
  `error` 色または固定 `#c4746e` を使用。

## 反映の仕組み

同じパレットを 2 つのホストで別の経路で反映している。

### WSL (Windows / komorebi + YASB)

中核は `modules/wm/yasb/matugen/yasb-theme.sh`
(home-manager が `~/.local/bin/yasb-theme` へ配置。**store ファイルなので
編集後は `home-manager switch` が必要**)。

```
壁紙変更 (YASB wallpapers ウィジェットの run_after)
  → yasb-theme <image>
     1. matugen image <壁紙> -c ~/.config/yasb/matugen/config.toml
        → テンプレート palette.css から ~/.cache/matugen/yasb-palette.css を生成
          (matugen が作るのはこの CSS 1枚だけ)
     2. yasb-theme が palette.css を読み、各アプリ向けに自前で展開する:
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
- `sync-win` は設定コピー後に必ず `yasb-theme --reapply` を呼ぶ。
  raw コピーはフォールバック色に戻ってしまうため、**手動で /mnt/c へコピーした場合も
  必ず reapply を実行する**こと。
- `--reapply` は `~/.cache/matugen/last-wallpaper` に記録された前回の壁紙から
  フル再生成する (テンプレート更新も反映される)。

### NixOS (Hyprland)

こちらは matugen の**テンプレート機能と post_hook に全部任せる**構成
(`modules/wm/hyprland/config/matugen/config.toml`)。

```
壁紙変更 (rofi の壁紙ピッカー wppicker.sh)
  → matugen image <壁紙>
     - [config.wallpaper] で awww により壁紙も matugen が設定
     - [templates.*] で各アプリの設定を直接生成 + post_hook で即時リロード:
       waybar (SIGUSR2) / kitty (SIGUSR1) / hyprland (hyprctl reload) /
       cava (SIGUSR1) / gtk3・gtk4 / rofi / spicetify / vesktop /
       starship / wezterm / colors.lua (nvim・yazi) / lazygit / fzf
  → wppicker.sh が colors.lua に complement を追記
     (matugen テンプレートは色相回転ができないため、WSL と同じ Python 計算を後付け)
```

### 2経路の違いまとめ

| | WSL | NixOS |
| :--- | :--- | :--- |
| matugen の役割 | palette.css を1枚生成するだけ | 全テンプレート生成 + post_hook |
| 展開ロジック | yasb-theme.sh (bash) に集約 | matugen config.toml に宣言 |
| 色相回転色 | yasb-theme 内で計算 | wppicker.sh が後付け追記 |
| 反映先が Windows | あり (/mnt/c へ配置 + sed) | なし |

新しいアプリを追従させたいときは、WSL なら yasb-theme.sh にセクションを足し、
NixOS なら templates/ にテンプレートを足して config.toml に登録する。
