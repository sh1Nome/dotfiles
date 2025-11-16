# DotfilesManager module

class DotfileEntry {
    [string]$Name
    [string]$SrcRel
    [string]$DstRel

    DotfileEntry([string]$Name, [string]$SrcRel, [string]$DstRel) {
        $this.Name = $Name
        $this.SrcRel = $SrcRel
        $this.DstRel = $DstRel
    }
}

$script:LinuxManagedDotfileEntries = @(
    [DotfileEntry]::new(".bashrc", ".bashrc", ".bashrc"),
    [DotfileEntry]::new("mise", "dot_mise", ".config/mise"),
    [DotfileEntry]::new(".vimrc", ".vimrc", ".vimrc"),
    [DotfileEntry]::new("nvim", "nvim", ".config/nvim"),
    [DotfileEntry]::new(".gitconfig", ".gitconfig", ".gitconfig"),
    [DotfileEntry]::new(".gitconfig.local", ".gitconfig.local", ".gitconfig.local"),
    [DotfileEntry]::new("settings.json", "vscode/settings.json", ".config/Code/User/settings.json"),
    [DotfileEntry]::new("keybindings.json", "vscode/keybindings.json", ".config/Code/User/keybindings.json")
)

$script:WindowsManagedDotfileEntries = @(
    [DotfileEntry]::new(".bashrc", ".bashrc", ".bashrc"),
    [DotfileEntry]::new("mise", "dot_mise", ".config/mise"),
    [DotfileEntry]::new("Microsoft.PowerShell_profile.ps1", "Microsoft.PowerShell_profile.ps1", "Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"),
    [DotfileEntry]::new(".vimrc", ".vimrc", ".vimrc"),
    [DotfileEntry]::new("nvim", "nvim", "AppData/Local/nvim"),
    [DotfileEntry]::new(".gitconfig", ".gitconfig", ".gitconfig"),
    [DotfileEntry]::new(".gitconfig.local", ".gitconfig.local", ".gitconfig.local"),
    [DotfileEntry]::new("settings.json", "vscode/settings.json", "AppData/Roaming/Code/User/settings.json"),
    [DotfileEntry]::new("keybindings.json", "vscode/keybindings.json", "AppData/Roaming/Code/User/keybindings.json")
)

class DotfilesManager {
    [string]$DotfilesDir
    [string]$Home
    [DotfileEntry[]]$ManagedDotfileEntries
    [string]$OsType

    DotfilesManager([string]$scriptPath, [string]$osType) {
        # Get dotfiles directory from script location
        $this.DotfilesDir = Split-Path -Path (Split-Path -Path (Split-Path -Path $scriptPath)) -Parent

        # Get home directory
        $this.Home = $env:USERPROFILE
        if (-not $this.Home) {
            $this.Home = $env:HOME
        }

        # Set OS type (passed from function)
        $this.OsType = $osType

        # Set managed dotfile entries based on OS
        if ($this.OsType -eq "linux") {
            $this.ManagedDotfileEntries = $script:LinuxManagedDotfileEntries
        } else {
            $this.ManagedDotfileEntries = $script:WindowsManagedDotfileEntries
        }
    }

    [void] SetPowerShellExecutionPolicy() {
        if ($this.OsType -ne "windows") {
            return
        }

        try {
            powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
            Write-Host "PowerShellの実行ポリシーをRemoteSignedに設定しました"
        } catch {
            Write-Error "PowerShellの実行ポリシー設定に失敗: $_"
            throw $_
        }
    }

    [void] SetupGitConfigInteractive() {
        $gitUser = Read-Host "Gitのユーザー名を入力してください"
        $gitEmail = Read-Host "Gitのメールアドレスを入力してください"
        $credProvider = Read-Host "credential.providerをgenericに設定しますか？ [y/N]"

        $gitconfigLocalPath = Join-Path $this.DotfilesDir ".gitconfig.local"
        $gitconfigLocalContent = "[user]`n    name = $gitUser`n    email = $gitEmail`n"

        if ($credProvider -eq "y" -or $credProvider -eq "Y") {
            $gitconfigLocalContent += "[credential]`n    provider = generic`n"
        }

        try {
            Set-Content -Path $gitconfigLocalPath -Value $gitconfigLocalContent -Encoding UTF8
        } catch {
            Write-Error ".gitconfig.localの作成に失敗: $_"
            throw $_
        }
    }

    [void] RemoveGitConfigLocal() {
        $gitconfigLocalPath = Join-Path $this.DotfilesDir ".gitconfig.local"

        if (-not (Test-Path $gitconfigLocalPath)) {
            Write-Error ".gitconfig.localは存在しません"
            return
        }

        try {
            Remove-Item -Path $gitconfigLocalPath -Force
            Write-Host ".gitconfig.localを削除しました"
        } catch {
            Write-Error ".gitconfig.localの削除に失敗: $_"
            throw $_
        }
    }

