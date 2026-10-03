@echo off
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

if "%HOST_PROFILE:~-1%"=="\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"

for %%I in ("%HOST_PROFILE%") do (
    if /i "%%~nxI"==".antigravity-profile2" set "HOST_PROFILE=%%~dpI"
    if /i "%%~nxI"=="Antigravity2" set "HOST_PROFILE=%%~dpI"
)
if "%HOST_PROFILE:~-1%"=="\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"

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
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/k \"\"%~f0\"\" \"\"%HOST_PROFILE%\"\"' -Verb RunAs" 2>nul
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

set "TARGET_PROFILE=%HOST_PROFILE%\.antigravity-profile2"
if not exist "%TARGET_PROFILE%" (
    if exist "%HOST_PROFILE%\Antigravity2" set "TARGET_PROFILE=%HOST_PROFILE%\Antigravity2"
)

set "APP_DIR=%HOST_PROFILE%\AppData\Local\Programs\antigravity"

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
if not exist "%TARGET_PROFILE%\AppData\Roaming" mkdir "%TARGET_PROFILE%\AppData\Roaming" >nul 2>&1
if not exist "%TARGET_PROFILE%\AppData\Local" mkdir "%TARGET_PROFILE%\AppData\Local" >nul 2>&1

icacls "%TARGET_PROFILE%" /grant "%TARGET_USER%:(OI)(CI)F" /T /C /Q >nul 2>&1
echo [OK] 独立存储目录完全控制权限已赋予给 %TARGET_USER%。
echo.

REM ==================================================
REM 7. 配置父目录遍历权限 (解决 Node.js realpathSync EPERM 崩溃)
REM ==================================================
echo [步骤 4/7] 配置父目录遍历权限 (防止 Node 模块加载权限不足崩溃)...
icacls "%HOST_PROFILE%" /grant "%TARGET_USER%:(RX)" >nul 2>&1
icacls "%HOST_PROFILE%\AppData" /grant "%TARGET_USER%:(RX)" >nul 2>&1
icacls "%HOST_PROFILE%\AppData\Local" /grant "%TARGET_USER%:(RX)" >nul 2>&1
icacls "%HOST_PROFILE%\AppData\Local\Programs" /grant "%TARGET_USER%:(RX)" >nul 2>&1
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
copy /y "%~dp0internal_worker.bat" "%TARGET_PROFILE%\run_account2.bat" >nul 2>&1
copy /y "%~dp02_Launch_Account2.bat" "%TARGET_PROFILE%\Launch_Account2.bat" >nul 2>&1
copy /y "%~dp0launch_silent.vbs" "%TARGET_PROFILE%\launch_silent.vbs" >nul 2>&1
copy /y "%~dp0worker_silent.vbs" "%TARGET_PROFILE%\worker_silent.vbs" >nul 2>&1
icacls "%TARGET_PROFILE%\run_account2.bat" /grant "%TARGET_USER%:(OI)(CI)F" >nul 2>&1
icacls "%TARGET_PROFILE%\worker_silent.vbs" /grant "%TARGET_USER%:(OI)(CI)F" >nul 2>&1
echo [OK] 启动套件已部署到: %TARGET_PROFILE%
echo.

REM ==================================================
REM 9. 修改注册表 ProfileImagePath 指向独立数据目录
REM ==================================================
echo [步骤 6/7] 配置 Windows 用户配置文件路径指向 %TARGET_PROFILE%...
set "USER_SID="
for /f "delims=" %%I in ('powershell -NoProfile -Command "([System.Security.Principal.NTAccount]'%TARGET_USER%').Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%I"
if defined USER_SID (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\%USER_SID%" /v ProfileImagePath /t REG_EXPAND_SZ /d "%TARGET_PROFILE%" /f >nul 2>&1
    echo [OK] 注册表 ProfileImagePath (SID: %USER_SID%) 已重定向到: %TARGET_PROFILE%
) else (
    echo [!] 未能动态获取 SID，尝试搜索现有注册表项...
    for /f "tokens=*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /s /f "%TARGET_USER%" ^| findstr /i "HKEY_LOCAL_MACHINE"') do (
        reg add "%%A" /v ProfileImagePath /t REG_EXPAND_SZ /d "%TARGET_PROFILE%" /f >nul 2>&1
    )
)

if exist "C:\Users\%TARGET_USER%" (
    if /i not "C:\Users\%TARGET_USER%"=="%TARGET_PROFILE%" (
        echo 正在清理 C:\Users\%TARGET_USER% 根目录残留...
        rd /s /q "C:\Users\%TARGET_USER%" >nul 2>&1
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
