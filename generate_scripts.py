# -*- coding: utf-8 -*-
"""
Antigravity Windows 多开物理隔离脚手架构建脚本
自动以 GBK / CRLF 规范生成无硬编码、零卡顿、无黑窗口、支持带空格路径与 Google OAuth 弹窗的极速启动套件
"""
import os

setup_dual_user_bat = """@echo off
title Antigravity 双开隔离环境一键配置
setlocal enabledelayedexpansion

REM ==================================================
REM 1. 动态获取宿主主用户的真实路径 (兼容提权与多用户上下文)
REM ==================================================
if not "%~1"=="" (
    set "HOST_PROFILE=%~1"
) else (
    set "HOST_PROFILE=%USERPROFILE%"
)

if "%HOST_PROFILE:~-1%"=="\\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"

for %%I in ("%HOST_PROFILE%") do (
    if /i "%%~nxI"==".antigravity-profile2" set "HOST_PROFILE=%%~dpI"
    if /i "%%~nxI"=="Antigravity2" set "HOST_PROFILE=%%~dpI"
)
if "%HOST_PROFILE:~-1%"=="\\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"

REM ==================================================
REM 2. 管理员权限检查与自动提权
REM ==================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ======================================================
    echo [提示] 配置隔离环境需要管理员权限。
    echo 正在请求管理员权限 (UAC 弹窗)...
    echo 若未弹出，请右键点击本脚本选择【以管理员身份运行】。
    echo ======================================================
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/k \\"\\"%~f0\\"\\" \\"\\"%HOST_PROFILE%\\"\\"' -Verb RunAs" 2>nul
    pause
    exit /b
)

cd /d "%~dp0"

echo ======================================================
echo    Antigravity Windows 多实例物理隔离环境初始化
echo ======================================================
echo.

REM ==================================================
REM 3. 基础参数与目录配置 (智能兼容现有 .antigravity-profile2 与 Antigravity2)
REM ==================================================
set "TARGET_USER=Antigravity2"
set "TARGET_PASS=Anti@2026!Pass"

set "TARGET_PROFILE=%HOST_PROFILE%\\.antigravity-profile2"
if not exist "%TARGET_PROFILE%" (
    if exist "%HOST_PROFILE%\\Antigravity2" set "TARGET_PROFILE=%HOST_PROFILE%\\Antigravity2"
)

set "APP_DIR=%HOST_PROFILE%\\AppData\\Local\\Programs\\antigravity"

echo [*] 当前宿主用户主目录: %HOST_PROFILE%
echo [*] 隔离数据收纳目录:   %TARGET_PROFILE%
echo.

REM ==================================================
REM 4. 检查并确保 Secondary Logon 服务已开启
REM ==================================================
echo [步骤 1/7] 检查系统 Secondary Logon 服务...
sc config seclogon start= demand >nul 2>&1
net start seclogon >nul 2>&1
echo [OK] Secondary Logon 服务已就绪。
echo.

REM ==================================================
REM 5. 检测或创建隔离用户
REM ==================================================
echo [步骤 2/7] 检查本地用户 [%TARGET_USER%]...
net user "%TARGET_USER%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 本地用户 [%TARGET_USER%] 已存在，正在更新密码...
    net user "%TARGET_USER%" "%TARGET_PASS%" >nul 2>&1
) else (
    echo 正在创建本地标准用户 [%TARGET_USER%]...
    net user "%TARGET_USER%" "%TARGET_PASS%" /add /comment:"Antigravity Dual Instance Isolated User"
    if %errorlevel% neq 0 (
        echo [错误] 创建用户失败，请检查系统安全策略。
        pause
        exit /b 1
    )
    echo [OK] 本地用户 [%TARGET_USER%] 创建成功。
)

powershell -NoProfile -Command "Set-LocalUser -Name '%TARGET_USER%' -PasswordNeverExpires $true" >nul 2>&1
echo [OK] 用户密码已设置为永不过期。
echo.

REM ==================================================
REM 6. 配置文件存放目录与初始赋权 (仅需在初始化时执行一次)
REM ==================================================
echo [步骤 3/7] 配置文件存放目录: %TARGET_PROFILE%...
if not exist "%TARGET_PROFILE%" mkdir "%TARGET_PROFILE%" >nul 2>&1
if not exist "%TARGET_PROFILE%\\AppData\\Roaming" mkdir "%TARGET_PROFILE%\\AppData\\Roaming" >nul 2>&1
if not exist "%TARGET_PROFILE%\\AppData\\Local" mkdir "%TARGET_PROFILE%\\AppData\\Local" >nul 2>&1

icacls "%TARGET_PROFILE%" /grant "%TARGET_USER%:(OI)(CI)F" /T /C /Q >nul 2>&1
echo [OK] 独立存储目录完全控制权限已赋予给 %TARGET_USER%。
echo.

REM ==================================================
REM 7. 配置父目录遍历权限 (解决 Node.js realpathSync EPERM 崩溃)
REM ==================================================
echo [步骤 4/7] 配置父目录遍历权限 (防止 Node 模块加载权限不足崩溃)...
icacls "%HOST_PROFILE%" /grant "%TARGET_USER%:(RX)" >nul 2>&1
icacls "%HOST_PROFILE%\\AppData" /grant "%TARGET_USER%:(RX)" >nul 2>&1
icacls "%HOST_PROFILE%\\AppData\\Local" /grant "%TARGET_USER%:(RX)" >nul 2>&1
icacls "%HOST_PROFILE%\\AppData\\Local\\Programs" /grant "%TARGET_USER%:(RX)" >nul 2>&1
if exist "%APP_DIR%" (
    icacls "%APP_DIR%" /grant "%TARGET_USER%:(OI)(CI)RX" /T /C /Q >nul 2>&1
    echo [OK] 已授权访问主程序: %APP_DIR%
)
icacls "%~dp0" /grant "%TARGET_USER%:(OI)(CI)M" /T /C /Q >nul 2>&1
echo.

REM ==================================================
REM 8. 部署静默极速启动套件到常驻目录
REM ==================================================
echo [步骤 5/7] 部署极速启动器到永久用户目录...
copy /y "%~dp0internal_worker.bat" "%TARGET_PROFILE%\\run_account2.bat" >nul 2>&1
copy /y "%~dp02_Launch_Account2.bat" "%TARGET_PROFILE%\\Launch_Account2.bat" >nul 2>&1
copy /y "%~dp0launch_silent.vbs" "%TARGET_PROFILE%\\launch_silent.vbs" >nul 2>&1
copy /y "%~dp0worker_silent.vbs" "%TARGET_PROFILE%\\worker_silent.vbs" >nul 2>&1
icacls "%TARGET_PROFILE%\\run_account2.bat" /grant "%TARGET_USER%:(OI)(CI)F" >nul 2>&1
icacls "%TARGET_PROFILE%\\worker_silent.vbs" /grant "%TARGET_USER%:(OI)(CI)F" >nul 2>&1
echo [OK] 启动套件已部署到: %TARGET_PROFILE%
echo.

REM ==================================================
REM 9. 修改注册表 ProfileImagePath 指向独立数据目录
REM ==================================================
echo [步骤 6/7] 配置 Windows 用户配置文件路径指向 %TARGET_PROFILE%...
set "USER_SID="
for /f "delims=" %%I in ('powershell -NoProfile -Command "([System.Security.Principal.NTAccount]'%TARGET_USER%').Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%I"
if defined USER_SID (
    reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList\\%USER_SID%" /v ProfileImagePath /t REG_EXPAND_SZ /d "%TARGET_PROFILE%" /f >nul 2>&1
    echo [OK] 注册表 ProfileImagePath (SID: %USER_SID%) 已重定向到: %TARGET_PROFILE%
) else (
    echo [!] 未能动态获取 SID，尝试搜索现有注册表项...
    for /f "tokens=*" %%A in ('reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList" /s /f "%TARGET_USER%" ^| findstr /i "HKEY_LOCAL_MACHINE"') do (
        reg add "%%A" /v ProfileImagePath /t REG_EXPAND_SZ /d "%TARGET_PROFILE%" /f >nul 2>&1
    )
)

if exist "C:\\Users\\%TARGET_USER%" (
    if /i not "C:\\Users\\%TARGET_USER%"=="%TARGET_PROFILE%" (
        echo 正在清理 C:\\Users\\%TARGET_USER% 根目录残留...
        rd /s /q "C:\\Users\\%TARGET_USER%" >nul 2>&1
    )
)
echo.

REM ==================================================
REM 10. 生成纯净静默桌面快捷方式 (无黑窗口、零卡顿)
REM ==================================================
echo [步骤 7/7] 生成专属桌面快捷方式...
if exist "%~dp0Create_Desktop_Shortcut.vbs" (
    cscript //nologo "%~dp0Create_Desktop_Shortcut.vbs"
    echo [OK] 桌面快捷方式已生成。
)

echo.
echo ======================================================
echo              配置已顺利完成！
echo ======================================================
echo 隔离用户: %TARGET_USER% (默认密码: %TARGET_PASS%)
echo 存储路径: %TARGET_PROFILE%
echo.
echo 启动方式:
echo    直接双击桌面上的【Antigravity (账号2 - 独立隔离)】
echo    或双击本目录下的【2_Launch_Account2.bat】
echo    (首次启动若弹窗提示输入密码，盲打输入一次 Anti@2026!Pass 即可永久免密秒开)
echo    (已开启 100%% 静默无黑框引擎，0 卡顿，秒开启动！)
echo ======================================================
echo.
pause
exit /b 0
"""

