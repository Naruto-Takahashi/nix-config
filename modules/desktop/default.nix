# =========================================================================
# Linux デスクトップ共通設定 (環境変数・デスクトップエントリー・MIME)
# =========================================================================
# 日本語入力は modules/input/fcitx5.nix、キーリマップは modules/input/kanata
# に分離されている。GUI パッケージ群は ./packages.nix。
{ config, ... }:

{
  # --- 環境変数の設定 ---
  # 環境変数（Environment Variables）の宣言的管理を行います．
  home.sessionVariables = {
    GTK_IM_MODULE      = "fcitx";
    QT_IM_MODULE       = "fcitx";
    XMODIFIERS         = "@im=fcitx";

    # 競技プログラミング用C++読み込みパスの追加
    CPLUS_INCLUDE_PATH = "$CPLUS_INCLUDE_PATH:${config.home.homeDirectory}/lib/ac-library-master";

    # 高度なLS_COLORS（ファイル種別ごとの鮮やかな色分け）の定義
    LS_COLORS          = "di=1;38;5;110:ex=1;38;5;109:ln=1;38;5;139:*.tar=1;38;5;203:*.tgz=1;38;5;203:*.zip=1;38;5;203:*.z=1;38;5;203:*.gz=1;38;5;203:*.bz2=1;38;5;203:*.deb=1;38;5;203:*.rpm=1;38;5;203:*.jar=1;38;5;203:*.rar=1;38;5;203:*.7z=1;38;5;203:*.xz=1;38;5;203:*.rs=1;38;5;151:*.js=1;38;5;151:*.ts=1;38;5;151:*.c=1;38;5;151:*.cpp=1;38;5;151:*.go=1;38;5;151:*.py=1;38;5;151:*.java=1;38;5;151:*.lua=1;38;5;151:*.html=1;38;5;151:*.css=1;38;5;151:*.md=1;38;5;151:*.json=1;38;5;151:*.toml=1;38;5;151:*.yaml=1;38;5;151:*.yml=1;38;5;151";
  };

  # --- デスクトップエントリー設定 ---
  # Rofi等で確実に優先されるよう ~/.local/share/applications/ に直接配置してシステム側をオーバーライドします．
  home.file.".local/share/applications/vivaldi-stable.desktop".text = ''
    [Desktop Entry]
    Categories=Network;WebBrowser;
    Exec=${config.home.homeDirectory}/.nix-profile/bin/vivaldi %U
    GenericName=Web Browser
    Icon=vivaldi
    MimeType=text/html;text/xml;application/xhtml+xml;application/xml;image/gif;image/jpeg;image/png;image/webp;application/x-xpinstall;x-scheme-handler/http;x-scheme-handler/https;
    Name=Vivaldi
    Terminal=false
    Type=Application
    Version=1.5
  '';

  # --- デフォルトアプリケーション（MIMEタイプ）の設定 ---
  # MIMEタイプに応じたデフォルトのハンドラを設定します．
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "vivaldi-stable.desktop" ];
    };
  };
}
