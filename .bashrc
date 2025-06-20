# ~/.bashrc: bash(1) の非ログインシェルで実行されます。
# サンプルについては /usr/share/doc/bash/examples/startup-files (bash-doc パッケージ内) を参照してください。

# 対話的でない場合は何もしません
case $- in
    *i*) ;;
      *) return;;
esac

# 履歴に重複行やスペースで始まる行を記録しない
# 詳細は bash(1) を参照
HISTCONTROL=ignoreboth

# 履歴ファイルに追記し、上書きしない
shopt -s histappend

# 履歴の長さは HISTSIZE と HISTFILESIZE で設定
HISTSIZE=1000
HISTFILESIZE=2000

# 各コマンド実行後にウィンドウサイズを確認し、必要なら LINES と COLUMNS を更新
shopt -s checkwinsize

# パターン "**" をパス名展開で使用すると、すべてのファイルとディレクトリ・サブディレクトリにマッチ
#shopt -s globstar

# less を非テキスト入力ファイルでも使いやすくする
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# 作業中の chroot を識別する変数を設定（プロンプトで使用）
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# 派手なプロンプトを設定（色なし、ただし色が必要な場合は色付き）
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# カラープロンプトを有効にするにはコメントを外す（デフォルトは無効）
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# カラーサポートありとみなす（Ecma-48 準拠を想定）
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# xterm の場合はタイトルに user@host:dir を表示
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ls のカラーサポートを有効化し、便利なエイリアスを追加
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# GCC の警告やエラーを色付きで表示
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# その他の ls エイリアス
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# エイリアス定義
# 追加は直接ここではなく、~/.bash_aliases など別ファイルに記載するのが推奨
# 詳細は bash-doc パッケージの /usr/share/doc/bash-doc/examples を参照

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
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
