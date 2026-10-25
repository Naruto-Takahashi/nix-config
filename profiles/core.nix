# =========================================================================
# 最小共通 CLI プロファイル (core.nix)
# =========================================================================
# デスクトップ (Mac/WSL/NixOS)、リモートサーバー、コンテナ (distrobox/sandbox)
# のすべての環境で共通して動作するヘッドレスな基盤 CLI ツールセット。
# GUI アプリ (WezTerm) や外部連携 (Obsidian/Orca) は含まない。
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # -----------------------------------------------------------------------
  # 各モジュールで利用するグローバル引数
  # -----------------------------------------------------------------------
  _module.args = {
    dotfilesPath = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/nix-config";
  };

  imports = [
    ../modules/shell/zsh
    ../modules/shell/starship
    ../modules/shell/direnv
    ../modules/shell/fastfetch
    ../modules/shell/atuin
    ../modules/cli/neovim
    ../modules/cli/yazi
    ../modules/cli/eza
    ../modules/cli/bat
    ../modules/cli/git
    ../modules/cli/lazygit
    ../modules/cli/git-hooks
    ../modules/cli/btop
  ];

  # -----------------------------------------------------------------------
  # 全ホスト共通の小物 CLI ツール
  # -----------------------------------------------------------------------
  programs.tealdeer = {
    enable = true;
    settings = {
      updates.auto_update = true;
      style = {
        description.foreground.rgb = {
          r = 225;
          g = 226;
          b = 232;
        };
        command_name = {
          foreground.rgb = {
            r = 162;
            g = 201;
            b = 253;
          };
          bold = true;
        };
        example_text.foreground.rgb = {
          r = 195;
          g = 198;
          b = 207;
        };
        example_code.foreground.rgb = {
          r = 215;
          g = 189;
          b = 228;
        };
        example_variable = {
          foreground.rgb = {
            r = 187;
            g = 199;
            b = 219;
          };
          italic = true;
        };
      };
    };
  };

  # ユーザー側の古い世代 (Home Manager 等) を定期的に削除して GC する。
  # システム側の世代は NixOS (hosts/nixos/configuration.nix) / Mac (hosts/mac/darwin.nix) で別途削除する。
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = [
    pkgs.fd # 高速 find (fzf バックエンド)
    pkgs.curl # HTTPクライアント
    pkgs.wget # ダウンローダー
    pkgs.tmux # 端末多重化・セッション永続化
    pkgs.less # pager
    pkgs.file # ファイル種別判定
    pkgs.man-db # man コマンド
    pkgs.ghq # リポジトリ一元管理
    pkgs.gh # GitHub CLI
    pkgs.jq # JSON整形・抽出
    pkgs.comma # 一時パッケージ実行
    pkgs.just # コマンドランナー
    pkgs.uv # Python 開発ツール (全環境共通)
    pkgs.bitwarden-cli # Bitwarden CLI (bw)
  ];
}
