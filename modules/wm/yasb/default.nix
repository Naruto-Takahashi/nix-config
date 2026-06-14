{ config, dotfilesPath, ... }:
{
  # YASB 設定ディレクトリ
  xdg.configFile."yasb" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/yasb";
    force = true;
  };
}
