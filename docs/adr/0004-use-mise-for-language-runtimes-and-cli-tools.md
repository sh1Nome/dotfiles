# 言語環境と CLI ツールの管理に mise を使用する

## Status

Accepted

## Context

開発環境として Fedora と Windows MSYS2 を使用している。  
ここでいう Windows は Windows ネイティブ環境と MSYS2 を指し、WSL を含まない。

言語環境と CLI ツールを両方の開発環境で管理する必要がある。  
aqua は言語環境を管理できない。  
Nix は WSL 上で利用できるが、Windows ネイティブ環境では動作しない。

## Decision

言語環境と CLI ツールの管理に mise を使用する。

## Consequences

- Fedora と Windows MSYS2 で言語環境と CLI ツールを一元管理できる
- mise 固有の設定方法と運用方法を覚える必要があるが、負担は小さい
- mise が対応しないツールは別の方法で管理する必要がある
