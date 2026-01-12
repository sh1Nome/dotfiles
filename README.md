# dotfiles

本リポジトリは、LinuxおよびWindows環境で利用できる各種設定ファイル（dotfiles）を管理しています。

## 方針

本リポジトリは、シンプルな構成を心がけています。  
必要になったものを追加し、使わなくなったものを（できるだけ）削除します。  
DebianとWindows、またNeovimとVSCodeで同じように開発できることを重視しています。  
操作は主にキーボードで行い、マウスは補助的に使う方針です。  
Neovimのキーマップはleaderキーのあとに1文字だけ使える制約で設定しています。

## 管理しているツール

* Fcitx5（Linux）
* Wezterm
* Bash
* mise
* Vim
* neovim
* Git
* VSCode

## セットアップ

`setup/bin`配下のバイナリを実行したあとに`mise install`を実行してください。  
注意：dotfilesリポジトリの設定ファイルを相対パスで参照しているので、バイナリは移動しないでください。

### サブコマンド説明

* `link`：シンボリックリンクの作成（ツールのインストールは未対応）
* `unlink`：シンボリックリンクの削除
  * Vimのデータディレクトリも削除（Linuxの場合は`~/.vim`、Windowsの場合は`~/vimfiles`）
  * neovimのデータディレクトリも削除（Linuxの場合は`~/.local/share/nvim`、Windowsの場合は`~/AppData/Local/nvim-data`）
* `list`：現在作成されているシンボリックリンク一覧を表示

### Windows環境の注意

このリポジトリのセットアップは、`$PROFILE`および`$APPDATA`のパスを変更していないことが前提です。  
これらのパスを変更している場合は、dotfilesのリンク先や動作に問題が生じる可能性があります。  
なお、Windows環境でsetupスクリプトを実行すると、PowerShellの実行ポリシーが自動でRemoteSignedに変更されます。

## VSCodeの拡張機能

`.vscode`ディレクトリで、VSCodeの推奨拡張機能を管理しています。

### 推奨拡張機能のインストール

このリポジトリをルートにVSCodeを開くと、`.vscode/extensions.json`に記載された推奨拡張機能のインストールを促す通知が表示されます。これにより、環境を簡単に統一できます。

## Tips

Windows環境とWSL環境どちらでも使いたい場合、Windows環境にdotfilesをクローンして、WSL環境から`/mnt/c/`以下のクローンしたdotfilesにシンボリックリンクを貼る運用がおすすめです。

## 開発者向けガイド

### ビルド方法

`setup/build.sh`でビルドできます。

