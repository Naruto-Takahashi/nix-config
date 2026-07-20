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

    # LS_COLORSは撤去した。`ls`は実質eza (エイリアス+chpwd) を使うため、
    # eza自体のtheme.yml (modules/apps/eza、matugen環境ではyaziと同じ配色) を
    # 優先させたい。LS_COLORSが設定されているとdi等の一部項目がそちらに
    # 引っ張られてしまうため撤去した (modules/shell/zsh/functions.zsh 参照)。
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
