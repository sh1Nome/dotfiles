# Windows では mise タスクを使用しない

## Status

Accepted

## Context

Windows では MSYS2 UCRT64 の bash から mise を利用している。  
mise タスクは既定で `cmd /c` を使う。bash を直接指定すると、実行環境や引数処理で問題が起きた。  
原因の詳細は検証していない。

## Decision

Windows では mise タスクを使用せず、Makefile を使用する。

## Consequences

MSYS2 と `cmd` の実行環境が混在する問題を避けられる。  
一方、mise タスクへ処理を統合できない。