internal_worker_bat = """@echo off
setlocal enabledelayedexpansion

REM ==================================================
REM 1. 动态定位独立存储目录与宿主用户目录
REM ==================================================
set "PROFILE_DIR=%~dp0"
if "%PROFILE_DIR:~-1%"=="\\" set "PROFILE_DIR=%PROFILE_DIR:~0,-1%"

for %%I in ("%PROFILE_DIR%\\..") do set "HOST_PROFILE=%%~fI"

if not exist "%PROFILE_DIR%\\AppData\\Roaming" mkdir "%PROFILE_DIR%\\AppData\\Roaming" >nul 2>&1
if not exist "%PROFILE_DIR%\\AppData\\Local" mkdir "%PROFILE_DIR%\\AppData\\Local" >nul 2>&1

set "USERPROFILE=%PROFILE_DIR%"
set "APPDATA=%PROFILE_DIR%\\AppData\\Roaming"
set "LOCALAPPDATA=%PROFILE_DIR%\\AppData\\Local"
set "HOME=%PROFILE_DIR%"
set "HOMEDRIVE=C:"
for %%I in ("%PROFILE_DIR%") do set "HOMEPATH=%%~pI%%~nxI"

REM 激活 Electron 主进程独立实例直连浏览器引擎 (彻底解决 Google OAuth 登录弹窗)
set "ANTIGRAVITY_SECONDARY_INSTANCE=1"
REM 确保不抑制 Language Server 启动外部浏览器
set "ANTIGRAVITY_VSCODE_HOST=1"

REM ==================================================
REM 2. 科学上网代理配置 (请按需修改；若不需要代理，请设 ENABLE_PROXY=0)
REM ==================================================
set "ENABLE_PROXY=1"
set "PROXY_HOST=127.0.0.1"
set "PROXY_PORT=7890"

if "%ENABLE_PROXY%"=="1" (
    set "HTTP_PROXY=http://%PROXY_HOST%:%PROXY_PORT%"
    set "HTTPS_PROXY=http://%PROXY_HOST%:%PROXY_PORT%"
    set "ALL_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%"
    set "NO_PROXY=localhost,127.0.0.1,::1"
)

REM ==================================================
REM 3. 自动为隔离用户注册默认浏览器协议 (清理 DelegateExecute 避免 COM 阻塞)
REM ==================================================
set "SYS_BROWSER="
if exist "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" (
    set "SYS_BROWSER=C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
) else if exist "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe" (
    set "SYS_BROWSER=C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
) else if exist "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe" (
    set "SYS_BROWSER=C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe"
)

if defined SYS_BROWSER (
    reg add "HKCU\\Software\\Classes\\http" /ve /t REG_SZ /d "URL:HyperText Transfer Protocol" /f >nul 2>&1
    reg add "HKCU\\Software\\Classes\\http" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCU\\Software\\Classes\\http\\shell\\open\\command" /ve /t REG_SZ /d "\\"!SYS_BROWSER!\\" --single-argument \\"%%%%1\\"" /f >nul 2>&1
    reg delete "HKCU\\Software\\Classes\\http\\shell\\open\\command" /v "DelegateExecute" /f >nul 2>&1

    reg add "HKCU\\Software\\Classes\\https" /ve /t REG_SZ /d "URL:HyperText Transfer Protocol with Privacy" /f >nul 2>&1
    reg add "HKCU\\Software\\Classes\\https" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCU\\Software\\Classes\\https\\shell\\open\\command" /ve /t REG_SZ /d "\\"!SYS_BROWSER!\\" --single-argument \\"%%%%1\\"" /f >nul 2>&1
    reg delete "HKCU\\Software\\Classes\\https\\shell\\open\\command" /v "DelegateExecute" /f >nul 2>&1
)

REM ==================================================
REM 4. 动态定位 Antigravity 主程序
REM ==================================================
set "ANTIGRAVITY_EXE="
if exist "%HOST_PROFILE%\\AppData\\Local\\Programs\\antigravity\\Antigravity.exe" (
    set "ANTIGRAVITY_EXE=%HOST_PROFILE%\\AppData\\Local\\Programs\\antigravity\\Antigravity.exe"
) else if exist "%LOCALAPPDATA%\\Programs\\antigravity\\Antigravity.exe" (
    set "ANTIGRAVITY_EXE=%LOCALAPPDATA%\\Programs\\antigravity\\Antigravity.exe"
) else if exist "%ProgramFiles%\\Antigravity\\Antigravity.exe" (
    set "ANTIGRAVITY_EXE=%ProgramFiles%\\Antigravity\\Antigravity.exe"
)

if not defined ANTIGRAVITY_EXE exit /b 1

for %%I in ("%ANTIGRAVITY_EXE%") do set "ANTIGRAVITY_DIR=%%~dpI"
cd /d "%ANTIGRAVITY_DIR%"

REM 极速拉起，立即退出 (无延迟、不残留 CMD 控制台)
start "" "%ANTIGRAVITY_EXE%" --user-data-dir="%APPDATA%\\Antigravity" %*
exit 0
"""

