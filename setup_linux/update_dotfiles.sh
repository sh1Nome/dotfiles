#!/bin/sh

# dotfilesディレクトリの絶対パスを取得
DOTFILES_DIR="$(cd "$(dirname "$0")/.."; pwd)"

# 既存のシンボリックリンクを削除
echo "既存のシンボリックリンクを削除します..."
sh "$DOTFILES_DIR/setup_linux/remove_dotfile_links.sh"

# 新しいシンボリックリンクを作成
echo "新しいシンボリックリンクを作成します..."
sh "$DOTFILES_DIR/setup_linux/setup_dotfiles.sh"

echo "dotfilesのアップデートが完了しました。"
