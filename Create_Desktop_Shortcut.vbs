Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

strScriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

strUserProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
If InStr(LCase(strUserProfile), ".antigravity-profile2") > 0 Then
    strUserProfile = fso.GetParentFolderName(strUserProfile)
ElseIf InStr(LCase(strUserProfile), "antigravity2") > 0 Then
    strUserProfile = fso.GetParentFolderName(strUserProfile)
End If

' 优先检查是否有 .antigravity-profile2 或 Antigravity2
strTargetProfile = strUserProfile & "\.antigravity-profile2"
If Not fso.FolderExists(strTargetProfile) Then
    strTargetProfile = strUserProfile & "\Antigravity2"
End If

' 优先使用静默无黑框启动器 (launch_silent.vbs)
strSilentLauncher = strTargetProfile & "\launch_silent.vbs"
If Not fso.FileExists(strSilentLauncher) Then
    strSilentLauncher = strScriptDir & "\launch_silent.vbs"
End If

strWorkingDir = strTargetProfile
If Not fso.FolderExists(strWorkingDir) Then
    strWorkingDir = strScriptDir
End If

strLocalAppData = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%")
strExePath = strLocalAppData & "\Programs\antigravity\Antigravity.exe"
If Not fso.FileExists(strExePath) Then
    strExePath = strUserProfile & "\AppData\Local\Programs\antigravity\Antigravity.exe"
End If
If Not fso.FileExists(strExePath) Then
    strExePath = "C:\Program Files\Antigravity\Antigravity.exe"
End If

Dim desktopPaths()
ReDim desktopPaths(0)
desktopPaths(0) = WshShell.SpecialFolders("Desktop")

If fso.FolderExists("D:\桌面") Then
    ReDim Preserve desktopPaths(1)
    desktopPaths(1) = "D:\桌面"
End If

Dim i, strDesktop, strShortcutPath, oShortcut
For i = 0 To UBound(desktopPaths)
    strDesktop = desktopPaths(i)
    If fso.FolderExists(strDesktop) Then
        strShortcutPath = strDesktop & "\Antigravity (账号2 - 独立隔离).lnk"
        Set oShortcut = WshShell.CreateShortcut(strShortcutPath)
        oShortcut.TargetPath = "wscript.exe"
        oShortcut.Arguments = "//nologo """ & strSilentLauncher & """"
        oShortcut.WorkingDirectory = strWorkingDir
        oShortcut.Description = "Antigravity 双开多实例 - 独立隔离环境 (账号2 - 静默秒开)"
        If fso.FileExists(strExePath) Then
            oShortcut.IconLocation = strExePath & ",0"
        End If
        oShortcut.Save
        WScript.Echo "[OK] 快捷方式已成功创建/更新: " & strShortcutPath
    End If
Next
