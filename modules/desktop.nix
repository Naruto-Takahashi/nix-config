# =========================================================================
# デスクトップ環境・日本語入力・環境変数モジュール
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 環境変数（Environment Variables）の宣言的管理
  # -----------------------------------------------------------------------
  home.sessionVariables = {
    GTK_IM_MODULE      = "fcitx";
    QT_IM_MODULE       = "fcitx";
    XMODIFIERS         = "@im=fcitx";
    
    # 競技プログラミング用 C++ 読み込みパスの追加
    CPLUS_INCLUDE_PATH = "$CPLUS_INCLUDE_PATH:/home/nalt/lib/ac-library-master";
    
    # 高度な LS_COLORS（ファイル種別ごとの鮮やかな色分け）の定義
    LS_COLORS          = "di=1;38;5;110:ex=1;38;5;109:ln=1;38;5;139:*.tar=1;38;5;203:*.tgz=1;38;5;203:*.zip=1;38;5;203:*.z=1;38;5;203:*.gz=1;38;5;203:*.bz2=1;38;5;203:*.deb=1;38;5;203:*.rpm=1;38;5;203:*.jar=1;38;5;203:*.rar=1;38;5;203:*.7z=1;38;5;203:*.xz=1;38;5;203:*.rs=1;38;5;151:*.js=1;38;5;151:*.ts=1;38;5;151:*.c=1;38;5;151:*.cpp=1;38;5;151:*.go=1;38;5;151:*.py=1;38;5;151:*.java=1;38;5;151:*.lua=1;38;5;151:*.html=1;38;5;151:*.css=1;38;5;151:*.md=1;38;5;151:*.json=1;38;5;151:*.toml=1;38;5;151:*.yaml=1;38;5;151:*.yml=1;38;5;151";
  };

  # -----------------------------------------------------------------------
  # 日本語入力・デスクトップ統合設定 (Fcitx5 + Mozc)
  # -----------------------------------------------------------------------
  i18n.inputMethod = {
    enabled      = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  # -----------------------------------------------------------------------
  # デスクトップエントリの登録（WezTerm）
  # -----------------------------------------------------------------------
  xdg.desktopEntries = {
    wezterm = {
      name        = "WezTerm";
      genericName = "Terminal Emulator";
      exec        = "${nixgl.packages.${pkgs.system}.nixGLDefault}/bin/nixGL ${pkgs.wezterm}/bin/wezterm";
      icon        = "org.wezfurlong.wezterm";
      categories  = [ "System" "TerminalEmulator" "Utility" ];
      terminal    = false;
    };
  };

  # -----------------------------------------------------------------------
  # Fcitx5 デザインカスタマイズ (ダサいトレイアイコンの排除 & 縦型候補リスト化)
  # -----------------------------------------------------------------------
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    # 候補選択ウィンドウを縦並びにして、MacやWindowsのように圧倒的に見やすくする
    Vertical Candidate List=True

    # トレイアイコンの「ダサい『あ』/『A』のオレンジ文字」を無効化し、
    # バーのデザインに極めて美しく調和する「フラットな単色キーボードアイコン」に変更
    UseInputMethodLangaugeToDisplayText=False
    UseInputMethodLanguageToDisplayText=False

    # 変換候補表示用フォントに、システム統一の「HackGen」を指定
    Font="HackGen Console NF 12"
    MenuFont="HackGen Console NF 12"
    TrayFont="HackGen Console NF 10"

    # 高解像度ディスプレイ（DPI）への追従を有効化
    PerScreenDPI=True
  '';

  # トレイアイコン（インジケーター）を完全に非表示にしてステータスバーをミニマル化する
  xdg.configFile."fcitx5/conf/panel.conf".text = ''
    [Panel]
    TrayIcon=False
  '';

  # -----------------------------------------------------------------------
  # デフォルトアプリケーション（MIMEタイプ）の設定
  # -----------------------------------------------------------------------
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "vivaldi-stable.desktop" ];
    };
  };
}
