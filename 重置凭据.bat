@echo off
title 重置 Antigravity2 凭据

echo ======================================================
echo         重置 Antigravity2 存储的 Windows 凭据
echo ======================================================
echo.
set "TARGET_USER=Antigravity2"
echo 正在清除保存的凭据缓存...
cmdkey /delete:Domain:interactive=%COMPUTERNAME%\%TARGET_USER% >nul 2>&1
cmdkey /delete:Domain:interactive=%TARGET_USER% >nul 2>&1
cmdkey /delete:%TARGET_USER% >nul 2>&1
echo.
echo [OK] 凭据已清除完毕！
echo 下次启动时将重新提示输入密码：Anti@2026!Pass
echo.
pause
exit /b 0
