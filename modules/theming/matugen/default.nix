# =========================================================================
# matugen 派生色ロジック 共通モジュール
# =========================================================================
# WSL (matugen-apply.sh) / NixOS (wppicker.sh) の壁紙変更フローが共通で呼ぶ
# 「色相回転計算 (complement/triad) + @@プレースホルダ@@ テンプレート置換」
# の実装を1箇所にまとめる。詳細は docs/matugen-palette.md を参照。
{ config, pkgs, dotfilesPath, ... }:

{
  # HLS計算 (colorsys) に python3 を使う。WSL/Mac には保証がないため
  # このモジュール自身が依存を宣言する。
  home.packages = [ pkgs.python3 ];

  # リポジトリ編集がそのまま反映されるよう mkOutOfStoreSymlink で配置する
  # (WSL側 matugen-apply.sh と同じ流儀。home-manager switch 不要)。
  # NixOS の hyprland module が ~/.config/matugen を丸ごと専有しているため
  # 別の名前空間に置く。
  xdg.configFile."matugen-common/lib" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/theming/matugen/lib";
  };
  xdg.configFile."matugen-common/templates" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/theming/matugen/templates";
  };
}
