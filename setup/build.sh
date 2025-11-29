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

# スクリプトのあるディレクトリ（setup/）に移動
cd "$(dirname "$0")"

# setup/binディレクトリのクリーン
rm -rf ./bin
mkdir -p ./bin

# ビルド
echo "Building $f for linux/amd64..."
GOOS=linux GOARCH=amd64 go build -v -o "bin/setup-linux-amd64" "setup.go"
GOOS=linux GOARCH=amd64 go build -v -o "bin/remove-linux-amd64" "remove.go"
echo "Building $f for windows/amd64..."
GOOS=windows GOARCH=amd64 go build -v -o "bin/setup-windows-amd64.exe" "setup.go"
GOOS=windows GOARCH=amd64 go build -v -o "bin/remove-windows-amd64.exe" "remove.go"

# bin以下のファイルに実行権限を付与
chmod +x ./bin/*
