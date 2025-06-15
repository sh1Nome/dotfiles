#!/bin/sh

DOTFILES_DIR="$(cd "$(dirname "$0")"; pwd)"

ln -sfn "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -sfn "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$DOTFILES_DIR/.gitconfig.local" "$HOME/.gitconfig.local"

echo "シンボリックリンクを作成しました。"
