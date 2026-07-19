# =========================================================================
# btop (システムモニタ TUI) 宣言的設定モジュール
# =========================================================================
# btop は終了時に btop.conf を自分で書き換えるため programs.btop
# (読み取り専用 symlink) は使わず、初回のみ設定をシードする方式にする。
# これによりアプリ内での設定変更もそのまま保存できる。
#
# 配色テーマは「color_theme は matugen 固定・中身のファイルを差し替える」
# 方式で、matugen 環境では matugen-apply が壁紙由来の配色で上書きし、
# 無い環境では activation が配置する kanagawa-dragon フォールバックが
# 使われ続ける。
{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.btop ];

  home.activation.seedBtopConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/btop/themes"
    [ -f "$HOME/.config/btop/themes/matugen.theme" ] || \
      cp ${../../theming/matugen/fallbacks/btop.theme} \
        "$HOME/.config/btop/themes/matugen.theme"
    chmod u+w "$HOME/.config/btop/themes/matugen.theme"
    if [ ! -f "$HOME/.config/btop/btop.conf" ]; then
      printf '%s\n' \
        'color_theme = "matugen"' \
        'theme_background = False' \
        'vim_keys = True' \
        > "$HOME/.config/btop/btop.conf"
    fi
  '';
}
