# =========================================================================
# AeroSpace タイリングウィンドウマネージャ宣言的設定モジュール
# =========================================================================
# キーバインドを変更したら docs/aerospace.md も直すこと
# (このファイルから自動生成されるドキュメントではないため乖離に注意)。
{
  config,
  pkgs,
  dotfilesPath,
  ...
}:

{
  # borders起動スクリプト。matugenパレット(~/.cache/matugen/colors.lua)の
  # accent/mutedがあればそれを使い、無ければ青ベースのフォールバックを使う。
  home.file.".local/bin/aerospace-launch-borders" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/aerospace/launch-borders.sh";
  };

  # AeroSpace自身の`start-at-login`はmacOSのログインアイテムとして働くため、
  # ログインセッションが完全に立ち上がる前に起動してしまうことがある。
  # その場合カスタム設定(キーバインド・gaps等)を読み込めずデフォルト値
  # (ギャップ0・独自バインド無し)のまま起動してしまい、加えて
  # after-startup-command (borders起動) も取りこぼされる。
  # after-startup-commandはAeroSpace自身の起動時に一度しか実行されず
  # reload-configでは再実行されないため、borders起動はここで明示的に
  # 行う必要がある。ログイン後に少し待ってから両方を確実に行う。
  launchd.agents.aerospace-reload-config = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "sleep 20 && /opt/homebrew/bin/aerospace reload-config && $HOME/.local/bin/aerospace-launch-borders"
      ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/aerospace-reload-config.out.log";
      StandardErrorPath = "/tmp/aerospace-reload-config.err.log";
    };
  };

  # --- AeroSpace設定 ---
  # 設定ファイル (aerospace.toml) はリポジトリ実ファイルへの直結リンクで配置する。
  # switch 不要で aerospace reload-config による即時反映が可能。
  xdg.configFile."aerospace/aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/wm/aerospace/aerospace.toml";
}
