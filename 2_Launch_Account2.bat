@echo off
setlocal
cd /d "%~dp0"

set "TARGET_USER=Antigravity2"
set "SAFE_WORKER=%~dp0run_account2.bat"

if not exist "%SAFE_WORKER%" (
    if exist "%~dp0internal_worker.bat" copy /y "%~dp0internal_worker.bat" "%SAFE_WORKER%" >nul 2>&1
)

runas /profile /savecred /user:%TARGET_USER% "cmd.exe /c "%SAFE_WORKER%""
exit /b 0
