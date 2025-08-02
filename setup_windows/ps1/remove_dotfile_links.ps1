# このスクリプトは、Windows環境でdotfilesのシンボリックリンク（ショートカットのようなもの）を削除するためのものです。
# PowerShellの基本的な文法やコマンドの使い方が分からなくても、コメントを読めば何をしているか理解できるように説明しています。
 
# 削除したいシンボリックリンクのパスをリスト（配列）として定義します。
# $HOMEはユーザーのホームディレクトリを表します。
$links = @(
    "$PROFILE", # PowerShellプロファイルへのリンク
    "$HOME\.vimrc",  # Vimの設定ファイルへのリンク
    "$HOME\.gitconfig",  # Gitの設定ファイルへのリンク
    "$HOME\.gitconfig.local",  # Gitの個人設定ファイルへのリンク
    "$env:APPDATA\Code\User\settings.json",  # VSCodeの設定ファイルへのリンク
    "$env:APPDATA\Code\User\keybindings.json",  # VSCodeのキーバインド設定ファイルへのリンク
    "$env:APPDATA\Code\User\prompts"  # VSCodeのプロンプト設定ディレクトリへのリンク
)
 
# $linksに入っている各パスについて、順番に処理します。
foreach ($link in $links) {
    if (Test-Path $link) {
        # ファイルやディレクトリの情報を取得します。
        $item = Get-Item $link -Force
        # シンボリックリンクまたはディレクトリの場合は削除
        if ($item.LinkType -eq 'SymbolicLink' -or $item.PSIsContainer) {
            Remove-Item $link -Force -Recurse
            Write-Host "$link を削除しました。"
        } else {
            Write-Host "$link はシンボリックリンクでもディレクトリでもありません。"
        }
    } else {
        # ファイルやディレクトリが存在しない場合のメッセージを表示します。
        Write-Host "$link は存在しません。"
    }
}
 
# 全ての処理が完了したことをユーザーに伝えます。
Write-Host "シンボリックリンクの削除が完了しました。"
# ユーザーがEnterキーを押すまで待機します。
Read-Host -Prompt "Press Enter to exit"
