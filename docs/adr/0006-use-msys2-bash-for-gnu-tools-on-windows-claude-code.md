# Windows の Claude Code では MSYS2 の bash を GNU ツール用に使う

## Status

Accepted

## Context

Windows ネイティブの Claude Code はコマンド実行に PowerShell ツールまたは Bash ツールを使う。  
開発環境には既に MSYS2 UCRT64 を導入しており、 Git for Windows を別途導入すると、git 本体と DLL が二重管理になる。  
Claude Code の Bash ツールは Windows では Git Bash の自動検出、または settings.json の `env.CLAUDE_CODE_GIT_BASH_PATH` による bash.exe の明示指定で有効になる。  
公式ドキュメント（https://code.claude.com/docs/en/tools-reference.md）は MSYS2 への言及がない。  
`env.CLAUDE_CODE_GIT_BASH_PATH` に `C:\msys64\usr\bin\bash.exe` を指定して検証した結果、Bash ツールが正常に動作した。

Claude Code は WezTerm 経由（`dot_config/exact_wezterm/wezterm.lua` の `default_prog` が `start_ucrt64.cmd`）で起動しており、  
親プロセスの MSYS2 UCRT64 ログインシェルから `MSYSTEM` や `PATH` を継承している。  
MSYS2 公式ドキュメント（https://www.msys2.org/wiki/Launchers/）は sh.exe の直接起動を推奨せず、  
ログインシェルとして起動し `MSYSTEM` 環境変数を設定することを求めている。  
実際に Claude Code の Bash ツールが起動する bash は `login_shell off` であり、この推奨に従っていない。

## Decision

Windows の Claude Code では、GNU ツールの提供元に Git for Windows ではなく既存の MSYS2 UCRT64 環境を使う。  
settings.json の `env.CLAUDE_CODE_GIT_BASH_PATH` に MSYS2 の bash.exe（`C:\msys64\usr\bin\bash.exe`）を指定し、Bash ツールを有効化する。  
`env.CLAUDE_CODE_USE_POWERSHELL_TOOL` を `"0"` に設定し、PowerShell ツールを無効化する。

Claude Code は WezTerm（`start_ucrt64.cmd`）経由での起動のみをサポート範囲とする。

## Consequences

- Git for Windows を追加導入せずに、既存の MSYS2 UCRT64 環境だけで GNU ツールが使える
- コマンド実行ツールを Bash に一本化できる
- Claude Code の Bash ツールが起動する bash はログインシェルではなく、`MSYSTEM` や `PATH` の設定は WezTerm 経由の親プロセスからの環境変数継承に依存する
- WezTerm 以外の経路（別ターミナル、タスクスケジューラなど）から Claude Code を起動すると、この継承が働かず動作しない可能性がある
- MSYS2 を bash.exe として使う構成は Claude Code の公式サポート対象外であり、将来の実装変更で動作しなくなるリスクがある
