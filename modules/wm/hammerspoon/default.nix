# =========================================================================
# Hammerspoon トラックパッドジェスチャー宣言的設定モジュール
# =========================================================================
{
  config,
  pkgs,
  dotfilesPath,
  ...
}:

{
  # Hammerspoon 設定ファイル (init.lua) をリポジトリ実ファイルへの直結リンクで配置する
  # switch 不要で Hammerspoon reload による即時反映が可能。
  home.file.".hammerspoon/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/hammerspoon/init.lua";
}
