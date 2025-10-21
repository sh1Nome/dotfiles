# dotfiles

本リポジトリは、LinuxおよびWindows環境で利用できる各種設定ファイル（dotfiles）を管理しています。  
また、それらのシンボリックリンクを自動で作成・削除するバイナリが含まれています。

## 方針

本リポジトリは、シンプルな構成を心がけています。  
必要になったものを追加し、使わなくなったものを（できるだけ）削除します。  
WindowsとDebianのどちらでも同じように開発できること、またVSCodeとneovimで統一感のある操作体験を得られることを重視しています。  
LSPやAI関連の作業はVSCodeで行います。  
各ツールや環境のデフォルト設定を意識して管理しています。  
操作は主にキーボードで行い、マウスは補助的に使う方針です。

## 管理しているツール

* Bash
* Powershell（Windows）
* Git
* Vim
* neovim
* VSCode

## セットアップ

セットアップは`setup/bin`配下のバイナリを実行するだけです。  
注意：dotfilesリポジトリの設定ファイルを相対パスで参照しているので、バイナリは移動しないでください。

* setup：シンボリックリンクの作成（ツールのインストールは未対応）
* remove：シンボリックリンクの削除
  * Vimのデータディレクトリも削除（Linuxの場合は`~/.vim`、Windowsの場合は`~/vimfiles`）
  * neovimのデータディレクトリも削除（Linuxの場合は`~/.local/share.nvim`、Windowsの場合は`~/AppData/Local/nvim-data`）

### Windows環境の注意

このリポジトリのセットアップは、`$PROFILE`および`$APPDATA`のパスを変更していないことが前提です。  
これらのパスを変更している場合は、dotfilesのリンク先や動作に問題が生じる可能性があります。  
なお、Windows環境でsetupスクリプトを実行すると、PowerShellの実行ポリシーが自動でRemoteSignedに変更されます。

### 補足

`setup`スクリプトを実行すると、「現在のdotfilesシンボリックリンク一覧」が表示されます。  
dotfilesで管理していないシンボリックリンクは「その他」として区別されます。  
不要なシンボリックリンクを簡単に探せます。

## VSCodeの拡張機能

`.vscode`ディレクトリで、VSCodeの推奨拡張機能を管理しています。

### 推奨拡張機能のインストール

このリポジトリをルートにVSCodeを開くと、`.vscode/extensions.json`に記載された推奨拡張機能のインストールを促す通知が表示されます。これにより、環境を簡単に統一できます。

## Tips

Windows環境とWSL環境どちらでも使いたい場合、Windows環境にdotfilesをクローンして、WSL環境から`/mnt/c/`以下のクローンしたdotfilesにシンボリックリンクを貼る運用がおすすめです。

## 開発者向けガイド

### ビルド方法

`setup/build.sh`でビルドできます。`docker`コマンドを`sudo`なしで実行できる必要があります。

### テスト

ビルド済みバイナリをテストするには以下のコマンドを使えます。

```bash
docker run --rm -it \
  -v "$(pwd)":/home/testuser/dotfiles \
  debian bash -c "\
    groupadd -g $(id -g) testgroup && \
    useradd -u $(id -u) -g $(id -g) -m testuser && \
    chsh -s /bin/bash testuser && \
    chown -R $(id -u):$(id -g) /home/testuser && \
    cd /home/testuser && \
    su - testuser \
  "
```
