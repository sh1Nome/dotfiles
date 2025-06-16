# dotfiles

このリポジトリは、Linux および Windows 環境で利用できる各種設定ファイル（dotfiles）を管理しています。  
また、それらのシンボリックリンクを自動で作成・削除・更新するスクリプトが含まれています。

## 管理しているツール

- Vim
- Git
- VSCode

## 各種スクリプトについて

### Linux 用スクリプト

`linux/` ディレクトリには、以下のスクリプトが含まれています。

- セットアップ用: `setup_dotfiles.sh`
- 削除用: `remove_dotfile_links.sh`
- アップデート用: `update_dotfiles.sh`

### Windows 用スクリプト

`windows/` ディレクトリには、以下のスクリプトが含まれています。

- セットアップ用: `setup_dotfiles.bat`
- 削除用: `remove_dotfile_links.bat`
- アップデート用: `update_dotfiles.bat`

また、`windows/ps1/` には PowerShell 用の同様のスクリプトも用意されています。

## 開発者向けガイド

新しいツールや設定を dotfiles に追加する場合は、必ず Linux および Windows 向けの各種スクリプト（セットアップ・削除・アップデート用）を修正し、README にもその内容を反映してください。
