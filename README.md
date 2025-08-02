# dotfiles

このリポジトリは、Linux および Windows 環境で利用できる各種設定ファイル（dotfiles）を管理しています。  
また、それらのシンボリックリンクを自動で作成・削除・更新するスクリプトが含まれています。

## 管理しているツール

- Bash（Linux）
- Powershell（Windows）
- Vim
- Git
- VSCode
- Alacritty

## 各種スクリプトについて

### Linux 用スクリプト

`setup_linux/` ディレクトリには、以下のスクリプトが含まれています。

- セットアップ用: `setup_dotfiles.sh`
- 削除用: `remove_dotfile_links.sh`
- アップデート用: `update_dotfiles.sh`

### Windows 用スクリプト

`setup_windows/` ディレクトリには、以下のスクリプトが含まれています。

- セットアップ用: `setup_dotfiles.bat`
- 削除用: `remove_dotfile_links.bat`
- アップデート用: `update_dotfiles.bat`

また、`setup_windows/ps1/` には PowerShell 用の同様のスクリプトも用意されています。

### 補足

`setup_dotfiles`スクリプトを実行すると、「現在の dotfiles シンボリックリンク一覧」が表示されます。  
dotfiles で管理していないシンボリックリンクは「その他」として区別されます。  
「その他」に表示された不要なシンボリックリンクは、手動で削除してください。  
なお、不要かどうかの判断はご自身の責任で行ってください。

## VSCode の拡張機能

`.vscode` ディレクトリで、VSCode の推奨拡張機能を管理しています。

### 推奨拡張機能のインストール

このリポジトリをルートに VSCode を開くと、`.vscode/extensions.json` に記載された推奨拡張機能のインストールを促す通知が表示されます。これにより、環境を簡単に統一できます。

## Tips

Windows 環境と WSL 環境どちらでも使いたい場合、Windows 環境に dotfiles をクローンして、WSL 環境から`/mnt/c/`以下のクローンした dotfiles にシンボリックリンクを貼る運用がおすすめです。

## 開発者向けガイド

新しいツールや設定を dotfiles に追加する場合は、必ず Linux および Windows 向けの各種スクリプト（セットアップ・削除・アップデート用）を修正し、README にもその内容を反映させてください。  
**注意:** PowerShell 用の `.ps1` ファイルは、BOM (Byte Order Mark) 付きの UTF-8 で保存してください。BOM なしの場合、スクリプトが正しく動作しないことがあります。
