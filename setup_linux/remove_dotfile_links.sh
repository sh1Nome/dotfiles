#!/bin/sh

# 削除対象のシンボリックリンク
links="\
    $HOME/.bashrc \
    $HOME/.vimrc \
    $HOME/.gitconfig \
    $HOME/.gitconfig.local \
    $HOME/.config/Code/User/settings.json \
    $HOME/.config/Code/User/keybindings.json \
    $HOME/.alacritty.toml \
"

# シンボリックリンクを削除
for link in $links; do
    if [ -L "$link" ]; then
        rm "$link"
        echo "$link を削除しました。"
    else
        echo "$link はシンボリックリンクではないか、存在しません。"
    fi
done

echo "シンボリックリンクの削除が完了しました。"
