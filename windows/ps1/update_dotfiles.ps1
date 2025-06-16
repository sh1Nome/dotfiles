# このスクリプトは、Windows環境でdotfiles（設定ファイル群）のアップデート（再作成）を行うものです。
# PowerShellの基本が分からなくても、何をしているか分かるように日本語で詳細なコメントを付けています。

# dotfilesディレクトリ（このスクリプトの2つ上の階層）のパスを取得します。
$DOTFILES_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# まず、既存のシンボリックリンクを削除することをユーザーに伝えます。
Write-Host "既存のシンボリックリンクを削除します..."
& "$DOTFILES_DIR\windows\ps1\remove_dotfile_links.ps1"

# 次に、新しいシンボリックリンクを作成することをユーザーに伝えます。
Write-Host "新しいシンボリックリンクを作成します..."
& "$DOTFILES_DIR\windows\ps1\setup_dotfiles.ps1"

# 全ての処理が終わったことをユーザーに伝えます。
Write-Host "dotfilesのアップデートが完了しました。"

# ユーザーがEnterキーを押すまで待機します。
Read-Host -Prompt "Press Enter to exit"
