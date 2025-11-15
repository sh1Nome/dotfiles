#!/bin/sh

# エラーが起きたらその時点で終了
set -e

# スクリプトのあるディレクトリ（setup/）に移動
cd "$(dirname "$0")"

# イメージ名とコンテナ名
IMAGE_NAME=dotfiles-golang-setup-dev
CONTAINER_NAME=dotfiles-golang-setup-container-dev

# Dockerイメージをビルド
docker build --target dev --no-cache -t "$IMAGE_NAME" .

# コンテナを起動
docker run --init -it --rm -v $HOME/.config/nvim:/root/.config/nvim --name "$CONTAINER_NAME" "$IMAGE_NAME" bash

# イメージを削除
docker rmi "$IMAGE_NAME"

# bin以下のファイルに実行権限を付与
chmod +x ./bin/*
