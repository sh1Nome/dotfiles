#!/bin/sh

# 削除対象のシンボリックリンク
links="\
    $HOME/.bashrc \
    $HOME/.vimrc \
    $HOME/.gitconfig \
    $HOME/.gitconfig.local \
    $HOME/.config/Code/User/settings.json \
    $HOME/.config/Code/User/keybindings.json \
    $HOME/.config/Code/User/prompts \
"

# シンボリックリンクを削除
for link in $links; do
    # シンボリックリンクかディレクトリであるかを確認
    if [ -L "$link" ] || [ -d "$link" ]; then
        rm -rf "$link"
        echo "$link を削除しました。"
    else
        echo "$link はシンボリックリンクでもディレクトリでもないか、存在しません。"
    fi
done

echo "シンボリックリンクの削除が完了しました。"
