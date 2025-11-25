#Requires -Version 5.1

<#
.SYNOPSIS
    Stops all Computer Monitoring services
.DESCRIPTION
    Cleanly shuts down monitoring and dashboard processes
#>

Write-Host "========================================" -ForegroundColor Red
Write-Host "Stopping Computer Monitoring System" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

$stopped = $false

# Stop Flask/Python processes (dashboard)
Write-Host "Stopping dashboard web server..." -ForegroundColor Yellow
$pythonProcs = Get-Process -Name python* -ErrorAction SilentlyContinue
if ($pythonProcs) {
    $pythonProcs | Where-Object { $_.CommandLine -like "*app.py*" } | Stop-Process -Force
    Write-Host "  Dashboard stopped" -ForegroundColor Green
    $stopped = $true
} else {
    Write-Host "  No dashboard processes found" -ForegroundColor Gray
}

# Stop monitoring PowerShell processes
Write-Host "Stopping monitoring service..." -ForegroundColor Yellow
$pwshProcs = Get-Process -Name pwsh -ErrorAction SilentlyContinue
if ($pwshProcs) {
    foreach ($proc in $pwshProcs) {
        try {
            if ($proc.MainWindowTitle -like "*Computer Monitor*" -or 
                $proc.CommandLine -like "*monitor.ps1*" -or 
                $proc.CommandLine -like "*start-dashboard.ps1*") {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                Write-Host "  Stopped process: $($proc.Id)" -ForegroundColor Green
                $stopped = $true
            }
        }
        catch {
            # Process might have already stopped
        }
    }
}

if (-not $stopped) {
    Write-Host "  No monitoring processes found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All services stopped" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
