@if(0)==(0) echo off
chcp 65001
setlocal

set "old=%~2"
set "new=%~5"
set "target=%~1"
set "old=%old:\=/%"
set "new=%new:\=/%"

git --no-pager diff --no-index --no-ext-diff "%old%" "%new%" ^
 | cscript //nologo /u /E:JScript "%~f0" "%old%" "%target%" ^
 | cscript //nologo /u /E:JScript "%~f0" "%new%" "%target%" ^
 | delta --paging=never --width=%LAZYGIT_COLUMNS%

endlocal
goto :EOF
@end

var oldStr = WScript.Arguments(0);
var newStr = WScript.Arguments(1);

var stdin = WScript.StdIn;
var stdout = WScript.StdOut;

while (!stdin.AtEndOfStream) {
    var line = stdin.ReadLine();
    line = line.split(oldStr).join(newStr);
    stdout.WriteLine(line);
}
