# =========================================================================
# デスクトップ環境・日本語入力・環境変数モジュール
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # -----------------------------------------------------------------------
  # 環境変数（Environment Variables）
  # -----------------------------------------------------------------------
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    
    # 競技プログラミング用 C++ 読み込みパスの移植
    CPLUS_INCLUDE_PATH = "$CPLUS_INCLUDE_PATH:/home/nalt/lib/ac-library-master";
    
    # .zshrcで定義されていた高度なLS_COLORS（ファイル種別ごとの色分け）を移植
    LS_COLORS = "di=1;38;5;110:ex=1;38;5;109:ln=1;38;5;139:*.tar=1;38;5;203:*.tgz=1;38;5;203:*.zip=1;38;5;203:*.z=1;38;5;203:*.gz=1;38;5;203:*.bz2=1;38;5;203:*.deb=1;38;5;203:*.rpm=1;38;5;203:*.jar=1;38;5;203:*.rar=1;38;5;203:*.7z=1;38;5;203:*.xz=1;38;5;203:*.rs=1;38;5;151:*.js=1;38;5;151:*.ts=1;38;5;151:*.c=1;38;5;151:*.cpp=1;38;5;151:*.go=1;38;5;151:*.py=1;38;5;151:*.java=1;38;5;151:*.lua=1;38;5;151:*.html=1;38;5;151:*.css=1;38;5;151:*.md=1;38;5;151:*.json=1;38;5;151:*.toml=1;38;5;151:*.yaml=1;38;5;151:*.yml=1;38;5;151";
  };

  # -----------------------------------------------------------------------
  # 日本語入力・デスクトップ統合設定
  # -----------------------------------------------------------------------
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  # WezTerm の有効化
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm; 
  };

  # WezTerm設定用のシンボリックリンク
  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink "/home/nalt/projects/dotfiles/wezterm";

  # デスクトップエントリの登録（WezTerm）
  xdg.desktopEntries = {
    wezterm = {
      name = "WezTerm";
      genericName = "Terminal Emulator";
      exec = "${nixgl.packages.${pkgs.system}.nixGLDefault}/bin/nixGL ${pkgs.wezterm}/bin/wezterm";
      icon = "org.wezfurlong.wezterm";
      categories = [ "System" "TerminalEmulator" "Utility" ];
      terminal = false;
    };
  };
}
