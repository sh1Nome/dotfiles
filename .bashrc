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

# 派手なプロンプトを設定（色なし、ただし色が必要な場合は色付き）
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# カラープロンプトを有効にするにはコメントを外す（デフォルトは無効）
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# カラーサポートありとみなす（Ecma-48 準拠を想定）
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# ls のカラーサポートを有効化し、エイリアスを追加
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# プログラマブル補完機能を有効化
# /etc/bash.bashrc ですでに有効なら不要
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
