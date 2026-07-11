# =========================================================================
# YASB (Yet Another Status Bar) 宣言的設定モジュール
# =========================================================================
{ config, dotfilesPath, ... }:

{
  # --- YASB設定ディレクトリ ---
  # 設定ファイル一式を配置するディレクトリへのシンボリックリンク．
  xdg.configFile."yasb" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/yasb";
    force = true;
  };

  # --- 配色連携スクリプト ---
  # 壁紙変更時にmatugenで生成された配色をYASBに反映させるためのスクリプト．
  home.file.".local/bin/matugen-apply" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/yasb/matugen/matugen-apply.sh";
    force = true;
  };
}
