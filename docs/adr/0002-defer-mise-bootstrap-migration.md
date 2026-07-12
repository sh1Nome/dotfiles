# mise bootstrap への移行を見送る

## Status

Accepted

## Context

chezmoi から `mise bootstrap` への移行を検討したが、次の要件を満たせない。

- mise の Tera テンプレートと chezmoi の `exact_` 相当の削除同期を両立できない
- Windows のシステムパッケージを `[bootstrap.packages]` で管理できない
- Windows では mise タスクを使用しない

## Decision

現時点では `mise bootstrap` へ移行しない。

## Consequences

- chezmoi、mise `[tools]`、Makefile の構成を維持する
- セットアップは複数コマンドのままとなる
- mise が上記の制約を解消した場合に再評価する
