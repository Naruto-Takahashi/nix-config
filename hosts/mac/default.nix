# =========================================================================
# Home Manager Mac環境用設定ファイル (hosts/mac/default.nix)
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../profiles/base.nix
    ../../modules/wm/aerospace
    ../../modules/theming/matugen/mac
    ../../modules/gui/vivaldi
  ];

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username = "nalt";
  home.homeDirectory = "/Users/nalt";
  home.stateVersion = "25.11";

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # -----------------------------------------------------------------------
  # インストールするパッケージの定義 (Mac固有パッケージ)
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    cowsay
    # fortune依存のrecode(3.7.16)がテストフェーズでセグフォルトしビルド不能
    # (このnixpkgsピン・aarch64-darwinで発生、upstreamのバグ)。テストだけ
    # 無効化して回避する(recode自体の挙動は変わらない)。
    (fortune.override {
      recode = recode.overrideAttrs (_: {
        doCheck = false;
      });
    })
    lolcat
    nodejs_22
    hackgen-nf-font
    kanata
  ];

  # フォントの設定を有効化
  fonts.fontconfig.enable = true;

  # Mac向け Kanata 設定ファイルの動的生成（置換ロジックは mac-config.nix に集約）
  # 英数/かな切り替え・WM操作ともKanata側（config.kbd）で完結させるため，
  # Karabiner-Elements本体（karabiner.json）は導入しない．
  xdg.configFile."kanata/config.kbd".text = import ../../modules/input/kanata/mac-config.nix;
}
