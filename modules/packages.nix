# =========================================================================
# パッケージ・アプリケーション管理モジュール
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  home.packages = [
    nixgl.packages.${pkgs.system}.nixGLDefault
    pkgs.hackgen-nf-font # WezTermで指定されているフォント

    # 元の.zshrcで自動検知（command -v）対象になっていたモダンツール群をフルカバー！
    pkgs.eza
    pkgs.bat
    pkgs.fzf
    pkgs.zoxide
    pkgs.ghq
    pkgs.git
    pkgs.gh
    pkgs.lazygit
    pkgs.kanata

    # Antigravity CLI (Gemini CLI の後継) を Nix で宣言的に管理
    (pkgs.stdenv.mkDerivation {
      pname = "antigravity-cli";
      version = "1.0.2";
      src = pkgs.fetchurl {
        url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.2-6109799369277440/linux-x64/cli_linux_x64.tar.gz";
        hash = "sha256-9sfKgNUJkzO/IpZ2RzvREeDapqDY23xTKt9lA7Dqrck=";
      };
      sourceRoot = ".";
      installPhase = ''
        mkdir -p $out/bin
        cp antigravity $out/bin/agy
        chmod +x $out/bin/agy
      '';
    })
  ];
}
