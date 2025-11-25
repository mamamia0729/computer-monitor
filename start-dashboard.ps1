#Requires -Version 5.1

<#
.SYNOPSIS
    Starts the Flask web dashboard
.DESCRIPTION
    Launches the Python Flask web server for the monitoring dashboard
#>

$scriptDir = $PSScriptRoot
$appScript = Join-Path $scriptDir "app.py"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Dashboard Web Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python found: $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Python not found. Please install Python 3.x" -ForegroundColor Red
    exit 1
}

# Check if Flask is installed
$flaskCheck = python -c "import flask; print(flask.__version__)" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flask not installed. Installing dependencies..." -ForegroundColor Yellow
    $requirementsFile = Join-Path $scriptDir "requirements.txt"
    
    if (Test-Path $requirementsFile) {
        python -m pip install -r $requirementsFile
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to install Flask" -ForegroundColor Red
            exit 1
        }
        Write-Host "Flask installed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: requirements.txt not found" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Flask version: $flaskCheck" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting Flask application..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start Flask app
try {
    python $appScript
}
catch {
    Write-Host "Dashboard stopped: $_" -ForegroundColor Red
    exit 1
}
