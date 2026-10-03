Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
strDir = fso.GetParentFolderName(WScript.ScriptFullName)
strBat = strDir & "\run_account2.bat"
WshShell.Run "cmd.exe /c """ & strBat & """", 0, False
