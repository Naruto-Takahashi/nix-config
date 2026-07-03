{ config, dotfilesPath, ... }:
{
  # Vivaldi カスタム CSS (sync-win でWindows側へ配置)
  xdg.configFile."vivaldi/custom.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/apps/vivaldi/css/custom.css";
    force = true;
  };
}
