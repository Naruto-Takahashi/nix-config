# =========================================================================
# パッケージ・アプリケーション管理モジュール
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  home.packages = [
    pkgs.hackgen-nf-font # WezTermで指定されているフォント

    pkgs.eza
    pkgs.bat
    pkgs.fzf
    pkgs.feh
    pkgs.picom
    pkgs.zoxide
    pkgs.ghq
    pkgs.git
    pkgs.gh
    pkgs.gcc
    pkgs.gnumake
    pkgs.python3
    pkgs.nodejs_22
    pkgs.ripgrep
    pkgs.xclip
    pkgs.wl-clipboard
    pkgs.kanata
    pkgs.gemini-cli
    pkgs.maim # 超軽量・極めて安定したスクリーンショットツール（GPUに依存しない）
    pkgs.slop # maim用の美しいドラッグ範囲選択ツール
    pkgs.cowsay
    pkgs.fortune
    pkgs.lolcat
    pkgs.fastfetch
    # vivaldi のラッパーパッケージ：XRDPセッション(DISPLAY>=10)時はプロファイルを分けて多重起動できるようにする
    (pkgs.stdenv.mkDerivation {
      name = "vivaldi-wrapped";
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/vivaldi
#!/usr/bin/env bash
display_num=\$(echo \$DISPLAY | cut -d: -f2 | cut -d. -f1)
if [ -f /run/current-system/sw/bin/vivaldi ]; then
  REAL_VIVALDI="/run/current-system/sw/bin/vivaldi"
elif [ -f /etc/profiles/per-user/nalt/bin/vivaldi ]; then
  REAL_VIVALDI="/etc/profiles/per-user/nalt/bin/vivaldi"
elif [ -f /usr/bin/vivaldi-stable ]; then
  REAL_VIVALDI="/usr/bin/vivaldi-stable"
else
  REAL_VIVALDI=\$(which -a vivaldi vivaldi-stable | grep -v "/.nix-profile/bin" | grep -v "/etc/profiles" | head -n 1)
fi

if [ -n "\$display_num" ] && [ "\$display_num" -ge 10 ]; then
  exec "\$REAL_VIVALDI" --user-data-dir="\$HOME/.config/vivaldi-remote" "\$@"
else
  exec "\$REAL_VIVALDI" "\$@"
fi
EOF
        chmod +x $out/bin/vivaldi
        ln -s vivaldi $out/bin/vivaldi-stable
      '';
    })

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
