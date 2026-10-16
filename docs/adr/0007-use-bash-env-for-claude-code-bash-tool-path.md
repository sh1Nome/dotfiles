# Claude Code の Bash ツールに PATH 設定を届けるため BASH_ENV を使う

## Status

Accepted

## Context

ADR 0006 に従い `CLAUDE_CODE_GIT_BASH_PATH` に MSYS2 の bash.exe を直接指定している。  
確認したところ、Windows の Claude Code で Bash ツールが起動する bash は非ログイン・非対話シェルだった。  
対話シェルは `.bashrc` を読み込むが、Bash ツールが起動する非ログイン・非対話シェルは読み込まない。  
そのため、`.bashrc` で PATH に追加している mise の shims、aqua、`~/.local/bin` は Bash ツールに反映されず、`gh` など mise 管理のコマンドが見つからなくなる。

対応策として次を試した。

- `CLAUDE_CODE_GIT_BASH_PATH` をログインシェル起動のラッパーに差し替える
  - Claude Code が bash と認識せず起動不能になった
- `settings.json` の `env.PATH` に PATH 文字列を直接書く
  - 環境が変わるたびに手動更新が必要になる
- bash 標準の `BASH_ENV`（非対話シェルの起動時に読み込むファイルを指定する仕組み）を使う
  - `.bashrc` の対話限定の制約と無関係に動作する

`BASH_ENV` の指定場所には2通りある。

- `settings.json` の `env.BASH_ENV` に明示する
- `.bashrc` で `export` し、WezTerm の対話シェルから環境変数を継承させる
    - この方法は WezTerm 経由以外の起動では機能しない

Claude Code の起動経路は WezTerm 経由のみである。

## Decision

PATH の構築を含む環境変数の定義を `.bashrc` から `~/.bash_env` に切り出す。  
`.bashrc` は `export BASH_ENV=~/.bash_env` と `source "$BASH_ENV"` の2行のみとする。  
`settings.json` には `BASH_ENV` を設定しない。

## Consequences

- 環境変数の定義を `.bash_env` に一本化でき、対話・非対話どちらのシェルも同じロジックを共有する
- `settings.json` に理由の読み取りにくい設定を増やさずに済む
- Claude Code を WezTerm 以外の経路から起動すると環境変数を継承できず、mise 等の PATH 設定が Bash ツールに届かない
- 環境変数は WezTerm の対話シェル → claude.exe → Bash ツールの bash という3段階で継承するため、挙動を把握するには経路全体を理解する必要がある
- `.bash_env` 内で bash を起動する子プロセス（aqua root-dir 経由の ldd など）は、`BASH_ENV` を継承して `.bash_env` を再帰的に source してしまう。そのため、source 中は `BASH_ENV` の値を退避して unset し、終了時に復元している

## Update

WezTerm から Alacritty へ移行した。その他の条件は変更していない。
