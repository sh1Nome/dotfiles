############################################################
# このDockerfileは、Goのソースコードをビルドし、
# binディレクトリにバイナリを配置するためのものです。
# build.sh スクリプトから呼び出されて利用されます。
# 主な処理:
# 1. golangイメージをベースに作業ディレクトリを設定
# 2. Goファイルをコンテナにコピー
# 3. Goバイナリをbinディレクトリにビルド
# 4. コンテナを起動し続ける
############################################################

# ベースステージ
FROM golang:1.24.5 AS base

# 作業ディレクトリを指定
WORKDIR /workspace


# ビルドステージ
FROM base AS build

# Goのソースコードをコンテナにコピー
COPY ./src/ ./

# Goファイルをビルドしてbinに配置する
RUN set -e; \
    mkdir bin; \
    for f in setup.go remove.go; do \
        name=$(basename "$f" .go); \
        echo "Building $f for linux/amd64..."; \
        GOOS=linux GOARCH=amd64 go build -v -o "bin/${name}-linux-amd64" "$f"; \
        echo "Building $f for windows/amd64..."; \
        GOOS=windows GOARCH=amd64 go build -v -o "bin/${name}-windows-amd64.exe" "$f"; \
    done

# コンテナを起動し続けるためのコマンド
CMD ["tail", "-f", "/dev/null"]


# 開発ステージ
FROM base AS dev

# nvimをインストール
RUN curl -LO --progress-bar https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage && \
    chmod 755 nvim-linux-x86_64.appimage && \
    mkdir -p /opt/nvim && \
    mv nvim-linux-x86_64.appimage /opt/nvim/nvim

# コンテナを起動し続けるためのコマンド
CMD ["tail", "-f", "/dev/null"]
