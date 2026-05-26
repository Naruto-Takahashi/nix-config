# =========================================================================
# Zsh シェル環境設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true; # compinit & complist 相当

    # 履歴管理（History）の設定をそのまま移植
    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.zsh_history";
      share = true; # SHARE_HISTORY
      ignoreAllDups = true; # HIST_IGNORE_ALL_DUPS
      ignoreSpace = true; # HIST_IGNORE_SPACE
    };

    # 元の.zshrcに登録されていたすべての便利なエイリアス群
    shellAliases = {
      # WezTerm用ラッパー
      wezterm = "nixGL wezterm";
      
      # ユーティリティ
      c = "printf \"\\033[2J\\033[H\"";
      reload = "source ~/.zshrc && echo \"Sourced .zshrc\"";
      path = "echo $PATH | tr \":\" \"\\n\"";

      # 安全性と明示性
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -iv";

      # 移動
      ".." = "cd ..";
      "..." = "cd ../..";
      win = "cd ~/win";

      # システム状況
      df = "df -h";
      free = "free -h";

      # 開発コアツール
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gs = "git status";
      vim = "nvim";
      lg = "lazygit";

      # コマンド判定なしでモダンCLIを直感的に固定呼び出し
      ls = "eza --icons --git";
      ll = "eza -alF --icons --git";
      la = "eza -a --icons --git";
      l = "eza -F --icons --git";
      tree = "eza --tree --icons";
      cat = "bat";
      grep = "grep --color=auto";

      # 各種サブツール・ブログ執筆用エイリアス
      vimtutor1 = "nvim -c \"Tutor ja/vim-01-beginner\"";
      vimtutor2 = "nvim -c \"Tutor ja/vim-02-beginner\"";
      zp = "npx zenn preview";
      zn = "npx zenn new:article";
      zqr = "~/dotfiles/bash/zqr";
      zstop = "pkill ngrok && echo \"ngrok stopped.\"";
      bgemini = "cp ~/.gemini/GEMINI.md ~/dotfiles/gemini/GEMINI.md && (cd ~/dotfiles && git add gemini/GEMINI.md && git commit -m \"chore: update GEMINI.md backup\" && git push) && echo \"GEMINI.md backed up.\"";
      gchat = "agy -i";
      achat = "agy -i";
    };

    # プラグイン（Nixが安全な絶対パスで自動管理・読み込みを行います）
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      }
      {
        name = "zsh-syntax-highlighting";
        src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
      }
    ];

    # ディレクトリハッシュ（hash -d）の完全移植
    dirHashes = {
      d = "$HOME/dotfiles";
      p = "$HOME/projects";
      zenn = "$HOME/projects/zenn-blog";
      rust = "$HOME/projects/rust-the-book";
      win = "$HOME/win";
    };

    # 環境固有の設定、キーバインド、関数群をすべて内包（最新仕様 of initContent）
    initContent = ''
      # システム制限の解除
      ulimit -s unlimited

      # 補完選択メニューキーマップ (menuselect) のロード
      zmodload zsh/complist

      # 外部環境マネージャーの追従（存在する場合のみロード）
      [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

      # 補完メニューの挙動最適化（大文字小文字無視、カーソル選択）
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' menu select

      # fzf オプションおよびCtrl+T, Ctrl+Rのプレビュー設定の完全移植
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=pointer:#ffc20d,marker:#ffc20d,prompt:#ffc20d,info:#b48ead,hl:#b48ead,hl+:#b48ead'
      export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
      export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview,tab:down,btab:up'"

      # Vi Modeの有効化と、インサートモード等でのバックスペース挙動の修正
      bindkey -v
      bindkey "^?" backward-delete-char

      # コマンドラインのVim編集機能（Esc -> v）
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'v' edit-command-line

      # 補完選択メニュー中の Vim-like (hjkl) 移動
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char

      # -------------------------------------------------------------------
      # 各種カスタム関数群（移植）
      # -------------------------------------------------------------------
      # ディレクトリ作成と同時に移動
      mkcd() {
          mkdir -p "$1"
          cd "$1" || return
      }
      
      # ディレクトリ移動後に自動でls（eza）を実行
      function chpwd() {
          ls
      }
      
      # 競技プログラミング用コンパイル＆実行
      runcpp() {
          g++ -std=c++20 -O2 "$1" -o "''${1%.cpp}.out" && "./''${1%.cpp}.out"
      }
      runcppio() {
          g++ -std=c++20 -O2 "$1" -o "''${1%.cpp}.out" && "./''${1%.cpp}.out" < input.txt > output.txt
      }

      # WezTerm OSC 7 サポート (カレントディレクトリの同期同期用)
      if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
          wezterm_osc7() {
              printf "\033]7;file://%s%s\033\\" "$HOST" "$PWD"
          }
          autoload -Uz add-zsh-hook
          add-zsh-hook precmd wezterm_osc7
      fi

      # ghq + fzf の高速ディレクトリ移動インタフェース
      function ghq-fzf() {
        local src=$(ghq list | fzf --bind 'tab:down,btab:up' --preview "ls -laTp $(ghq root)/{} | tail -n+2 | head -n 200")
        if [ -n "$src" ]; then
          BUFFER="cd $(ghq root)/$src"
          zle accept-line
        fi
        zle reset-prompt
      }
      zle -N ghq-fzf
      bindkey '^g' ghq-fzf
      bindkey -M viins '^g' ghq-fzf
      bindkey -M vicmd '^g' ghq-fzf

      # シンタックスハイライトのカスタムスタイル適用
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

      # Windowsとの設定同期関数（WSL固有パスですが資産として完全に維持します）
      function sync-win() {
          echo "Syncing WezTerm config..."
          cp ~/dotfiles/wezterm/*.lua /mnt/c/Users/tnaru/.config/wezterm/
          echo "Syncing AutoHotkey scripts..."
          mkdir -p /mnt/c/Users/tnaru/Tools/Customization
          cp -r ~/dotfiles/ahk/* /mnt/c/Users/tnaru/Tools/Customization/
          echo "Syncing GlazeWM config..."
          mkdir -p /mnt/c/Users/tnaru/.glzr/glazewm
          cp ~/dotfiles/glazewm/config.yaml /mnt/c/Users/tnaru/.glzr/glazewm/
          echo "Syncing Zebar config..."
          mkdir -p /mnt/c/Users/tnaru/.glzr/zebar
          cp -r ~/dotfiles/zebar/* /mnt/c/Users/tnaru/.glzr/zebar/
          echo "Syncing Vivaldi CSS..."
          mkdir -p /mnt/c/Users/tnaru/Tools/Vivaldi
          cp ~/dotfiles/vivaldi/css/vivaldi_minimal_transparent.css /mnt/c/Users/tnaru/Tools/Vivaldi/custom.css
          echo "All Windows configs synced."
      }

      # ローカル固有環境変数の自動ソース化
      [ -f ~/.env ] && source ~/.env
    '';
  };
}
