# =========================================================================
# 日本語入力 (Fcitx5 + Mozc) モジュール
# =========================================================================
{ pkgs, ... }:

{
  # --- 日本語入力設定 (Fcitx5 + Mozc) ---
  # 日本語入力・デスクトップ統合設定を行います．
  i18n.inputMethod = {
    enabled      = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  # --- Fcitx5 デザインカスタマイズ ---
  # トレイアイコンを排除し，縦型候補リスト化を行います．
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    # 候補選択ウィンドウを縦並びにして，MacやWindowsのように圧倒的に見やすくします．
    Vertical Candidate List=True

    # トレイアイコンの「ダサい『あ』/『A』のオレンジ文字」を無効化し，
    # バーのデザインに極めて美しく調和する「フラットな単色キーボードアイコン」に変更します．
    UseInputMethodLangaugeToDisplayText=False
    UseInputMethodLanguageToDisplayText=False

    # 変換候補表示用フォントに，システム統一の「HackGen」を指定します．
    Font="HackGen Console NF 12"
    MenuFont="HackGen Console NF 12"
    TrayFont="HackGen Console NF 10"

    # 高解像度ディスプレイ（DPI）への追従を有効化します．
    PerScreenDPI=True
  '';

  # トレイアイコン（インジケーター）を完全に非表示にしてステータスバーをミニマル化します．
  xdg.configFile."fcitx5/conf/panel.conf".text = ''
    [Panel]
    TrayIcon=False
  '';
}
