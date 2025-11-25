#Requires -Version 5.1

<#
.SYNOPSIS
    Quick system test to verify everything is working
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Computer Monitoring System - Quick Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$allGood = $true

# Test 1: Check configuration file
Write-Host "[1/6] Checking configuration file..." -ForegroundColor Yellow
$configPath = Join-Path $scriptDir "config.json"
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        Write-Host "  ✓ Configuration file valid" -ForegroundColor Green
        
        # Check CSV file exists
        if (Test-Path $config.csvFilePath) {
            $csvCount = (Import-Csv $config.csvFilePath).Count
            Write-Host "  ✓ CSV file found with $csvCount computers" -ForegroundColor Green
        } else {
            Write-Host "  ✗ CSV file not found: $($config.csvFilePath)" -ForegroundColor Red
            $allGood = $false
        }
    } catch {
        Write-Host "  ✗ Configuration file invalid: $_" -ForegroundColor Red
        $allGood = $false
    }
} else {
    Write-Host "  ✗ Configuration file not found" -ForegroundColor Red
    $allGood = $false
}

# Test 2: Check Python
Write-Host "`n[2/6] Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✓ Python installed: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Python not found" -ForegroundColor Red
    $allGood = $false
}

# Test 3: Check Flask
Write-Host "`n[3/6] Checking Flask..." -ForegroundColor Yellow
$flaskCheck = python -c "import flask; print('OK')" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Flask installed" -ForegroundColor Green
} else {
    Write-Host "  ✗ Flask not installed (run: pip install Flask)" -ForegroundColor Red
    $allGood = $false
}

# Test 4: Check directories
Write-Host "`n[4/6] Checking directories..." -ForegroundColor Yellow
$dataDir = Join-Path $scriptDir "data"
$logsDir = Join-Path $scriptDir "logs"
$templatesDir = Join-Path $scriptDir "templates"

if ((Test-Path $dataDir) -and (Test-Path $logsDir) -and (Test-Path $templatesDir)) {
    Write-Host "  ✓ All required directories exist" -ForegroundColor Green
} else {
    Write-Host "  ✗ Missing required directories" -ForegroundColor Red
    $allGood = $false
}

# Test 5: Check if monitoring has run
Write-Host "`n[5/6] Checking monitoring data..." -ForegroundColor Yellow
$statusFile = Join-Path $dataDir "status.json"
if (Test-Path $statusFile) {
    try {
        $status = Get-Content $statusFile -Raw | ConvertFrom-Json
        Write-Host "  ✓ Status file exists" -ForegroundColor Green
        Write-Host "    Last update: $($status.lastUpdate)" -ForegroundColor Gray
        Write-Host "    Online: $($status.onlineCount) / Offline: $($status.offlineCount)" -ForegroundColor Gray
    } catch {
        Write-Host "  ✗ Status file invalid" -ForegroundColor Red
        $allGood = $false
    }
} else {
    Write-Host "  ⚠ Status file not found (monitoring hasn't run yet)" -ForegroundColor Yellow
    Write-Host "    Run: .\monitor.ps1" -ForegroundColor Gray
}

# Test 6: Check PowerShell version
Write-Host "`n[6/6] Checking PowerShell version..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5) {
    Write-Host "  ✓ PowerShell $psVersion (compatible)" -ForegroundColor Green
} else {
    Write-Host "  ✗ PowerShell $psVersion (need 5.1+)" -ForegroundColor Red
    $allGood = $false
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "✓ All tests passed!" -ForegroundColor Green
    Write-Host "`nYou're ready to go! Run:" -ForegroundColor White
    Write-Host "  .\start-all.ps1" -ForegroundColor Cyan
} else {
    Write-Host "✗ Some tests failed" -ForegroundColor Red
    Write-Host "Please fix the issues above before starting" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
