@echo off
set HOME=%USERPROFILE%
C:/msys64/msys2_shell.cmd -defterm -where "%HOME%" -no-start -ucrt64 -full-path
