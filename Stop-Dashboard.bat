@echo off
REM Stop Computer Monitoring Dashboard

cd /d "%~dp0"
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Stop-Dashboard.ps1"
