Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

strDir = fso.GetParentFolderName(WScript.ScriptFullName)
strWorkerBat = strDir & "\run_account2.bat"
q = Chr(34)

' 测试凭据是否已成功保存 (执行简单的 exit 0 测试)
intRet = WshShell.Run("cmd.exe /c runas /savecred /user:Antigravity2 ""cmd.exe /c exit 0""", 0, True)

If intRet = 0 Then
    ' 凭据有效：全静默拉起，无任何窗口闪烁、秒开运行
    strCmd = "runas /profile /savecred /user:Antigravity2 " & q & "cmd.exe /c " & q & q & strWorkerBat & q & q & q
    WshShell.Run strCmd, 0, False
Else
    ' 凭据需要初始化：打开前台可见窗口引导用户盲打一次密码 Anti@2026!Pass
    strInitCmd = "cmd.exe /k ""title Antigravity 账号2 凭据初始化 & mode con: cols=65 lines=14 & color 0B & " & _
        "echo ========================================================= & " & _
        "echo      Antigravity 账号2 凭据初始化向导 (仅首次需要) & " & _
        "echo ========================================================= & " & _
        "echo. & " & _
        "echo 检测到尚未保存隔离账户 Antigravity2 的登录凭据。 & " & _
        "echo 请在下方提示处输入默认密码并回车: & " & _
        "echo [ 默认密码 ]: Anti@2026!Pass & " & _
        "echo (注: Windows 密码输入时不会显示任何字符，直接输入回车即可) & " & _
        "echo ========================================================= & " & _
        "echo. & " & _
        "runas /profile /savecred /user:Antigravity2 " & q & "cmd.exe /c " & q & q & strWorkerBat & q & q & q & " & exit"""
    WshShell.Run strInitCmd, 1, False
End If
