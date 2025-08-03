#!/bin/sh

#############################################################################
# このスクリプトは、GoのソースコードをDockerコンテナでビルドし、
# 生成されたバイナリをbinディレクトリに取得するためのものです。
# 主な処理:
# 1. Dockerイメージのビルド
# 2. コンテナの起動とバイナリ取得
# 3. コンテナとイメージのクリーンアップ
#############################################################################


# エラーが起きたらその時点で終了
set -e

# イメージ名とコンテナ名
IMAGE_NAME=dotfiles-golang-setup
CONTAINER_NAME=dotfiles-golang-setup-container

# setup/binディレクトリのクリーン
rm -rf ./bin
mkdir -p ./bin

# Dockerイメージをビルド
docker build -t "$IMAGE_NAME" .

# コンテナを起動（バックグラウンドで）
docker run -d --init --name "$CONTAINER_NAME" "$IMAGE_NAME"

# コンテナからbinディレクトリをコピー
docker cp "$CONTAINER_NAME":/workspace/bin .

# コンテナを停止して削除
docker stop "$CONTAINER_NAME"
docker rm "$CONTAINER_NAME"

# イメージを削除
docker rmi "$IMAGE_NAME"
