#Requires -Version 5.1

<#
.SYNOPSIS
    Restarts TermService and UmRdpService on a remote computer
.DESCRIPTION
    Non-interactive script to restart RDP services remotely
    Called by the monitoring dashboard API
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$ComputerName
)

try {
    # Test connectivity first
    $pingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue
    
    if (-not $pingResult) {
        Write-Output "ERROR: Cannot reach $ComputerName"
        exit 1
    }
    
    Write-Output "Connected to $ComputerName"
    
    # Stop UmRdpService first
    Write-Output "Stopping UmRdpService..."
    $stopDependent = sc.exe "\\$ComputerName" stop UmRdpService 2>&1
    Start-Sleep -Seconds 3
    
    # Stop TermService
    Write-Output "Stopping TermService..."
    $stopTerm = sc.exe "\\$ComputerName" stop TermService 2>&1
    
    if ($LASTEXITCODE -ne 0 -and $stopTerm -notmatch 'STOP_PENDING') {
        Write-Output "ERROR: Failed to stop TermService: $stopTerm"
        exit 1
    }
    
    Start-Sleep -Seconds 5
    
    # Start TermService
    Write-Output "Starting TermService..."
    $startTerm = sc.exe "\\$ComputerName" start TermService 2>&1
    
    if ($LASTEXITCODE -ne 0 -and $startTerm -notmatch 'START_PENDING') {
        Write-Output "ERROR: Failed to start TermService: $startTerm"
        exit 1
    }
    
    Start-Sleep -Seconds 3
    
    # Start UmRdpService
    Write-Output "Starting UmRdpService..."
    $startDependent = sc.exe "\\$ComputerName" start UmRdpService 2>&1
    
    # Verify TermService is running
    $query = sc.exe "\\$ComputerName" query TermService 2>&1
    
    if ($query -match 'RUNNING') {
        Write-Output "SUCCESS: TermService restarted successfully on $ComputerName"
        exit 0
    }
    else {
        Write-Output "WARNING: TermService may not have started successfully"
        exit 1
    }
}
catch {
    Write-Output "ERROR: $_"
    exit 1
}
