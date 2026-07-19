# =========================================================================
# Zsh 追加設定 (環境変数・オプション・キーバインド・カスタム関数)
# =========================================================================
# modules/shell/zsh/default.nix の initContent から source される実ファイル。
# --- zsh-autosuggestions設定 ---
# zsh-autosuggestionsの検索を非同期化し，ラグをゼロにする設定です．
export ZSH_AUTOSUGGEST_USE_ASYNC="true"
# 入力文字数が1文字以下の場合はサジェスト探索をスキップします（空ENTER時のラグを完全にゼロにするため）．
export ZSH_AUTOSUGGEST_MIN_SIZE=2

# --- パスおよび環境変数設定 ---
# 外部ツールなどのパスを追加します．
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/home/nalt/lib/ac-library-master
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin

# LS_COLORSのカラーパレット定義です．
export LS_COLORS="di=1;38;5;110:ex=1;38;5;109:ln=1;38;5;139:*.tar=1;38;5;203:*.tgz=1;38;5;203:*.zip=1;38;5;203:*.z=1;38;5;203:*.gz=1;38;5;203:*.bz2=1;38;5;203:*.deb=1;38;5;203:*.rpm=1;38;5;203:*.jar=1;38;5;203:*.rar=1;38;5;203:*.7z=1;38;5;203:*.xz=1;38;5;203:*.rs=1;38;5;151:*.js=1;38;5;151:*.ts=1;38;5;151:*.c=1;38;5;151:*.cpp=1;38;5;151:*.go=1;38;5;151:*.py=1;38;5;151:*.java=1;38;5;151:*.lua=1;38;5;151:*.html=1;38;5;151:*.css=1;38;5;151:*.md=1;38;5;151:*.json=1;38;5;151:*.toml=1;38;5;151:*.yaml=1;38;5;151:*.yml=1;38;5;151"

# --- シェルオプション設定 ---
# ディレクトリ移動（cdなしでの移動を許可）を有効化します．
setopt auto_cd

# 履歴保存オプションの追加拡張を設定します．
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
# HIST_REDUCE_BLANKS は行継続の "\" による改行も余分な空白とみなして
# 1行に詰めてしまい、履歴を遡ったときに複数行コマンドが潰れる原因になるため無効化
setopt HIST_FIND_NO_DUPS
setopt HIST_NO_STORE

# システムスタック制限の解除を行います（開発時等の安定化のため）．
ulimit -s unlimited

# --- 補完およびメニュー設定 ---
# 補完選択メニュー用モジュール（complist）をロードします．
zmodload zsh/complist

[ -f "$HOME/.cargo/env" ]  && . "$HOME/.cargo/env"

# 補完メニューの挙動最適化（大文字小文字の曖昧補完，カーソル選択）を設定します．
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# --- fzf設定 ---
# fzfオプションおよびCtrl+T，Ctrl+Rのプレビュー表示を設定します．
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=pointer:#e6c384,marker:#e6c384,prompt:#e6c384,info:#a292a3,hl:#a292a3,hl+:#a292a3'
# matugen生成のfzf配色があれば上書きします（matugen-applyが生成します）．
[[ -f ~/.cache/matugen/fzf-colors.sh ]] && source ~/.cache/matugen/fzf-colors.sh
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview,tab:down,btab:up'"

# --- キーマップ・Vimモード設定 ---
# Vi Mode（Vim風キーマップ）の有効化とインサート時のバックスペース調整を行います．
bindkey -v
bindkey "^?" backward-delete-char

# コマンドラインのVim編集機能を有効化します（ノーマルモードで 'v' でエディタ起動）．
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# 補完選択メニュー中のVim風（HJKL）移動キーマップを定義します．
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# --- 配色環境変数設定 ---
# matugen生成のstarship配色があればそちらを優先します．
[[ -f ~/.cache/matugen/starship.toml ]] && export STARSHIP_CONFIG=~/.cache/matugen/starship.toml

# matugen生成のlazygit完全設定があれば単一ファイルで渡します（マージ問題回避のため）．
[[ -f ~/.cache/matugen/lazygit-config.yml ]] && \
  export LG_CONFIG_FILE="$HOME/.cache/matugen/lazygit-config.yml"

# matugen生成のtealdeer(tldr)配色があればそちらを優先します．
[[ -f ~/.cache/matugen/tealdeer/config.toml ]] && \
  export TEALDEER_CONFIG_DIR="$HOME/.cache/matugen/tealdeer"

