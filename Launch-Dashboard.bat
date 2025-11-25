@echo off
REM Computer Monitoring Dashboard Launcher
REM Double-click this file to start the system

cd /d "%~dp0"
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-all-protected.ps1"
