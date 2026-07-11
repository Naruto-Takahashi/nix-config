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

## 生成の流れ

```
壁紙変更 (YASB wallpapers ウィジェット)
  → yasb-theme <image>
    → matugen が ~/.cache/matugen/yasb-palette.css を生成 (palette.css テンプレート)
    → colors.lua / starship.toml / lazygit / fzf / yazi theme.toml などへ配色を展開
    → Windows 側 (styles.css, config.yaml, komorebi.json, starship.toml) にも配置
```

`sync-win` は最後に `yasb-theme --reapply` を呼ぶため、設定を書き換えて同期すれば
常に最新パレットが再適用される。
