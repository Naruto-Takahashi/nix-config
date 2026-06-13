# =========================================================================
# Chrome Remote Desktop 連携モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # Chrome Remote Desktop セッション設定
  # -----------------------------------------------------------------------
  # Chrome Remote Desktop (CRD) は Linux で新しいセッションを開始する際、
  # ~/.chrome-remote-desktop-session を参照します。
  # このファイルで Home Manager が生成する .xsession を呼び出すことで、
  # リモート環境でも i3wm や各種設定をそのまま利用できます。
  # -----------------------------------------------------------------------
  home.file.".chrome-remote-desktop-session" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Home Manager が生成した標準の X セッション（i3 起動を含む）を実行
      exec /home/nalt/.xsession
    '';
  };

  # 補足: CRD を Ubuntu 等にインストールした後は、以下のコマンドで
  # ユーザーをグループに追加する必要があります（ホスト OS 側で実行）:
  # sudo usermod -a -G chrome-remote-desktop $USER
}
