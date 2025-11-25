#Requires -Version 5.1

<#
.SYNOPSIS
    Starts both monitoring service and dashboard with closure protection
.DESCRIPTION
    Launches both services with warnings against accidental closure
#>

$scriptDir = $PSScriptRoot
$monitorScript = Join-Path $scriptDir "monitor.ps1"
$dashboardScript = Join-Path $scriptDir "start-dashboard.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Computer Monitoring System - Startup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if scripts exist
if (-not (Test-Path $monitorScript)) {
    Write-Host "ERROR: monitor.ps1 not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $dashboardScript)) {
    Write-Host "ERROR: start-dashboard.ps1 not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Starting monitoring service..." -ForegroundColor Yellow

# Start monitoring in new window with warning title
$monitorWindowTitle = "MONITORING SERVICE - DO NOT CLOSE"
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "& {`$Host.UI.RawUI.WindowTitle='$monitorWindowTitle'; & '$monitorScript'}" -WindowStyle Minimized

Start-Sleep -Seconds 2

Write-Host "Starting dashboard web server..." -ForegroundColor Yellow

# Start dashboard in new window with warning title
$dashboardWindowTitle = "DASHBOARD WEB SERVER - DO NOT CLOSE"
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "& {`$Host.UI.RawUI.WindowTitle='$dashboardWindowTitle'; & '$dashboardScript'}" -WindowStyle Minimized

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Both services started successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The windows are MINIMIZED in your taskbar" -ForegroundColor Cyan
Write-Host "They show: 'DO NOT CLOSE' in the title" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dashboard: http://localhost:5000" -ForegroundColor Green
Write-Host ""

# Get local IP for network access
try {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.PrefixOrigin -eq "Dhcp"}).IPAddress | Select-Object -First 1
    if ($localIP) {
        Write-Host "Network Access URL: http://$($localIP):5000" -ForegroundColor Green
        Write-Host "(Share this URL with others on your network)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "Could not determine local IP address" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  - Windows are MINIMIZED (check taskbar)" -ForegroundColor White
Write-Host "  - DO NOT close the PowerShell windows" -ForegroundColor White
Write-Host "  - To stop: Run 'Stop-Dashboard.bat'" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit this window (services will continue)..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
