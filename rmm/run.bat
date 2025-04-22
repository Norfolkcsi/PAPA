@echo off

:: Elevate if not admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Full path to the script in the same folder
set scriptPath=%~dp0remote_loader.ps1

:: Run it using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Get-Content -Raw -Path '%scriptPath%')"

:: Wait for user to press Enter
powershell -Command "Read-Host 'Press Enter to exit'"