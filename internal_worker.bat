@echo off

REM ==================================================
REM 1. �?动为隔�?�用户注册默认浏览器协�??与网络代�?
REM (注意：必须在 enabledelayedexpansion 前执行，以确�? %1 准确写入注册�?)
REM ==================================================
set "SYS_BROWSER="
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "SYS_BROWSER=C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "SYS_BROWSER=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
) else if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
    set "SYS_BROWSER=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

if defined SYS_BROWSER (
    reg add "HKCU\Software\Classes\http" /ve /t REG_SZ /d "URL:HyperText Transfer Protocol" /f >nul 2>&1
    reg add "HKCU\Software\Classes\http" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCU\Software\Classes\http\shell\open\command" /ve /t REG_SZ /d ""%SYS_BROWSER%" --single-argument "%%1"" /f >nul 2>&1
    reg delete "HKCU\Software\Classes\http\shell\open\command" /v "DelegateExecute" /f >nul 2>&1

    reg add "HKCU\Software\Classes\https" /ve /t REG_SZ /d "URL:HyperText Transfer Protocol with Privacy" /f >nul 2>&1
    reg add "HKCU\Software\Classes\https" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCU\Software\Classes\https\shell\open\command" /ve /t REG_SZ /d ""%SYS_BROWSER%" --single-argument "%%1"" /f >nul 2>&1
    reg delete "HKCU\Software\Classes\https\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
)

set "PROXY_HOST=127.0.0.1"
set "PROXY_PORT=7890"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "%PROXY_HOST%:%PROXY_PORT%" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "<local>;localhost;127.0.0.1" /f >nul 2>&1

setlocal enabledelayedexpansion

REM ==================================================
REM 2. 动�?�定位独立存储目录与宿主用户�?�?
REM ==================================================
set "PROFILE_DIR=%~dp0"
if "%PROFILE_DIR:~-1%"=="" set "PROFILE_DIR=%PROFILE_DIR:~0,-1%"

for %%I in ("%PROFILE_DIR%\..") do set "HOST_PROFILE=%%~fI"

if not exist "%PROFILE_DIR%\AppData\Roaming" mkdir "%PROFILE_DIR%\AppData\Roaming" >nul 2>&1
if not exist "%PROFILE_DIR%\AppData\Local" mkdir "%PROFILE_DIR%\AppData\Local" >nul 2>&1

set "USERPROFILE=%PROFILE_DIR%"
set "APPDATA=%PROFILE_DIR%\AppData\Roaming"
set "LOCALAPPDATA=%PROFILE_DIR%\AppData\Local"
set "HOME=%PROFILE_DIR%"
set "HOMEDRIVE=C:"
for %%I in ("%PROFILE_DIR%") do set "HOMEPATH=%%~pI%%~nxI"

REM �?�? Electron 主进程独立实例直连浏览器引擎 (彻底解决 Google OAuth 登录弹窗)
set "ANTIGRAVITY_SECONDARY_INSTANCE=1"
REM �?�? Language Server 打印并�?�知外部浏�?�器 URL
set "ANTIGRAVITY_VSCODE_HOST=1"

REM ==================================================
REM 3. �?境变量代理�?�置
REM ==================================================
set "HTTP_PROXY=http://%PROXY_HOST%:%PROXY_PORT%"
set "HTTPS_PROXY=http://%PROXY_HOST%:%PROXY_PORT%"
set "ALL_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%"
set "NO_PROXY=localhost,127.0.0.1,::1"

REM ==================================================
REM 4. 动�?�定�? Antigravity 主程�?
REM ==================================================
set "ANTIGRAVITY_EXE="
if exist "%HOST_PROFILE%\AppData\Local\Programsntigravity\Antigravity.exe" (
    set "ANTIGRAVITY_EXE=%HOST_PROFILE%\AppData\Local\Programsntigravity\Antigravity.exe"
) else if exist "%LOCALAPPDATA%\Programsntigravity\Antigravity.exe" (
    set "ANTIGRAVITY_EXE=%LOCALAPPDATA%\Programsntigravity\Antigravity.exe"
) else if exist "%ProgramFiles%\Antigravity\Antigravity.exe" (
    set "ANTIGRAVITY_EXE=%ProgramFiles%\Antigravity\Antigravity.exe"
)

if not defined ANTIGRAVITY_EXE exit /b 1

for %%I in ("%ANTIGRAVITY_EXE%") do set "ANTIGRAVITY_DIR=%%~dpI"
cd /d "%ANTIGRAVITY_DIR%"

REM 极�?�拉起，立即�?�? (无延迟�?�不残留 CMD 控制�?)
start "" "%ANTIGRAVITY_EXE%" --user-data-dir="%APPDATA%\Antigravity" %*
exit 0
