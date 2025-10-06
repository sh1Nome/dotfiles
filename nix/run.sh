#!/bin/sh
# Dockerイメージをビルドし、起動するスクリプト
set -e

IMAGE_NAME=dotfiles-nix
CONTAINER_NAME=dotfiles-nix-dev

# ビルド
docker build -t $IMAGE_NAME .

# 既存コンテナがあれば削除
if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
	docker rm -f $CONTAINER_NAME
fi

# 起動
docker run --rm -it \
	--name $CONTAINER_NAME \
	-v "$(pwd)/..:/home/sh1nome/dotfiles" \
	$IMAGE_NAME
