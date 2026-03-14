# dotfiles

Linux および Windows 環境で利用できる各種設定ファイルを管理しています。

## 方針

本リポジトリは、シンプルな構成を心がけています。  
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

### ツールのインストール

mise で管理しているものを除き、ツールのインストーラーは用意していません。

## 管理しているツール

* Fcitx5 ( Linux )
* Wezterm
* Bash
* mise
* Vim
* Neovim
* Git
* VS Code
* Skills
* opencode

##  VS Code の拡張機能

`chezmoi -v apply` の実行時に VS Code の拡張機能がインストールされます。  
インストールする拡張機能は `run_install_vscode_extensions.sh` に定義しています。  
`code` コマンドが使えない場合、スキップされます。

