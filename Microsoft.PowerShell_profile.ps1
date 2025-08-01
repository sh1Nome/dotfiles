# 履歴に重複するコマンドを記録しない
Set-PSReadLineOption -HistoryNoDuplicates
# 履歴ファイルに保存するコマンドの最大行数を設定
Set-PSReadLineOption -MaximumHistoryCount 2000
# 履歴をセッションごとに追記でファイルに保存する
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# 現在のGitブランチ名を取得する関数
function Get-GitBranchName {
    try {
        # git branch --show-current を実行し、エラーは無視する
        $branch = git branch --show-current 2>$null
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
    # 色付けのためのANSIエスケープコード
    $esc = "$([char]27)"
    $reset = "$esc[0m"        # 全ての色をリセット
    $green = "$esc[01;32m"    # 明るい緑
    $blue = "$esc[01;34m"     # 明るい青
    $yellow = "$esc[33m"      # 黄色

    # プロンプトの構成要素
    $userName = $env:USERNAME
    $computerName = $env:COMPUTERNAME
    $location = (Get-Location).Path
    $gitBranch = Get-GitBranchName

    # プロンプト文字列を組み立てる
    $userAtHost = "$green$userName@$computerName$reset"
    $currentPath = "$blue$location$reset"
    $gitStatus = "$yellow$gitBranch$reset"
    
    # 注意: PowerShellのprompt関数は、最終的に1つの文字列を返す必要があります。
    # 末尾のスペースは、入力との間に隙間を作るために重要です。
    return "$userAtHost`:$currentPath$gitStatus`> "
}