# ===================================================================
# カスタムシェル関数
# ===================================================================

# 1. ディレクトリを作成して即時に移動します．
mkcd() {
    mkdir -p "$1"
    cd "$1" || return
}

# 2. ディレクトリ移動 (cd) 後に自動的に eza (ls) を実行します．
function chpwd() {
    ls
}

# 3. 競技プログラミング用C++のコンパイル＆実行を行います．
runcpp() {
    g++ -std=c++20 -O2 "$1" -o "${1%.cpp}.out" && "./${1%.cpp}.out"
}
runcppio() {
    g++ -std=c++20 -O2 "$1" -o "${1%.cpp}.out" && "./${1%.cpp}.out" < input.txt > output.txt
}

# 4. WezTerm OSC 7サポート（新しいタブを開いた際のカレントディレクトリ同期用）を設定します．
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    wezterm_osc7() {
        printf "\033]7;file://%s%s\033\\" "$HOST" "$PWD"
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd wezterm_osc7
fi

# 5. ghq + fzfによる超高速ディレクトリジャンプを定義します．
function ghq-fzf() {
  local src=$(ghq list | fzf --bind 'tab:down,btab:up' --preview "ls -lap $(ghq root)/{} | tail -n+2 | head -n 200")
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

# 6. zsh-syntax-highlighting用のカスタムカラースタイルを設定します．
# Kanagawa Dragon 系の落ち着いた色に合わせる（ネオンな green/red,bold を回避）
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#98bb6c,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e46876,bold'

# 7. Windowsとの設定同期を行います（WSL環境用）．
function sync-win() {
    echo "Syncing WezTerm config..."
    cp ~/.config/wezterm/*.lua /mnt/c/Users/tnaru/.config/wezterm/
    mkdir -p /mnt/c/Users/tnaru/Tools/Customization
    # ~/.config/ahkは現在未使用（AHKはkomorebi.ahkのみ）．存在する場合だけ同期します．
    if [ -d ~/.config/ahk ]; then
        echo "Syncing AutoHotkey scripts..."
        cp -rL ~/.config/ahk/* /mnt/c/Users/tnaru/Tools/Customization/
    fi
    echo "Syncing Komorebi config..."
    mkdir -p /mnt/c/Users/tnaru/.config/komorebi
    cp -L ~/.config/komorebi/komorebi.json /mnt/c/Users/tnaru/.config/komorebi/
    cp -L ~/.config/komorebi/komorebi.ahk /mnt/c/Users/tnaru/.config/komorebi/
    cp -L ~/.config/komorebi/applications.json /mnt/c/Users/tnaru/.config/komorebi/
    # 読み込みの確実性を高めるため，ホーム直下にも配置します．
    cp -L ~/.config/komorebi/komorebi.json /mnt/c/Users/tnaru/
    cp -L ~/.config/komorebi/applications.json /mnt/c/Users/tnaru/
    rm -f "/mnt/c/Users/tnaru/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/komorebi.ahk"
    # スタートアップ・環境構築スクリプトの同期を行います．
    cp -L ~/.config/komorebi/startup.ps1 /mnt/c/Users/tnaru/Tools/Customization/
    cp -L ~/.config/komorebi/setup-windows.ps1 /mnt/c/Users/tnaru/Tools/Customization/
    echo "Syncing YASB config..."
    mkdir -p /mnt/c/Users/tnaru/.config/yasb
    cp -rL ~/.config/yasb/* /mnt/c/Users/tnaru/.config/yasb/
    # matugen生成済みパレットがあればstyles.cssに再適用します．
    [ -x ~/.local/bin/matugen-apply ] && ~/.local/bin/matugen-apply --reapply
    echo "Syncing Vivaldi CSS..."
    mkdir -p /mnt/c/Users/tnaru/Tools/Vivaldi
    cp -L ~/.config/vivaldi/custom.css /mnt/c/Users/tnaru/Tools/Vivaldi/custom.css
    echo "Done."
}

# 8. 最新のスクリーンショットをAntigravityチャットへ連携します（撮影した ~/Pictures/Screenshots/ 下の最新画像を同期）．
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
        echo "  -> $ss_dir/latest.png としてコピーしました．"
        echo "  （クリップボードにコピーしたため，チャットへ Ctrl+V で直接貼り付け可能です）"
    else
        echo "スクリーンショットが見つかりませんでした．($ss_dir)"
    fi
}