    [void] RemoveVimDataDir() {
        if ($this.OsType -eq "windows") {
            $vimDir = Join-Path $this.Home "vimfiles"
            $nvimDataDir = Join-Path $this.Home "AppData" "Local" "nvim-data"
        } else {
            $vimDir = Join-Path $this.Home ".vim"
            $nvimDataDir = Join-Path $this.Home ".local" "share" "nvim"
        }

        # Remove vim directory
        if (-not (Test-Path $vimDir)) {
            Write-Host "$vimDir は存在しません。"
        } else {
            try {
                Remove-Item -Path $vimDir -Recurse -Force
                Write-Host "$vimDir を削除しました。"
            } catch {
                Write-Error "$vimDir の削除に失敗しました: $_"
                throw $_
            }
        }

        # Remove nvim data directory
        if (-not (Test-Path $nvimDataDir)) {
            Write-Host "$nvimDataDir は存在しません。"
        } else {
            try {
                Remove-Item -Path $nvimDataDir -Recurse -Force
                Write-Host "$nvimDataDir を削除しました。"
            } catch {
                Write-Error "$nvimDataDir の削除に失敗しました: $_"
                throw $_
            }
        }
    }

    [void] CreateDotfileLinks() {
        foreach ($entry in $this.ManagedDotfileEntries) {
            $src = Join-Path $this.DotfilesDir $entry.SrcRel
            $dst = Join-Path $this.Home $entry.DstRel

            # Remove existing symlink/directory
            if (Test-Path $dst) {
                try {
                    Remove-Item -Path $dst -Force -Recurse
                } catch {
                    Write-Error "既存のリンク削除失敗: $dst : $_"
                    continue
                }
            }

            # Create parent directory if needed
            $dstDir = Split-Path -Path $dst
            if (-not (Test-Path $dstDir)) {
                try {
                    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
                } catch {
                    Write-Error "ディレクトリ作成失敗: $dstDir : $_"
                    continue
                }
            }

            # Create symlink
            try {
                New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
            } catch {
                Write-Error "リンク作成失敗: $src -> $dst : $_"
            }
        }
    }

    [void] RemoveDotfileLinks() {
        foreach ($entry in $this.ManagedDotfileEntries) {
            $link = Join-Path $this.Home $entry.DstRel

            if (-not (Test-Path $link -PathType Leaf) -and -not (Test-Path $link -PathType Container)) {
                Write-Host "$link は存在しません。"
                continue
            }

            try {
                Remove-Item -Path $link -Recurse -Force
                Write-Host "$link を削除しました。"
            } catch {
                Write-Host "$link の削除に失敗しました: $_"
            }
        }
    }

    [void] ShowDotfilesLinks() {
        Write-Host "現在のdotfilesシンボリックリンク一覧:"

        $order = @()
        foreach ($entry in $this.ManagedDotfileEntries) {
            $order += $entry.Name
        }

        $found = @{}

        # Define skip directories for Windows
        $skipDirs = @{}
        if ($this.OsType -eq "windows") {
            $skipList = @(
                "AppData/LocalLow",
                "AppData/LineCall",
                "Pictures",
                "Videos",
                "Downloads",
                "Music",
                "3D Objects",
                "Saved Games",
                "Contacts",
                "Links",
                "Searches",
                "Favorites"
            )
            foreach ($d in $skipList) {
                $skipDirs[(Join-Path $this.Home $d)] = $true
            }
        }

        # Search for symlinks pointing to dotfiles
        $this.WalkDirectory($this.Home, $skipDirs, $found)

        # Display in order
        foreach ($k in $order) {
            if ($found.ContainsKey($k)) {
                Write-Host $found[$k]
                $found.Remove($k)
            }
        }

        # Display remaining links
        if ($found.Count -gt 0) {
            Write-Host "その他:"
            foreach ($v in $found.Values) {
                Write-Host $v
            }
        }
    }

    hidden [void] WalkDirectory([string]$path, [hashtable]$skipDirs, [hashtable]$found) {
        try {
            $items = Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue
        } catch {
            return
        }

        foreach ($item in $items) {
            try {
                # Skip directories for Windows performance
                if ($this.OsType -eq "windows" -and $item.PSIsContainer) {
                    if ($skipDirs.ContainsKey($item.FullName)) {
                        continue
                    }
                }

                # Check if it's a symlink pointing to dotfiles
                if ($item.LinkType -eq "SymbolicLink") {
                    $linkTarget = Get-Item -Path $item.FullName -Force | Select-Object -ExpandProperty Target
                    if ($linkTarget -like "*dotfiles*") {
                        $baseName = Split-Path -Path $item.FullName -Leaf
                        $found[$baseName] = "$($item.FullName) -> $(Split-Path -Path $linkTarget -Leaf)"
                    }
                } elseif ($item.PSIsContainer) {
                    # Recurse into subdirectories
                    $this.WalkDirectory($item.FullName, $skipDirs, $found)
                }
            } catch {
                # Silently continue on permission errors
            }
        }
    }
}

function Get-DotfilesManager {
    param(
        [string]$ScriptPath = $PSScriptRoot
    )
    
    # Determine OS type (outside of class)
    $osType = "windows"
    if ($PSVersionTable.Platform -eq "Unix") {
        $osType = "linux"
    } elseif ($PSVersionTable.OS -like "*Linux*") {
        $osType = "linux"
    } elseif ($env:OS -like "*Linux*") {
        $osType = "linux"
    }
    
    return [DotfilesManager]::new($ScriptPath, $osType)
}
