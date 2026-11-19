# sbx kit のビルドに Debian trixie を使う

## Status

Accepted

## Context

`git-personal` は Git をソースからビルドする。従来のビルド元である `sbx/codex:latest` は、確認時点で Docker Hardened Images（DHI）の Debian 13（trixie）を使っていた。`libcurl4-openssl-dev` の間接依存である `nettle-dev` が要求するバージョンと、イメージに入っていた `libnettle8t64`、`libhogweed6t64` のバージョンが食い違い、APT が依存関係を解決できなかった。

sbx の v3 mixin は、最終ステージの Dockerfile が追加・変更したファイルを実行先に適用する。ビルド済みの実行ファイルだけをコピーする場合、その実行ファイルが必要とする共有ライブラリは実行先に必要となる。[Docker の mixin 仕様](https://docs.docker.com/ai/sandboxes/customize/author/tool-mixins/)

## Decision

- `git-personal`、`hunk`、`tgrep`、`codex-personal` のビルドステージに `debian:trixie-slim` を使う。Debian の世代を実行先の Codex に合わせる。各 kit は `scratch` の最終ステージに必要な成果物をコピーする。
- `pstack` は `sbx/codex:latest` を使う。Codex 向けの kit であり、DHI の `nodejs-24` から Node.js の実行ファイルを取り出す。
- `ffmpeg` は `sbx/codex:latest` を使い、ビルド時に FFmpeg と日本語フォントを APT で入れる。実行先と同じ系統のイメージで依存関係を解決する。
- `claude-personal` は `scratch` から静的ファイルを配布する。

## Consequences

- 4件のビルドは Codex イメージ内の APT パッケージ構成に依存しなくなる。`trixie-slim` は Debian の世代を固定するタグで、同じ世代内の更新は取り込む。
- Codex のベースイメージが変わった場合は、Git と配布バイナリに必要な共有ライブラリや、`tomlkit` と Python の互換性を確認する。`pstack` と `ffmpeg` は Codex イメージの変更がビルド時の依存解決にも影響する。
- Docker ビルド後、現在の DHI 環境で Git の HTTPS 通信と相対パスの worktree 作成、`hunk` と `tgrep` の起動、`tomlkit` の読み書きを確認した。sbx で kit を適用できることも確認した。
