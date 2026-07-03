# =========================================================================
# Zsh シェル環境設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
    options = [ "--cmd cd" ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true; # compinit & complist 相当の自動読み込み

    # ---------------------------------------------------------------------
    # 履歴管理（History）の設定
    # ---------------------------------------------------------------------
    history = {
      size           = 50000;
      save           = 50000;
      path           = "$HOME/.zsh_history";
      share          = true;  # SHARE_HISTORY
      ignoreAllDups  = true;  # HIST_IGNORE_ALL_DUPS
      ignoreSpace    = true;  # HIST_IGNORE_SPACE
    };

    # ---------------------------------------------------------------------
    # コマンドエイリアス (shellAliases) の定義
    # ---------------------------------------------------------------------
    shellAliases = {
      # WezTerm用ラッパー (Nvidia環境対応)
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

      # GitHub Copilot (Manual Install - v1.0.63+)
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

    # ---------------------------------------------------------------------
    # プラグイン (Nixによる絶対パスでの超安定自動配置)
    # ---------------------------------------------------------------------
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

    # ---------------------------------------------------------------------
    # ディレクトリハッシュ (hash -d による `~ショートカット`)
    # ---------------------------------------------------------------------
    dirHashes = {
      d    = "$HOME/dotfiles";
      p    = "$HOME/projects";
      zenn = "$HOME/projects/zenn-blog";
      rust = "$HOME/projects/rust-the-book";
      win  = "$HOME/win";
    };

    # ---------------------------------------------------------------------
    # 環境固有の設定、キーバインド、カスタム関数
    # ---------------------------------------------------------------------
    initContent = ''
      # zsh-autosuggestions の検索を非同期化し，ラグをゼロにする設定
      export ZSH_AUTOSUGGEST_USE_ASYNC="true"
      # 入力文字数が1文字以下の場合はサジェスト探索をスキップ（空ENTER時のラグを完全にゼロにする）
      export ZSH_AUTOSUGGEST_MIN_SIZE=2

      # 外部ツールなどのパス追加・設定
      export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
      export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/home/nalt/lib/ac-library-master
      export PATH=$PATH:/usr/local/go/bin
      export PATH=$PATH:$HOME/go/bin

      # LS_COLORS のカラーパレット定義
      export LS_COLORS="di=1;38;5;110:ex=1;38;5;109:ln=1;38;5;139:*.tar=1;38;5;203:*.tgz=1;38;5;203:*.zip=1;38;5;203:*.z=1;38;5;203:*.gz=1;38;5;203:*.bz2=1;38;5;203:*.deb=1;38;5;203:*.rpm=1;38;5;203:*.jar=1;38;5;203:*.rar=1;38;5;203:*.7z=1;38;5;203:*.xz=1;38;5;203:*.rs=1;38;5;151:*.js=1;38;5;151:*.ts=1;38;5;151:*.c=1;38;5;151:*.cpp=1;38;5;151:*.go=1;38;5;151:*.py=1;38;5;151:*.java=1;38;5;151:*.lua=1;38;5;151:*.html=1;38;5;151:*.css=1;38;5;151:*.md=1;38;5;151:*.json=1;38;5;151:*.toml=1;38;5;151:*.yaml=1;38;5;151:*.yml=1;38;5;151"

      # ディレクトリ移動（cdなしでの移動を許可）
      setopt auto_cd

      # 履歴保存オプションの追加拡張
      setopt EXTENDED_HISTORY
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt HIST_FIND_NO_DUPS
      setopt HIST_NO_STORE

      # システムスタック制限の解除 (開発時等の安定化)
      ulimit -s unlimited

      # 補完選択メニュー用モジュール (complist) のロード
      zmodload zsh/complist

      [ -f "$HOME/.cargo/env" ]  && . "$HOME/.cargo/env"

      # 補完メニューの挙動最適化（大文字小文字の曖昧補完、カーソル選択）
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' menu select

      # fzf オプションおよびCtrl+T, Ctrl+Rのプレビュー表示設定
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=pointer:#ffc20d,marker:#ffc20d,prompt:#ffc20d,info:#b48ead,hl:#b48ead,hl+:#b48ead'
      # matugen 生成の fzf 配色があれば上書き (yasb-theme が生成)
      [[ -f ~/.cache/matugen/fzf-colors.sh ]] && source ~/.cache/matugen/fzf-colors.sh
      export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
      export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview,tab:down,btab:up'"

      # Vi Mode (Vim風キーマップ) の有効化とインサート時のバックスペース調整
      bindkey -v
      bindkey "^?" backward-delete-char

      # コマンドラインのVim編集機能（ノーマルモードで 'v' でエディタ起動）
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'v' edit-command-line

      # 補完選択メニュー中の Vim風 (HJKL) 移動キーマップ
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char

      # ===================================================================
      # カスタムシェル関数
      # ===================================================================
      
      # 1. ディレクトリを作成して即時に移動
      mkcd() {
          mkdir -p "$1"
          cd "$1" || return
      }
      
      # 2. ディレクトリ移動 (cd) 後に自動的に eza (ls) を実行
      function chpwd() {
          ls
      }
      
      # 3. 競技プログラミング用 C++ コンパイル＆実行
      runcpp() {
          g++ -std=c++20 -O2 "$1" -o "''${1%.cpp}.out" && "./''${1%.cpp}.out"
      }
      runcppio() {
          g++ -std=c++20 -O2 "$1" -o "''${1%.cpp}.out" && "./''${1%.cpp}.out" < input.txt > output.txt
      }

      # 4. WezTerm OSC 7 サポート (新しいタブを開いた際のカレントディレクトリ同期用)
      if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
          wezterm_osc7() {
              printf "\033]7;file://%s%s\033\\" "$HOST" "$PWD"
          }
          autoload -Uz add-zsh-hook
          add-zsh-hook precmd wezterm_osc7
      fi

      # 5. ghq + fzf による超高速ディレクトリジャンプ
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

      # 6. zsh-syntax-highlighting 用のカスタムカラースタイル
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
      ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

      # matugen 生成の starship 配色があればそちらを優先
      [[ -f ~/.cache/matugen/starship.toml ]] && export STARSHIP_CONFIG=~/.cache/matugen/starship.toml

      # matugen 生成の lazygit 完全設定があれば単一ファイルで渡す (マージ問題回避)
      [[ -f ~/.cache/matugen/lazygit-config.yml ]] && \
        export LG_CONFIG_FILE="$HOME/.cache/matugen/lazygit-config.yml"

      # 7. Windowsとの設定同期用関数 (WSL環境用)
      function sync-win() {
          echo "Syncing WezTerm config..."
          cp ~/.config/wezterm/*.lua /mnt/c/Users/tnaru/.config/wezterm/
          echo "Syncing AutoHotkey scripts..."
          mkdir -p /mnt/c/Users/tnaru/Tools/Customization
          cp -rL ~/.config/ahk/* /mnt/c/Users/tnaru/Tools/Customization/
          echo "Syncing Komorebi config..."
          mkdir -p /mnt/c/Users/tnaru/.config/komorebi
          cp -L ~/.config/komorebi/komorebi.json /mnt/c/Users/tnaru/.config/komorebi/
          cp -L ~/.config/komorebi/komorebi.ahk /mnt/c/Users/tnaru/.config/komorebi/
          cp -L ~/.config/komorebi/applications.json /mnt/c/Users/tnaru/.config/komorebi/
          # 読み込みの確実性を高めるため、ホーム直下にも配置
          cp -L ~/.config/komorebi/komorebi.json /mnt/c/Users/tnaru/
          cp -L ~/.config/komorebi/applications.json /mnt/c/Users/tnaru/
          rm -f "/mnt/c/Users/tnaru/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/komorebi.ahk"
          # スタートアップ・環境構築スクリプトの同期
          cp -L ~/.config/komorebi/startup.ps1 /mnt/c/Users/tnaru/Tools/Customization/
          cp -L ~/.config/komorebi/setup-windows.ps1 /mnt/c/Users/tnaru/Tools/Customization/
          echo "Syncing YASB config..."
          mkdir -p /mnt/c/Users/tnaru/.config/yasb
          cp -rL ~/.config/yasb/* /mnt/c/Users/tnaru/.config/yasb/
          # matugen 生成済みパレットがあれば styles.css に再適用
          [ -x ~/.local/bin/yasb-theme ] && ~/.local/bin/yasb-theme --reapply
          echo "Syncing Vivaldi CSS..."
          mkdir -p /mnt/c/Users/tnaru/Tools/Vivaldi
          cp ~/dotfiles/vivaldi/css/vivaldi_minimal_transparent.css /mnt/c/Users/tnaru/Tools/Vivaldi/custom.css
          echo "Reloading Komorebi..."
          /mnt/c/Program\ Files/komorebi/bin/komorebic.exe reload-configuration 2>/dev/null \
              || echo "  (komorebi reload skipped — not running)"
          echo "Done."
      }

      # 8. 最新のスクリーンショットを Antigravity チャットへ連携する関数
      # (撮影した ~/Pictures/Screenshots/ 下の最新画像を sync)
      function agy-ss() {
          local ss_dir="$HOME/Pictures/Screenshots"
          local latest_file=$(ls -t "$ss_dir"/Screenshot*.png 2>/dev/null | head -n 1)
          if [ -n "$latest_file" ]; then
              cp "$latest_file" "$ss_dir/latest.png"
              if command -v wl-copy >/dev/null 2>&1; then
                  echo -n "$latest_file" | wl-copy
              elif command -v xclip >/dev/null 2>&1; then
                  echo -n "$latest_file" | xclip -selection clipboard
              fi
              echo "最新のスクリーンショットを登録しました！"
              echo "  元ファイル: $latest_file"
              echo "  -> $ss_dir/latest.png としてコピーしました。"
              echo "  (クリップボードにコピーしたため、チャットへ Ctrl+V で直接貼り付け可能です)"
          else
              echo "スクリーンショットが見つかりませんでした。($ss_dir)"
          fi
      }

      # zoxide の初期化（nvmロード後に実行することで、nvm内部のcd処理との衝突を防ぐ）
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"

      # Run fastfetch on interactive shell startup
      if [[ -o interactive ]] && command -v fastfetch >/dev/null; then
          fastfetch
      fi
    '';
  };
}
