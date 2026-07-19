# =========================================================================
# パッケージ・アプリケーション管理宣言的モジュール
# =========================================================================
{ config, pkgs, nixgl, ... }:

{
  # --- 導入パッケージ一覧 ---
  home.packages = [
    # ターミナルで使用するフォント
    pkgs.hackgen-nf-font # WezTermで指定されているフォントです．

    # 基本CLIユーティリティ
    pkgs.eza
    pkgs.bat
    pkgs.fzf
    pkgs.feh
    pkgs.picom
    pkgs.zoxide
    pkgs.ghq
    pkgs.git
    pkgs.gh

    # 開発環境・コンパイラ
    pkgs.gcc
    pkgs.gnumake
    pkgs.python3
    pkgs.nodejs_22
    pkgs.ripgrep

    # クリップボード・ユーティリティ
    pkgs.xclip
    pkgs.wl-clipboard
    pkgs.kanata

    # AI連携ツール
    pkgs.gemini-cli
    pkgs.claude-code

    # スクリーンショットツール
    pkgs.maim # 超軽量・極めて安定したスクリーンショットツール（GPUに依存しない）です．
    pkgs.slop # maim用の美しいドラッグ範囲選択ツールです．

    # ジョークツール・装飾
    pkgs.cowsay
    pkgs.fortune
    pkgs.lolcat
    pkgs.fastfetch

    # --- カスタムパッケージ定義 ---
    
    # vivaldiのラッパーパッケージ：XRDPセッション（DISPLAY>=10）時はプロファイルを分けて多重起動できるようにします．
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

    # Antigravity CLI（Gemini CLIの後継）をNixで宣言的に管理します．
    (pkgs.stdenv.mkDerivation {
      pname = "antigravity-cli";
      version = "1.1.4";
      src = pkgs.fetchurl {
        url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.4-6277569641840640/linux-x64/cli_linux_x64.tar.gz";
        hash = "sha256-qqtC45XLTjv+WuiJlKNAhl2Un3qefwYE/6Kj8eiq2/o=";
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
