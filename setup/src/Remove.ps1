#Requires -Version 5.0

# Import DotfilesManager
. (Join-Path $PSScriptRoot "DotfilesManager.ps1")

$manager = Get-DotfilesManager -ScriptPath $PSScriptRoot

# Remove symbolic links for managed dotfiles
$manager.RemoveDotfileLinks()

# Remove .gitconfig.local
$manager.RemoveGitConfigLocal()

# Remove vim data directories
$manager.RemoveVimDataDir()

# Display symlinks
Write-Host "シンボリックリンクを削除しました。"
$manager.ShowDotfilesLinks()

# Wait for user input before exit
Write-Host "Enterを押して終了します..."
$null = Read-Host