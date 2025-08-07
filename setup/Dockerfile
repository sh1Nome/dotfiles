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

FROM golang:1.24.5

# 作業ディレクトリを指定
WORKDIR /workspace

# Goのソースコードをコンテナにコピー
COPY ./src/* ./

# Goファイルをビルドしてbinに配置する
RUN mkdir bin && \
    for f in setup.go remove.go; do \
        name=$(basename "$f" .go); \
        # Linux amd64
        GOOS=linux GOARCH=amd64 go build -o "bin/${name}-linux-amd64" "$f"; \
        # Linux arm64
        GOOS=linux GOARCH=arm64 go build -o "bin/${name}-linux-arm64" "$f"; \
        # Windows amd64
        GOOS=windows GOARCH=amd64 go build -o "bin/${name}-windows-amd64.exe" "$f"; \
    done

# コンテナを起動し続けるためのコマンド
CMD ["tail", "-f", "/dev/null"]