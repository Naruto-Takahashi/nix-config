# ドキュメント索引

リポジトリ内の全ドキュメントの索引です。各ツールの解説は、そのツールのフォルダにある `README.md` (コードの隣) に置いています。このディレクトリ自体には、セットアップ手順書と複数ツールにまたがる文書だけがあります。「どのOSで使えるか」は[メインREADMEの対応表](../README.md#どれがどのOSで動くか-対応表)も参照してください。

## セットアップ

| ドキュメント | 内容 |
| :--- | :--- |
| [setup-nixos.md](setup-nixos.md) | NixOSへの導入手順 (Tailscale + Sunshine リモートデスクトップ設定を含む) |
| [setup-wsl.md](setup-wsl.md) | WSL2への導入手順 |
| [setup-mac.md](setup-mac.md) | macOSへの導入手順 (TCC/SIP関連の手動作業を含む) |
| [setup-distrobox.md](setup-distrobox.md) | sudo無し共有Linuxホストへの導入手順 (rootless podman/distroboxコンテナ内にNixを構築) |

## ウィンドウマネージャー・キーリマップ

| ドキュメント | 内容 |
| :--- | :--- |
| [hyprland.md](../modules/wm/hyprland/README.md) | NixOS: Hyprland (Wayland) のキーバインド |
| [komorebi.md](../modules/wm/komorebi/README.md) | WSL2: komorebi + YASB (Windows側) のキーバインド |
| [aerospace.md](../modules/wm/aerospace/README.md) | macOS: AeroSpace のキーバインド・配色連携・壁紙ピッカー |
| [hammerspoon.md](../modules/wm/hammerspoon/README.md) | macOS: Hammerspoon によるトラックパッドジェスチャー (ワークスペース移動・ウィンドウ操作・コーナータップ) |
| [kanata.md](../modules/input/kanata/README.md) | 3ホスト共通のキーボードリマップ層 (SandS・IME切替・CapsLock改修)。OSごとの実装方式の違いもここに整理 |
| [karabiner](../modules/input/karabiner/README.md) | macOS: Karabiner-Elements によるキーボードリマップ (Esc・Caps・Command・Space / Option レイヤー)。HHKB のモードの注意も |

## 配色・テーマ

| ドキュメント | 内容 |
| :--- | :--- |
| [matugen-palette.md](../modules/theming/matugen/README.md) | 壁紙連動の動的配色 (Matugen) の仕組み・色の定義・各ホストのパイプライン |

## 共通アプリケーション

| ドキュメント | 内容 |
| :--- | :--- |
| [wezterm.md](../modules/gui/wezterm/README.md) | WezTerm の外観・キーバインド |
| [neovim.md](../modules/cli/neovim/README.md) | Neovim の設計方針・独自マクロ・操作チートシート |
| [yazi.md](../modules/cli/yazi/README.md) | Yazi の独自拡張 (rich-preview, compress)・操作チートシート |
| [cli-tools.md](cli-tools.md) | starship / atuin / tealdeer / fd / delta / eza / btop / smassh の使い方チートシート |
| [gitmoji.md](../modules/cli/git-hooks/README.md) | git commit へのgitmoji自動付与フック |

## その他の連携

| ドキュメント | 内容 |
| :--- | :--- |
| [obsidian-brain.md](../modules/services/README.md) | 全OS共通: Obsidianを日常管理・AIエージェントの外部脳として使う連携基盤 (`ob` CLI / 共通Skill / 自動Git同期) |
