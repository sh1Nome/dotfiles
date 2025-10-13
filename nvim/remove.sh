#!/bin/sh

# Neovim AppImage（/opt/nvim/nvim）を削除するスクリプト
set -e

# root権限でなければエラーで終了
if [ "$(id -u)" -ne 0 ]; then
	echo "このスクリプトはroot権限で実行してください (例: sudo sh $0)" >&2
	exit 1
fi

if [ -f /opt/nvim/nvim ]; then
	rm /opt/nvim/nvim
	echo "/opt/nvim/nvim を削除しました。"
else
	echo "/opt/nvim/nvim は存在しません。"
fi

# ディレクトリが空なら/opt/nvimも削除
if [ -d /opt/nvim ] && [ "$(ls -A /opt/nvim)" = "" ]; then
	rmdir /opt/nvim
	echo "/opt/nvim ディレクトリを削除しました。"
fi