launch_account2_bat = """@echo off
title 启动 Antigravity 账号2 (独立隔离)
setlocal enabledelayedexpansion

cd /d "%~dp0"

REM ==================================================
REM 1. 动态推导宿主主用户的真实主目录
REM ==================================================
set "HOST_PROFILE=%USERPROFILE%"
if "%HOST_PROFILE:~-1%"=="\\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"
for %%I in ("%HOST_PROFILE%") do (
    if /i "%%~nxI"==".antigravity-profile2" set "HOST_PROFILE=%%~dpI"
    if /i "%%~nxI"=="Antigravity2" set "HOST_PROFILE=%%~dpI"
)
if "%HOST_PROFILE:~-1%"=="\\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"

REM ==================================================
REM 2. 检查隔离运行环境目录 (优先级: .antigravity-profile2 > Antigravity2)
REM ==================================================
set "TARGET_PROFILE=%HOST_PROFILE%\\.antigravity-profile2"
if not exist "%TARGET_PROFILE%" set "TARGET_PROFILE=%HOST_PROFILE%\\Antigravity2"

if not exist "%TARGET_PROFILE%\\launch_silent.vbs" (
    if not exist "%TARGET_PROFILE%\\run_account2.bat" (
        echo ======================================================
        echo [提示] 检测到隔离环境尚未初始化！
        echo 请先双击运行 [1_Setup_DualUser.bat] 完成一键配置。
        echo ======================================================
        pause
        exit /b 1
    )
)

REM 自动同步本工程最新脚本到运行时环境 (确保配置更新实时生效)
if exist "%~dp0internal_worker.bat" copy /y "%~dp0internal_worker.bat" "%TARGET_PROFILE%\\run_account2.bat" >nul 2>&1
if exist "%~dp0launch_silent.vbs" copy /y "%~dp0launch_silent.vbs" "%TARGET_PROFILE%\\launch_silent.vbs" >nul 2>&1
if exist "%~dp0worker_silent.vbs" copy /y "%~dp0worker_silent.vbs" "%TARGET_PROFILE%\\worker_silent.vbs" >nul 2>&1

REM ==================================================
REM 3. 静默秒开启动 (彻底消除黑窗口、无路径空格解析 Bug、秒开运行)
REM ==================================================
if exist "%TARGET_PROFILE%\\launch_silent.vbs" (
    wscript.exe //nologo "%TARGET_PROFILE%\\launch_silent.vbs"
    exit /b 0
)

REM 兜底直接使用 runas (转义嵌套引号，防止因路径含空格报错闪退)
set "TARGET_USER=Antigravity2"
set "SAFE_WORKER=%TARGET_PROFILE%\\run_account2.bat"
runas /profile /savecred /user:%TARGET_USER% "cmd.exe /c \\"\\"%SAFE_WORKER%\\"\\""
exit /b 0
"""

