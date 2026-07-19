# =========================================================================
# Zsh シェル環境設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # programs.direnv は modules/shell/direnv で定義されているため，ここでは定義しない．

  # --- ユーティリティツールの有効化 ---
  # fzf（ファジーファインダー）の有効化とZsh連携を設定します．
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # zoxide（スマートなcdコマンド）の有効化を設定します．
  # （Zshとの自動連携は無効化し，initContent内で手動初期化します）
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
    options = [ "--cmd cd" ];
  };

  # --- Zsh本体の設定 ---
  programs.zsh = {
    enable = true;
    enableCompletion = true; # compinit & complist 相当の自動読み込み

    # 履歴管理（History）の設定
    history = {
      size           = 50000;
      save           = 50000;
      path           = "$HOME/.zsh_history";
      share          = true;  # SHARE_HISTORY
      ignoreAllDups  = true;  # HIST_IGNORE_ALL_DUPS
      ignoreSpace    = true;  # HIST_IGNORE_SPACE
    };

    # コマンドエイリアス（shellAliases）の定義
    shellAliases = {
      # WezTerm用ラッパー（Nvidia環境対応）
      wezterm = "nixGL wezterm";
      
      # ユーティリティ & 表示クリア
      c       = "printf \"\\033[2J\\033[H\"";
      reload  = "source ~/.zshrc && echo \"Sourced .zshrc\"";
      path    = "echo $PATH | tr \":\" \"\\n\"";

      # 安全性と明示性の確保
      cp      = "cp -iv";
      mv      = "mv -iv";
      rm      = "rm -iv";

      # ディレクトリ移動の短縮
      ".."    = "cd ..";
      "..."   = "cd ../..";
      win     = "cd ~/win";

      # システム状況監視
      df      = "df -h";
      free    = "free -h";

      # 開発コアツール
      g       = "git";
      ga      = "git add";
      gc      = "git commit";
      gp      = "git push";
      gs      = "git status";
      vim     = "nvim";
      lg      = "lazygit";

      # GitHub Copilot（Manual Install - v1.0.63+）
      chat    = "copilot";
      ask     = "copilot -i";
      exp     = "copilot -i 'explain '";
      copilot = "copilot";

      # モダンCLIユーティリティへの置き換え
      ls      = "eza --icons";
      ll      = "eza -alF --icons";
      la      = "eza -a --icons";
      l       = "eza -F --icons";
      tree    = "eza --tree --icons";
      cat     = "bat";
      grep    = "grep --color=auto";

      # tldr を日本語ページで引く (tldr-pages のコミュニティ日本語訳を利用)
      tldrj   = "LANG=ja_JP.UTF-8 LANGUAGE=ja tldr";

      # サブツール・ブログ執筆関連
      vimtutor1 = "nvim -c \"Tutor ja/vim-01-beginner\"";
      vimtutor2 = "nvim -c \"Tutor ja/vim-02-beginner\"";
      zp        = "npx zenn preview";
      zn        = "npx zenn new:article";
      zqr       = "~/dotfiles/bash/zqr";
      zstop     = "pkill ngrok && echo \"ngrok stopped.\"";
      bgemini   = "cp ~/.gemini/GEMINI.md ~/dotfiles/gemini/GEMINI.md && (cd ~/dotfiles && git add gemini/GEMINI.md && git commit -m \"chore: update GEMINI.md backup\" && git push) && echo \"GEMINI.md backed up.\"";
      gchat     = "agy -i";
      achat     = "agy -i";

      # Raspberry Pi 3B SSHFS マウント操作
      raspi-mount  = "mkdir -p ~/mnt/raspi && sshfs nalt@192.168.151.253:/home/nalt ~/mnt/raspi && echo 'raspi mounted at ~/mnt/raspi'";
      raspi-umount = "fusermount -u ~/mnt/raspi && echo 'raspi unmounted'";
      raspi        = "cd ~/mnt/raspi";
    };

    # プラグイン設定（Nixによる絶対パスでの自動配置）
    plugins = [
      {
        name = "zsh-autosuggestions";
        src  = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      }
      # 構文ハイライトを有効化
      {
        name = "zsh-syntax-highlighting";
        src  = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
        file = "zsh-syntax-highlighting.zsh";
      }
    ];

    # ディレクトリハッシュ（hash -d による「~ショートカット」）
    dirHashes = {
      d    = "$HOME/dotfiles";
      p    = "$HOME/projects";
      zenn = "$HOME/projects/zenn-blog";
      rust = "$HOME/projects/rust-the-book";
      win  = "$HOME/win";
    };

    # 環境固有の設定，キーバインド，カスタム関数（.zshrcへの流し込み）
    initContent = ''
      # 静的な追加設定 (関数・オプション・キーバインド) は実ファイルから読み込む
      source ~/.config/zsh/functions.zsh

      # zoxideの初期化を行います（nvmロード後に実行することで，nvm内部のcd処理との衝突を防ぎます）．
      # 非対話シェル (zsh -ic) では初期化順の診断警告が誤検知されるため抑止します．
      export _ZO_DOCTOR=0
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"
    '';
  };

  # --- 追加設定ファイルの配置 ---
  xdg.configFile."zsh/functions.zsh".source = ./functions.zsh;
}
