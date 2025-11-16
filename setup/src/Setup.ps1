#Requires -Version 5.0

# Import DotfilesManager
. (Join-Path $PSScriptRoot "DotfilesManager.ps1")

$manager = Get-DotfilesManager -ScriptPath $PSScriptRoot

# Set PowerShell execution policy on Windows
$manager.SetPowerShellExecutionPolicy()

# Setup Git config interactively
$manager.SetupGitConfigInteractive()

# Create symbolic links for managed dotfiles
$manager.CreateDotfileLinks()

# Display symlinks
Write-Host "シンボリックリンクを作成しました。"
$manager.ShowDotfilesLinks()

# Wait for user input before exit
Write-Host "Enterを押して終了します..."
$null = Read-Host