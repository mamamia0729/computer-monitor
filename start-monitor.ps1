#Requires -Version 5.1

<#
.SYNOPSIS
    Starts the computer monitoring script in continuous loop
.DESCRIPTION
    Runs the monitor.ps1 script continuously with configured interval between runs
#>

$scriptDir = $PSScriptRoot
$configPath = Join-Path $scriptDir "config.json"
$monitorScript = Join-Path $scriptDir "monitor.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Computer Monitoring - Background Service" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: Configuration file not found: $configPath" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$interval = $config.monitoringInterval

Write-Host "Configuration loaded" -ForegroundColor Green
Write-Host "Monitoring interval: $interval seconds" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
Write-Host ""

$runCount = 0

try {
    while ($true) {
        $runCount++
        Write-Host "----------------------------------------" -ForegroundColor Gray
        Write-Host "Run #$runCount - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
        Write-Host "----------------------------------------" -ForegroundColor Gray
        
        # Run monitoring script
        & $monitorScript -ConfigPath $configPath
        
        Write-Host ""
        Write-Host "Waiting $interval seconds until next run..." -ForegroundColor Gray
        Write-Host ""
        
        Start-Sleep -Seconds $interval
    }
}
catch {
    Write-Host "Monitoring stopped: $_" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "Monitoring service stopped" -ForegroundColor Yellow
}
