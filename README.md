# dotfiles

Linux および Windows 環境で利用できる各種設定ファイルを管理しています。

## 方針

必要になったものを追加し、使わなくなったものを削除します。  
Linux と Windows 、また Neovim と VS Code で同じように開発できることを重視しています。  
操作は主にキーボードで行い、マウスは補助的に使う方針です。  
Neovim のキーマップは leader キーのあとに1文字だけ使える制約で設定しています。

## 前提

* Git
* chezmoi
* mise
* Noto Sans Mono CJK

## セットアップ

1. `chezmoi init git@github.com:sh1Nome/dotfiles.git`
    * https の場合は `chezmoi init https://github.com/sh1Nome/dotfiles.git`
1. `chezmoi -v apply`
1. `mise install`

## 管理しているツール

本リポジトリで管理しているツールと、各ツールのインストールについてです。  
[セットアップ](#セットアップ)で設定ファイルの配置をしますが、すべてのツールをインストールするわけではありません。

| ツール名         | インストール                   |
| :--------------- | :----------------------------- |
| Fcitx5 ( Linux ) | 未対応                         |
| Wezterm          | 未対応                         |
| Bash             | 未対応                         |
| mise             | 未対応                         |
| Vim              | 未対応                         |
| Neovim           | `mise install`                 |
| Git              | 未対応                         |
| VS Code          | `chezmoi apply` で拡張機能のみ |
| Skills           | `~/.claude` に配置             |
| opencode         | `mise install`                 |
| GitHub Copilot   | `mise install`                 |