worker_silent_vbs = '''Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
strDir = fso.GetParentFolderName(WScript.ScriptFullName)
strBat = strDir & "\\run_account2.bat"
WshShell.Run "cmd.exe /c """ & strBat & """", 0, False
'''

launch_silent_vbs = '''Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

strDir = fso.GetParentFolderName(WScript.ScriptFullName)
strWorkerVbs = strDir & "\\worker_silent.vbs"
strWorkerBat = strDir & "\\run_account2.bat"

q = Chr(34)

If fso.FileExists(strWorkerVbs) Then
    strCmd = "runas /profile /savecred /user:Antigravity2 " & q & "wscript.exe //nologo \\" & q & strWorkerVbs & "\\" & q & q
Else
    strCmd = "runas /profile /savecred /user:Antigravity2 " & q & "cmd.exe /c \\" & q & strWorkerBat & "\\" & q & q
End If

WshShell.Run strCmd, 0, False
'''

reset_cred_bat = """@echo off
title 重置 Antigravity2 凭据

echo ======================================================
echo         重置 Antigravity2 存储的 Windows 凭据
echo ======================================================
echo.
set "TARGET_USER=Antigravity2"
echo 正在清除保存的凭据缓存...
cmdkey /delete:Domain:interactive=%COMPUTERNAME%\\%TARGET_USER% >nul 2>&1
cmdkey /delete:Domain:interactive=%TARGET_USER% >nul 2>&1
cmdkey /delete:%TARGET_USER% >nul 2>&1
echo.
echo [OK] 凭据已清除完毕！
echo 下次启动时将重新提示输入密码：Anti@2026!Pass
echo.
pause
exit /b 0
"""

