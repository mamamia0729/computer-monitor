#Requires -Version 5.1

<#
.SYNOPSIS
    Starts both monitoring service and dashboard web server
.DESCRIPTION
    Launches both the monitoring loop and Flask dashboard in separate windows
#>

$scriptDir = $PSScriptRoot
$monitorScript = Join-Path $scriptDir "start-monitor.ps1"
$dashboardScript = Join-Path $scriptDir "start-dashboard.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Computer Monitoring System - Startup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if scripts exist
if (-not (Test-Path $monitorScript)) {
    Write-Host "ERROR: start-monitor.ps1 not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dashboardScript)) {
    Write-Host "ERROR: start-dashboard.ps1 not found" -ForegroundColor Red
    exit 1
}

Write-Host "Starting monitoring service..." -ForegroundColor Yellow

# Start monitoring in new window
Start-Process pwsh -ArgumentList "-NoExit", "-File", "`"$monitorScript`"" -WindowStyle Normal

Start-Sleep -Seconds 2

Write-Host "Starting dashboard web server..." -ForegroundColor Yellow

# Start dashboard in new window
Start-Process pwsh -ArgumentList "-NoExit", "-File", "`"$dashboardScript`"" -WindowStyle Normal

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Both services started successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Monitoring Service: Running in separate window" -ForegroundColor Cyan
Write-Host "Dashboard: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop: Close both PowerShell windows" -ForegroundColor Yellow
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
Write-Host "Press any key to exit this window (services will continue running)..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
