#!/bin/sh

# Neovim AppImageを/opt/nvimに配置するスクリプト
set -e

# root権限でなければエラーで終了
if [ "$(id -u)" -ne 0 ]; then
	echo "このスクリプトはroot権限で実行してください (例: sudo sh $0)" >&2
	exit 1
fi

curl -LO --progress-bar https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod 755 nvim-linux-x86_64.appimage
mkdir -p /opt/nvim
mv nvim-linux-x86_64.appimage /opt/nvim/nvim

echo "Neovim AppImageを/opt/nvimにインストールしました。"
