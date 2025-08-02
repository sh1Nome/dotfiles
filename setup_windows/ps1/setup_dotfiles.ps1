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

# PowerShellプロファイルのディレクトリパスを作成
$psProfileDir = Split-Path -Path $PROFILE -Parent
# ディレクトリがなければ新規作成します。
if (!(Test-Path $psProfileDir)) {
    New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null
}
# PowerShellプロファイルのシンボリックリンクを作成
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$DOTFILES_DIR\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
# このスクリプトを実行するには、PowerShellの実行ポリシーを RemoteSigned に設定する必要があります。
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

New-Item -ItemType SymbolicLink -Path "$HOME\.vimrc" -Target "$DOTFILES_DIR\.vimrc" -Force | Out-Null  # Vimの設定
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$DOTFILES_DIR\.gitconfig" -Force | Out-Null  # Gitの設定
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig.local" -Target "$DOTFILES_DIR\.gitconfig.local" -Force | Out-Null  # Gitの個人設定

# VSCodeのユーザー設定ディレクトリのパスを作成
$codeUserDir = "$env:APPDATA\Code\User"
# ディレクトリがなければ新規作成します。
if (!(Test-Path $codeUserDir)) {
    New-Item -ItemType Directory -Path $codeUserDir | Out-Null
}
# VSCodeの設定ファイルのシンボリックリンクを作成します。
New-Item -ItemType SymbolicLink -Path "$codeUserDir\settings.json" -Target "$DOTFILES_DIR\vscode\settings.json" -Force | Out-Null  # VSCodeの設定
New-Item -ItemType SymbolicLink -Path "$codeUserDir\keybindings.json" -Target "$DOTFILES_DIR\vscode\keybindings.json" -Force | Out-Null  # VSCodeのキーバインド
New-Item -ItemType SymbolicLink -Path "$codeUserDir\prompts" -Target "$DOTFILES_DIR\vscode\prompts" -Force | Out-Null  # VSCodeのプロンプトディレクトリ

# Alacrittyのユーザー設定ディレクトリのパスを作成
$alacrittyDir = "$env:APPDATA\alacritty"
# ディレクトリがなければ新規作成します。
if (!(Test-Path $alacrittyDir)) {
    New-Item -ItemType Directory -Path $alacrittyDir | Out-Null
}
# Alacrittyの設定ファイルのシンボリックリンクを作成
New-Item -ItemType SymbolicLink -Path "$alacrittyDir\alacritty.toml" -Target "$DOTFILES_DIR\alacritty.toml" -Force | Out-Null  # Alacrittyの設定

# 全ての処理が終わったことをユーザーに伝えます。
Write-Host "シンボリックリンクを作成しました。"
# dotfilesのシンボリックリンク一覧を表示

# シンボリックリンク検索対象ディレクトリを配列で管理
$symlinkDirs = @(
    $HOME,
    "$env:APPDATA\Code\User",
    "$env:APPDATA\alacritty",
    $PROFILE
)
Write-Host "`n現在のdotfilesシンボリックリンク一覧:"
# 管理しているツール順のパターンリスト
$toolOrder = @(
    @{ Name = "Bash"; Pattern = ".bashrc" },
    @{ Name = "Powershell"; Pattern = "Microsoft.PowerShell_profile.ps1" },
    @{ Name = "Vim"; Pattern = ".vimrc" },
    @{ Name = "Git"; Pattern = ".gitconfig" },
    @{ Name = "Git"; Pattern = ".gitconfig.local" },
    @{ Name = "VSCode"; Pattern = "settings.json" },
    @{ Name = "VSCode"; Pattern = "keybindings.json" },
    @{ Name = "VSCode"; Pattern = "prompts" },
    @{ Name = "Alacritty"; Pattern = "alacritty.toml" }
)

# シンボリックリンク一覧取得
$symlinks = Get-ChildItem -Path $symlinkDirs -Force |
    Where-Object { $_.LinkType -eq 'SymbolicLink' -and $_.Target -match 'dotfiles' }

# ツール順でソートして表示
foreach ($tool in $toolOrder) {
    $pattern = $tool.Pattern
    $links = $symlinks | Where-Object { $_.Name -eq $pattern }
    foreach ($link in $links) {
        Write-Host "$($link.Name) -> $($link.Target)"
    }
}
# ユーザーがEnterキーを押すまで待機します。
Read-Host -Prompt "Press Enter to exit"
