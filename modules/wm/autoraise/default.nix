# =========================================================================
# AutoRaise (focus-follows-mouse) 宣言的設定モジュール
# =========================================================================
{
  config,
  pkgs,
  dotfilesPath,
  ...
}:

{
  # 設定ファイル (~/.config/AutoRaise/config) をリポジトリ実ファイルへの直結リンクで配置
  xdg.configFile."AutoRaise/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/autoraise/config";

  # plist 初期化スクリプト (GUI ラッパーが参照する defaults 値を宣言状態と同期)
  home.activation.setupAutoRaiseDefaults = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults write com.sbmpost.AutoRaise autoRaiseDelay -int 105
    /usr/bin/defaults write com.sbmpost.AutoRaise autoFocusDelay -int 105
    /usr/bin/defaults write com.sbmpost.AutoRaise enableOnLaunch -bool true
    /usr/bin/defaults write com.sbmpost.AutoRaise enableWarp -bool false
    /usr/bin/defaults write com.sbmpost.AutoRaise ignoreApps -string "Microsoft Word,Microsoft Excel,Microsoft PowerPoint,Microsoft Outlook,Microsoft OneNote,Microsoft Teams"
  '';
}
