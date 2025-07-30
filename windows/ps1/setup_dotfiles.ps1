# このスクリプトは、Windows環境でdotfiles（設定ファイル群）のセットアップ（初期化）を行うものです。
# PowerShellの基本が分からなくても、何をしているか分かるように日本語で詳細なコメントを付けています。

# dotfilesディレクトリ（このスクリプトの2つ上の階層）のパスを取得します。
$DOTFILES_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Gitのユーザー名とメールアドレスを、画面から入力してもらいます。
$git_user = Read-Host "Gitのユーザー名を入力してください"
$git_email = Read-Host "Gitのメールアドレスを入力してください"

# 入力された情報を使って、.gitconfig.local というファイルを作成または上書きします。
# これはGitの個人設定ファイルです。
@"
[user]
    name = $git_user
    email = $git_email
"@ | Set-Content -Encoding UTF8 "$DOTFILES_DIR\.gitconfig.local"

# 各種設定ファイルのシンボリックリンク（ショートカットのようなもの）を作成します。
# 既に存在していても強制的に上書きします。
New-Item -ItemType SymbolicLink -Path "$HOME\.vimrc" -Target "$DOTFILES_DIR\.vimrc" -Force | Out-Null  # Vimの設定
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$DOTFILES_DIR\.gitconfig" -Force | Out-Null  # Gitの設定
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig.local" -Target "$DOTFILES_DIR\.gitconfig.local" -Force | Out-Null  # Gitの個人設定
New-Item -ItemType SymbolicLink -Path "$HOME\.bashrc" -Target "$DOTFILES_DIR\.bashrc" -Force | Out-Null  # bashrcの設定

# VSCodeのユーザー設定ディレクトリのパスを作成
$codeUserDir = "$HOME\AppData\Roaming\Code\User"
# ディレクトリがなければ新規作成します。
if (!(Test-Path $codeUserDir)) {
    New-Item -ItemType Directory -Path $codeUserDir | Out-Null
}
# VSCodeの設定ファイルのシンボリックリンクを作成します。
New-Item -ItemType SymbolicLink -Path "$codeUserDir\settings.json" -Target "$DOTFILES_DIR\vscode\settings.json" -Force | Out-Null  # VSCodeの設定
New-Item -ItemType SymbolicLink -Path "$codeUserDir\keybindings.json" -Target "$DOTFILES_DIR\vscode\keybindings.json" -Force | Out-Null  # VSCodeのキーバインド

# 全ての処理が終わったことをユーザーに伝えます。
Write-Host "シンボリックリンクを作成しました。"
# ユーザーがEnterキーを押すまで待機します。
Read-Host -Prompt "Press Enter to exit"