create_shortcut_vbs = '''Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

strScriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

strUserProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
If InStr(LCase(strUserProfile), ".antigravity-profile2") > 0 Then
    strUserProfile = fso.GetParentFolderName(strUserProfile)
ElseIf InStr(LCase(strUserProfile), "antigravity2") > 0 Then
    strUserProfile = fso.GetParentFolderName(strUserProfile)
End If

' 优先检查是否有 .antigravity-profile2 或 Antigravity2
strTargetProfile = strUserProfile & "\\.antigravity-profile2"
If Not fso.FolderExists(strTargetProfile) Then
    strTargetProfile = strUserProfile & "\\Antigravity2"
End If

' 优先使用静默无黑框启动器 (launch_silent.vbs)
strSilentLauncher = strTargetProfile & "\\launch_silent.vbs"
If Not fso.FileExists(strSilentLauncher) Then
    strSilentLauncher = strScriptDir & "\\launch_silent.vbs"
End If

strWorkingDir = strTargetProfile
If Not fso.FolderExists(strWorkingDir) Then
    strWorkingDir = strScriptDir
End If

strLocalAppData = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%")
strExePath = strLocalAppData & "\\Programs\\antigravity\\Antigravity.exe"
If Not fso.FileExists(strExePath) Then
    strExePath = strUserProfile & "\\AppData\\Local\\Programs\\antigravity\\Antigravity.exe"
End If
If Not fso.FileExists(strExePath) Then
    strExePath = "C:\\Program Files\\Antigravity\\Antigravity.exe"
End If

Dim desktopPaths()
ReDim desktopPaths(0)
desktopPaths(0) = WshShell.SpecialFolders("Desktop")

If fso.FolderExists("D:\\桌面") Then
    ReDim Preserve desktopPaths(1)
    desktopPaths(1) = "D:\\桌面"
End If

Dim i, strDesktop, strShortcutPath, oShortcut
For i = 0 To UBound(desktopPaths)
    strDesktop = desktopPaths(i)
    If fso.FolderExists(strDesktop) Then
        strShortcutPath = strDesktop & "\\Antigravity (账号2 - 独立隔离).lnk"
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
'''

