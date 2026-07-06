# =========================================================================
# Vivaldi 宣言的設定モジュール
# =========================================================================
{ config, dotfilesPath, ... }:

{
  # --- VivaldiカスタムCSS設定 ---
  # VivaldiのカスタムCSSを配置します（sync-winコマンドでWindows側へ配置されます）．
  xdg.configFile."vivaldi/custom.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/apps/vivaldi/css/custom.css";
    force = true;
  };
}
