# dotfiles

Linux および Windows 環境で利用できる各種設定ファイルを管理しています。

## 方針

必要になったものを追加し、使わなくなったものを削除します。  
Linux と Windows 、また Neovim と VS Code で同じように開発できることを重視しています。  
操作は主にキーボードで行い、マウスは補助的に使う方針です。  
Neovim のキーマップは leader キーのあとに1文字だけ使える制約で設定しています。  
例外的に zk コマンドは `<leader>z` をプレフィックスとして使用しています。

## 前提

* Git
* chezmoi
* mise
* Noto Sans Mono CJK
* MSYS2（Windows の場合）

## セットアップ

1. `chezmoi init git@github.com:sh1Nome/dotfiles.git`
    * https の場合は `chezmoi init https://github.com/sh1Nome/dotfiles.git`
1. `chezmoi -v apply`
1. `mise install`

## xfce4 設定の反映

`chezmoi apply` だけでは xfce4 の設定は反映されません。

```sh
pkill xfconfd
```

その後ログインし直すと xfconfd が再起動し、設定が読み込まれます。
