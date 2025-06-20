# dotfiles

このリポジトリは、Linux および Windows 環境で利用できる各種設定ファイル（dotfiles）を管理しています。  
また、それらのシンボリックリンクを自動で作成・削除・更新するスクリプトが含まれています。

## 管理しているツール

- Bash（Linuxのみ）
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

## VSCode の拡張機能

`.vscode` ディレクトリで、VSCode の推奨拡張機能を管理しています。

### 推奨拡張機能のインストール

このリポジトリをルートに VSCode を開くと、`.vscode/extensions.json` に記載された推奨拡張機能のインストールを促す通知が表示されます。これにより、環境を簡単に統一できます。

## シンボリックリンクの確認方法

### Linux

```bash
find ~ -type l -exec ls -l {} + | grep 'dotfiles'
```

### Windows（PowerShell）

```powershell
Get-ChildItem -Path $HOME,$HOME\AppData\Roaming\Code\User -Force | Where-Object { $_.LinkType -eq 'SymbolicLink' -and $_.Target -match 'dotfiles' } | Select-Object FullName,Target
```

## Tips

Windows 環境と WSL 環境どちらでも使いたい場合、Windows 環境に dotfiles をクローンして、WSL 環境から`/mnt/c/`以下のクローンした dotfiles にシンボリックリンクを貼る運用がおすすめです。

## 開発者向けガイド

新しいツールや設定を dotfiles に追加する場合は、必ず Linux および Windows 向けの各種スクリプト（セットアップ・削除・アップデート用）を修正し、README にもその内容を反映させてください。
