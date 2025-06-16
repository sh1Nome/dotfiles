# dotfilesアップデートスクリプト（Windows用）

$DOTFILES_DIR = Split-Path -Parent $PSScriptRoot

Write-Host "既存のシンボリックリンクを削除します..."
powershell -ExecutionPolicy Bypass -File "$DOTFILES_DIR\windows\remove_dotfile_links.ps1"

Write-Host "新しいシンボリックリンクを作成します..."
powershell -ExecutionPolicy Bypass -File "$DOTFILES_DIR\windows\setup_dotfiles.ps1"

Write-Host "dotfilesのアップデートが完了しました。"

Read-Host -Prompt "Press Enter to exit"
