{ config, dotfilesPath, ... }:
{
  # YASB 設定ディレクトリ
  xdg.configFile."yasb" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/yasb";
    force = true;
  };

  # 壁紙変更時に matugen で YASB の配色を再生成するスクリプト
  home.file.".local/bin/yasb-theme" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/yasb/matugen/yasb-theme.sh";
    force = true;
  };

}
