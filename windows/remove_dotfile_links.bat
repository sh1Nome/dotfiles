@echo off
:: 管理者権限でなければ再実行
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ここから下は管理者権限で実行される
pushd %~dp0
powershell -ExecutionPolicy Bypass -File ps1\remove_dotfile_links.ps1
popd