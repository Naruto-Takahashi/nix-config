# =========================================================================
# Vivaldi 宣言的設定モジュール
# =========================================================================
# 自動非表示は Vivaldi 標準機能 (UI Auto-hide)、ガラス化 (透過・ブラー) は
# 自作の css/glass.css で行う。公開テーマ (AirZenify 等) は使わない:
# 実DOMとのセレクタ不一致が多く、上書き修正を重ねるより実DOMをCDPで
# 確認しながら自前で書くほうが精度が高いため。セレクタは Vivaldi 8.2.4133
# (Mac) 基準。Vivaldi 更新後は tools/glass-audit.mjs で漏れを再検査する。
{
  config,
  dotfilesPath,
  ...
}:

{
  # --- VivaldiカスタムCSS設定 ---
  # Mac/NixOS では ~/.config/vivaldi/ をそのまま Vivaldi設定の
  # CSS UI Mods Directory に指定する (Vivaldi本体は darwin.nix の Homebrew cask)。
  # WSL のみ、Windows(Vivaldi)から \\wsl.localhost\... 経由のシンボリック
  # リンクを辿れずリンク文字列そのものを読んでしまう (実機で確認済み) ため、
  # sync-win (cp -L で実体を解決してコピー) で C:\Users\tnaru\Tools\Vivaldi\
  # へ配置し、CSS UI Mods Directory もそちらへ向ける。
  # 前提となるVivaldi設定 (UIで手動設定):
  #   - Settings > Appearance/Tabs でUI自動非表示 (Auto-hide) を有効化
  #   - Show Title Bar を無効化
  #   - Theme設定で Transparent Tab Bar を有効化 (Blur = 0)
  xdg.configFile."vivaldi/glass.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/gui/vivaldi/css/glass.css";
    force = true;
  };
}
