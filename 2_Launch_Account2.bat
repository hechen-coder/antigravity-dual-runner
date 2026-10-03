@echo off
title 启动 Antigravity 账号2 (独立隔离)
setlocal enabledelayedexpansion

cd /d "%~dp0"

REM ==================================================
REM 1. 动态推导宿主主用户的真实主目录
REM ==================================================
set "HOST_PROFILE=%USERPROFILE%"
if "%HOST_PROFILE:~-1%"=="\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"
for %%I in ("%HOST_PROFILE%") do (
    if /i "%%~nxI"==".antigravity-profile2" set "HOST_PROFILE=%%~dpI"
    if /i "%%~nxI"=="Antigravity2" set "HOST_PROFILE=%%~dpI"
)
if "%HOST_PROFILE:~-1%"=="\" set "HOST_PROFILE=%HOST_PROFILE:~0,-1%"

REM ==================================================
REM 2. 检查隔离运行环境目录 (优先级: .antigravity-profile2 > Antigravity2)
REM ==================================================
set "TARGET_PROFILE=%HOST_PROFILE%\.antigravity-profile2"
if not exist "%TARGET_PROFILE%" set "TARGET_PROFILE=%HOST_PROFILE%\Antigravity2"

if not exist "%TARGET_PROFILE%\launch_silent.vbs" (
    if not exist "%TARGET_PROFILE%\run_account2.bat" (
        echo ======================================================
        echo [提示] 检测到隔离环境尚未初始化！
        echo 请先双击运行 [1_Setup_DualUser.bat] 完成一键配置。
        echo ======================================================
        pause
        exit /b 1
    )
)

REM 自动同步本工程最新脚本到运行时环境 (确保配置更新实时生效)
if exist "%~dp0internal_worker.bat" copy /y "%~dp0internal_worker.bat" "%TARGET_PROFILE%\run_account2.bat" >nul 2>&1
if exist "%~dp0launch_silent.vbs" copy /y "%~dp0launch_silent.vbs" "%TARGET_PROFILE%\launch_silent.vbs" >nul 2>&1
if exist "%~dp0worker_silent.vbs" copy /y "%~dp0worker_silent.vbs" "%TARGET_PROFILE%\worker_silent.vbs" >nul 2>&1

REM ==================================================
REM 3. 静默秒开启动 (彻底消除黑窗口、无路径空格解析 Bug、秒开运行)
REM ==================================================
if exist "%TARGET_PROFILE%\launch_silent.vbs" (
    wscript.exe //nologo "%TARGET_PROFILE%\launch_silent.vbs"
    exit /b 0
)

REM 兜底直接使用 runas (转义嵌套引号，防止因路径含空格报错闪退)
set "TARGET_USER=Antigravity2"
set "SAFE_WORKER=%TARGET_PROFILE%\run_account2.bat"
runas /profile /savecred /user:%TARGET_USER% "cmd.exe /c \"\"%SAFE_WORKER%\"\""
exit /b 0
