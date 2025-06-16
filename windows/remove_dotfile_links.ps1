# シンボリックリンクを削除するスクリプト（Windows用）

$links = @(
    "$HOME\.vimrc",
    "$HOME\.gitconfig",
    "$HOME\.gitconfig.local",
    "$HOME\AppData\Roaming\Code\User\settings.json",
    "$HOME\AppData\Roaming\Code\User\keybindings.json"
)

foreach ($link in $links) {
    if (Test-Path $link -PathType Leaf -PathType Container) {
        $item = Get-Item $link -Force
        if ($item.LinkType -eq 'SymbolicLink') {
            Remove-Item $link -Force
            Write-Host "$link を削除しました。"
        } else {
            Write-Host "$link はシンボリックリンクではないか、存在しません。"
        }
    } else {
        Write-Host "$link は存在しません。"
    }
}

Write-Host "シンボリックリンクの削除が完了しました。"
Read-Host -Prompt "Press Enter to exit"