fix_shortcut_bat = """@echo off
title 修复或创建桌面快捷方式
cd /d "%~dp0"

echo ======================================================
echo          Antigravity 桌面快捷方式一键修复/校准
echo ======================================================
echo.
echo 正在检测并创建专属桌面快捷方式 (静默秒开模式)...
echo.

if exist "%~dp0Create_Desktop_Shortcut.vbs" (
    cscript //nologo "%~dp0Create_Desktop_Shortcut.vbs"
    echo.
    echo ======================================================
    echo [OK] 快捷方式已成功刷新校准！
    echo 无论您将本工程文件夹移动到何处，均可通过双击本脚本一键恢复。
    echo ======================================================
) else (
    echo [错误] 未找到 Create_Desktop_Shortcut.vbs 脚本！
)

echo.
pause
exit /b 0
"""

files = {
    "1_Setup_DualUser.bat": setup_dual_user_bat,
    "internal_worker.bat": internal_worker_bat,
    "2_Launch_Account2.bat": launch_account2_bat,
    "worker_silent.vbs": worker_silent_vbs,
    "launch_silent.vbs": launch_silent_vbs,
    "重置凭据.bat": reset_cred_bat,
    "Create_Desktop_Shortcut.vbs": create_shortcut_vbs,
    "修复或创建桌面快捷方式.bat": fix_shortcut_bat
}

def main():
    print("=" * 60)
    print(" 正在生成可移植、零卡顿、无黑窗口的 Antigravity 双开脚本套件 ")
    print("=" * 60)
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    for fname, fc in files.items():
        fpath = os.path.join(script_dir, fname)
        normalized = fc.replace("\r\n", "\n").replace("\n", "\r\n")
        with open(fpath, "w", encoding="gbk", errors="replace") as f:
            f.write(normalized)
        print(f"[OK] 已生成: {fname} (GBK, CRLF)")

    # 动态推导并同步到常驻目录
    user_profile = os.environ.get("USERPROFILE", "")
    if ".antigravity-profile2" in user_profile or "Antigravity2" in user_profile:
        user_profile = os.path.dirname(user_profile)
    if not user_profile:
        user_profile = r"C:\Users\86176"

    for cand_name in [".antigravity-profile2", "Antigravity2"]:
        tp = os.path.join(user_profile, cand_name)
        if os.path.exists(tp):
            with open(os.path.join(tp, "run_account2.bat"), "w", encoding="gbk", errors="replace") as f:
                f.write(internal_worker_bat.replace("\r\n", "\n").replace("\n", "\r\n"))
            with open(os.path.join(tp, "Launch_Account2.bat"), "w", encoding="gbk", errors="replace") as f:
                f.write(launch_account2_bat.replace("\r\n", "\n").replace("\n", "\r\n"))
            with open(os.path.join(tp, "worker_silent.vbs"), "w", encoding="gbk", errors="replace") as f:
                f.write(worker_silent_vbs.replace("\r\n", "\n").replace("\n", "\r\n"))
            with open(os.path.join(tp, "launch_silent.vbs"), "w", encoding="gbk", errors="replace") as f:
                f.write(launch_silent_vbs.replace("\r\n", "\n").replace("\n", "\r\n"))
            print(f"[OK] 运行时脚本已同步至常驻目录: {tp}")

    print("\n所有文件同步完成！已开启 100% 静默无黑框秒开引擎！")

if __name__ == "__main__":
    main()
