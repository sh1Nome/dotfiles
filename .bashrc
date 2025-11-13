# 対話的でない場合は何もしない
case $- in
    *i*) ;;
      *) return;;
esac

# 履歴に重複行やスペースで始まる行を記録しない
HISTCONTROL=ignoreboth

# 履歴ファイルに追記し、上書きしない
shopt -s histappend

# 履歴の長さは HISTSIZE と HISTFILESIZE で設定
HISTSIZE=1000
HISTFILESIZE=2000

# 各コマンド実行後にウィンドウサイズを確認し、必要なら LINES と COLUMNS を更新
shopt -s checkwinsize

# ターミナルの種類が xterm-color または 256色対応の場合、色付きプロンプトを有効化
case "$TERM" in
    xterm-color|*-256color)
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            color_prompt=yes
        fi
        ;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='\[\033]0;\W\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '
else
    PS1='\[\033]0;\W\a\]\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# Gitブランチ名を取得する関数
parse_git_branch() {
  branch=$(git branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    echo "(git:$branch)"
  fi
}

# ls のカラーサポートを有効化し、エイリアスを追加
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# ANSI カラー 4番 ( 青 ) を #3a7fff に変更
printf "\e]4;4;#3a7fff\a"

# プログラマブル補完機能を有効化
# /etc/bash.bashrc ですでに有効なら不要
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# nvim
export PATH="$PATH:/opt/nvim/"
export EDITOR=nvim

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
