# Neovim と Claude Code を Makefile で管理する

## Status

Accepted

## Context

Neovim と Claude Code は mise `[tools]` のコマンドを呼び出す。  
Windows の mise は shims 方式で動作する。  
Neovim と Claude Code 自体を mise で管理すると、  
mise のインストールディレクトリが shims より前の `PATH` に入る。  
その結果、呼び出すコマンドの `.cmd` や `.bat` を解決できない場合がある。

## Decision

Neovim と Claude Code を mise `[tools]` で管理せず、Makefile から OS パッケージまたは公式インストーラーで導入する。

## Consequences

- Neovim と Claude Code から mise の shims を経由してツールを呼び出せる
- OS ごとの導入処理を Makefile で保守する必要がある
