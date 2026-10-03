Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

strDir = fso.GetParentFolderName(WScript.ScriptFullName)
strWorkerVbs = strDir & "\worker_silent.vbs"
strWorkerBat = strDir & "\run_account2.bat"

q = Chr(34)

If fso.FileExists(strWorkerVbs) Then
    strCmd = "runas /profile /savecred /user:Antigravity2 " & q & "wscript.exe //nologo \" & q & strWorkerVbs & "\" & q & q
Else
    strCmd = "runas /profile /savecred /user:Antigravity2 " & q & "cmd.exe /c \" & q & strWorkerBat & "\" & q & q
End If

WshShell.Run strCmd, 0, False
