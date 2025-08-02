@echo off
:: このバッチファイルは、管理者権限でPowerShellスクリプト（ps1\remove_dotfile_links.ps1）を実行し、ドットファイルのリンクを削除します。

:: 管理者権限でなければ再実行
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: 管理者権限で再実行するため、PowerShellで自身を管理者として起動します。
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ここから下は管理者権限で実行される
:: pushdは、現在のディレクトリを一時的に保存し、バッチファイルのある場所（%~dp0）に移動します。
pushd %~dp0
:: PowerShellスクリプトを実行して、ドットファイルのリンクを削除します。
powershell -ExecutionPolicy Bypass -File ps1\remove_dotfile_links.ps1
:: popdは、pushdで保存した元のディレクトリに戻ります。
popd