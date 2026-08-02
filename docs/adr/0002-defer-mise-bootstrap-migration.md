# mise bootstrap への移行を見送る

## Status

Accepted

## Context

chezmoi から `mise bootstrap` への移行を検討したが、次の要件を満たせない。

- mise の Tera テンプレートと chezmoi の `exact_` 相当の削除同期を両立できない
- Windows のシステムパッケージを `[bootstrap.packages]` で管理できない
- Windows では mise タスクを使用しない

2026 年 8 月時点の mise ドキュメント（https://mise.jdx.dev/dotfiles.html 、https://mise.jdx.dev/templates.html ）で、削除とパーミッションの扱いを再確認した。

- `symlink-each` は mise 自身が作成したシンボリックリンクだけを prune し、管理外のファイルは残す。`exact_` の「ディレクトリの中身をソースと完全一致させる」挙動には届かない
- `[dotfiles]` の `mode` は配置方式（`symlink` / `symlink-each` / `copy` / `template`）を指し、パーミッションを指定するキーはない。`private_` と `executable_` に相当する宣言ができない
- `symlink` モードならソース側の権限が透過するが、Windows ではシンボリックリンクが copy にフォールバックするため権限が崩れる

## Decision

現時点では `mise bootstrap` へ移行しない。

## Consequences

- chezmoi、mise `[tools]`、Makefile の構成を維持する
- セットアップは複数コマンドのままとなる
- mise が上記の制約を解消した場合に再評価する
