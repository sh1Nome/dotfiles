# dotfilesセットアップスクリプト（Windows用）

$DOTFILES_DIR = Split-Path -Parent $PSScriptRoot

# Gitユーザー名とメールアドレスを対話的に取得
$git_user = Read-Host "Gitのユーザー名を入力してください"
$git_email = Read-Host "Gitのメールアドレスを入力してください"

# .gitconfig.local を作成・更新
@"
[user]
    name = $git_user
    email = $git_email
"@ | Set-Content -Encoding UTF8 "$DOTFILES_DIR\.gitconfig.local"

# 各種設定ファイルのシンボリックリンクを作成
New-Item -ItemType SymbolicLink -Path "$HOME\.vimrc" -Target "$DOTFILES_DIR\.vimrc" -Force | Out-Null
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$DOTFILES_DIR\.gitconfig" -Force | Out-Null
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig.local" -Target "$DOTFILES_DIR\.gitconfig.local" -Force | Out-Null

$codeUserDir = "$HOME\AppData\Roaming\Code\User"
if (!(Test-Path $codeUserDir)) {
    New-Item -ItemType Directory -Path $codeUserDir | Out-Null
}
New-Item -ItemType SymbolicLink -Path "$codeUserDir\settings.json" -Target "$DOTFILES_DIR\vscode\settings.json" -Force | Out-Null
New-Item -ItemType SymbolicLink -Path "$codeUserDir\keybindings.json" -Target "$DOTFILES_DIR\vscode\keybindings.json" -Force | Out-Null

Write-Host "シンボリックリンクを作成しました。"
Read-Host -Prompt "Press Enter to exit"
