# =========================================================================
# Vivaldi 宣言的設定モジュール
# =========================================================================
{
  pkgs,
  ...
}:

let
  # --- air-zenify.css (外部CSS mod) ---
  # 出典: https://github.com/ELGUAPOLIFE/Zen-Theme-CSS-for-Vivaldi-Browser
  # (MohamedxSalah/Vivaldi-Air と PaRr0tBoY/Awesome-Vivaldi の派生)
  # Vivaldi 7.9+ のネイティブUI自動非表示機能を前提としたテーマ。
  # 本文をリポジトリに手でコピペせず、Nixのfetchurl (ハッシュ検証付き) で
  # 特定コミットから取得する。DynamicNeonTab.css (ネオン配色のタブ) は
  # 現在のmatugen連携の落ち着いた配色と合わないため採用していない。
  #
  # ⚠️ 運用ポリシー: AirZenify単体で運用し、自作CSSは持たない
  # (2026-10 に独自custom.cssを廃止。ガラス化の対象選定を公開テーマに任せ、
  # 見落とし探しを自前で抱えないため)。気になる不具合が出たら個別対処する。
  # rev はアップストリームの最新コミット (2026-05-27) を固定している。
  # 以下はVivaldi 8.1.4087時点でCDPにより確認した既知のセレクタ不一致で、
  # 廃止したcustom.css (git履歴に残る) で上書き修正していたもの。
  # 現在は修正せず受け入れている。個別対処の際の手がかりとして残す:
  #   1. `.auto-hide #browser ...` という子孫セレクタが実際は
  #      `#browser.auto-hide` (autoHideクラスは#browser自身に付与される)
  #      であるべきで一度もマッチしていない (自動非表示時に#webpage-stackの
  #      影付き内枠 box-shadow/margin が残る)
  #   2. `.unified-ui .auto-hide-wrapper` の transparent 指定が同名クラスの
  #      ガラス効果定義と詳細度が同じで後勝ちしてしまうケースがある
  #   3. 信号ボタン(.window-buttongroup)は#headerではなく常時opacity:1の
  #      #titlebarの子要素で、AirZenify本体はどちらの表示状態も制御しない
  #      (#titlebar の背景も transparent 固定)
  #   4. フローティングパネル有効時の実際のクラスは `.overlay` ではなく
  #      `.expanded` で、パネル本体 (.panel-group/#switch) のガラス効果が
  #      適用されない
  # rev/hashを更新する場合は、CDP (chrome devtools protocol) で実際の
  # DOM/computedStyleを確認し、上記が解消されたか・新たな不一致がないかを
  # 再監査すること。
  airZenifyRev = "cb65d550a6f68c74dc7b07ecf37388a0c7a7a3b7";
  airZenifyCss = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/ELGUAPOLIFE/Zen-Theme-CSS-for-Vivaldi-Browser/${airZenifyRev}/AirZenify.css";
    hash = "sha256-I8+/oDyz6+/06cIZ1jEtdmtRJMN7cLcL67SC/851H6Q=";
  };
in
{
  # --- VivaldiカスタムCSS設定 ---
  # Mac/NixOS では ~/.config/vivaldi/ をそのまま Vivaldi設定の
  # CSS UI Mods Directory に指定する (Vivaldi本体は darwin.nix の Homebrew cask)。
  # WSL のみ以下の理由で Windows 側へ実体コピーする。
  # Windows(Vivaldi)からWSL側のシンボリックリンクを \\wsl.localhost\...
  # 経由で直接読ませると、リンク先を辿れずリンク文字列そのもの(数十バイト)を
  # 読んでしまい、CSSが一切適用されない不具合がある (実機で確認済み。
  # fetchurlの結果もシンボリックリンクのため影響を受ける)。そのため他の
  # Windows向け設定 (wezterm/komorebi/yasb等) と同じく、sync-win
  # (cp -L で実体を解決してコピー) で C:\Users\tnaru\Tools\Vivaldi\ へ配置し、
  # Vivaldi設定のCSS UI Mods DirectoryもそちらへUIから向ける。
  # 前提となるVivaldi設定 (UIで手動設定):
  #   - Settings > Appearance/Tabs でUI自動非表示 (Auto-hide) を有効化
  #   - Show Title Bar を無効化
  #   - Theme設定で Transparent Tab Bar を有効化 (Blur = 0)
  xdg.configFile."vivaldi/air-zenify.css" = {
    source = airZenifyCss;
    force = true;
  };
}
