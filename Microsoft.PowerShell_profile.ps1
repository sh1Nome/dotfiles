# 履歴に重複するコマンドを記録しない
Set-PSReadLineOption -HistoryNoDuplicates
# 履歴ファイルに保存するコマンドの最大行数を設定
Set-PSReadLineOption -MaximumHistoryCount 2000
# 履歴をセッションごとに追記でファイルに保存する
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# 現在のGitブランチ名を取得する関数
function Get-GitBranchName {
    try {
        $originalEncoding = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $branch = git branch --show-current 2>$null
        [Console]::OutputEncoding = $originalEncoding
        if ($null -ne $branch -and $branch.Length -gt 0) {
            return "(git:$branch)"
        }
    }
    catch {
        # gitコマンドが存在しないか、ここがGitリポジトリでない場合のエラー処理
    }
    return ""
}

# 'prompt' 関数は PowerShell のプロンプト文字列を定義します。
function prompt {
    # ウィンドウタイトルをカレントディレクトリ名に
    $host.UI.RawUI.WindowTitle = Split-Path -Leaf (Get-Location).Path
    # ANSIエスケープコードを使用してプロンプトの色を設定
    $esc = [char]27
    return "${esc}[01;32m$env:USERNAME@$env:COMPUTERNAME${esc}[0m:${esc}[01;34m$((Get-Location).Path)${esc}[0m${esc}[33m$(Get-GitBranchName)${esc}[0m> "
}
