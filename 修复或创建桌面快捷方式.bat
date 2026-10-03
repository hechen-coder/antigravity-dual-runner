@echo off
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
