@echo off
title Antigravity - Account 2 (Legacy)

echo ======================================================
echo [提示] 检测到您正在运行旧版兼容模式启动脚本。
echo 该旧脚本在 Windows 凭据管理器中容易导致“账户窜位”。
echo 推荐使用 runas 彻底物理隔离方案：
echo    同目录下的【2_Launch_Account2.bat】
echo    或桌面快捷方式【Antigravity (账号2 - 独立隔离)】
echo ======================================================
echo.
set /p "CHOICE=是否切换至 runas 彻底隔离模式启动(Y/N，直接回车默认为 Y): "
if /i "%CHOICE%"=="" goto :USE_NEW
if /i "%CHOICE%"=="Y" goto :USE_NEW
goto :CONTINUE_LEGACY

:USE_NEW
call "%~dp02_Launch_Account2.bat"
exit /b %errorlevel%

:CONTINUE_LEGACY
echo 正在继续以旧版兼容方式启动...

REM ==================================================
REM 1. 先保存当前真实 Windows 用户目录（避免后续寻址失败）
REM ==================================================
set "REAL_USERPROFILE=%USERPROFILE%"
set "REAL_LOCALAPPDATA=%LOCALAPPDATA%"

REM Antigravity 实际安装位置
set "ANTIGRAVITY_EXE=%REAL_LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"

if not exist "%ANTIGRAVITY_EXE%" (
    echo.
    echo Antigravity.exe not found:
    echo %ANTIGRAVITY_EXE%
    echo.
    pause
    exit /b 1
)

REM ==================================================
REM 2. Clash / 科学上网代理配置（按需修改端口）
REM ==================================================
set "PROXY_HOST=127.0.0.1"
set "PROXY_PORT=7890"

set "HTTP_PROXY=http://%PROXY_HOST%:%PROXY_PORT%"
set "HTTPS_PROXY=http://%PROXY_HOST%:%PROXY_PORT%"
set "ALL_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%"
set "NO_PROXY=localhost,127.0.0.1,::1"

REM ==================================================
REM 3. 准备 Account 2 独立用户数据目录
REM ==================================================
set "PROFILE_DIR=%REAL_USERPROFILE%\.antigravity-profile2"

if not exist "%PROFILE_DIR%\AppData\Roaming" (
    mkdir "%PROFILE_DIR%\AppData\Roaming"
)

if not exist "%PROFILE_DIR%\AppData\Local" (
    mkdir "%PROFILE_DIR%\AppData\Local"
)

REM ==================================================
REM 4. 临时重定向第二个实例的环境变量
REM ==================================================
set "USERPROFILE=%PROFILE_DIR%"
set "APPDATA=%PROFILE_DIR%\AppData\Roaming"
set "LOCALAPPDATA=%PROFILE_DIR%\AppData\Local"

REM ==================================================
REM 5. 启动第二个 Antigravity 实例
REM ==================================================
start "" "%ANTIGRAVITY_EXE%"

exit /b 0
