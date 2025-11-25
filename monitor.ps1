#Requires -Version 5.1

<#
.SYNOPSIS
    Computer connectivity monitoring script
.DESCRIPTION
    Monitors computers from CSV file, tests connectivity, tracks state changes, and logs results
#>

param(
    [string]$ConfigPath = "$PSScriptRoot\config.json"
)

# Global variables
$Script:Config = $null
$Script:StatusFilePath = ""
$Script:HistoryFilePath = ""
$Script:LogFilePath = ""

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to console
    switch ($Level) {
        'ERROR'   { Write-Host $logMessage -ForegroundColor Red }
        'WARNING' { Write-Host $logMessage -ForegroundColor Yellow }
        default   { Write-Host $logMessage -ForegroundColor Gray }
    }
    
    # Write to log file
    if ($Script:LogFilePath) {
        try {
            Add-Content -Path $Script:LogFilePath -Value $logMessage -ErrorAction Stop
        }
        catch {
            # Silently continue if log file not yet initialized
        }
    }
}

function Import-Configuration {
    param([string]$Path)
    
    try {
        if (-not (Test-Path $Path)) {
            throw "Configuration file not found: $Path"
        }
        
        $configContent = Get-Content -Path $Path -Raw -ErrorAction Stop
        $config = $configContent | ConvertFrom-Json -ErrorAction Stop
        
        # Set script-level paths
        $Script:StatusFilePath = Join-Path $config.dataDirectory "status.json"
        $Script:HistoryFilePath = Join-Path $config.dataDirectory "history.json"
        
        $logFileName = "monitor_$(Get-Date -Format 'yyyyMMdd').log"
        $Script:LogFilePath = Join-Path $config.logDirectory $logFileName
        
        return $config
    }
    catch {
        Write-Host "ERROR: Failed to load configuration: $_" -ForegroundColor Red
        exit 1
    }
}

function Import-ComputerList {
    param(
        [string]$CsvPath
    )
    
    try {
        if (-not (Test-Path $CsvPath)) {
            throw "CSV file not found: $CsvPath"
        }
        
        $computers = Import-Csv -Path $CsvPath -ErrorAction Stop
        
        if ($computers.Count -eq 0) {
            throw "CSV file is empty"
        }
        
        Write-Log "Loaded $($computers.Count) computers from CSV"
        return $computers
    }
    catch {
        Write-Log "Failed to import computer list: $_" -Level ERROR
        throw
    }
}

function Test-ComputerStatus {
    param(
        [array]$Computers,
        [int]$TimeoutSeconds = 2,
        [int]$Count = 1,
        [int]$ThrottleLimit = 20
    )
    
    Write-Log "Testing connectivity for $($Computers.Count) computers (parallel: $ThrottleLimit)..."
    
    $results = $Computers | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
        $computer = $_.ComputerName
        $location = $_.Location
        $timeout = $using:TimeoutSeconds
        $count = $using:Count
        
        try {
            # Test-Connection in PowerShell 5.1 compatible way
            $pingResult = Test-Connection -ComputerName $computer -Count $count -Quiet -ErrorAction Stop
            
            $status = if ($pingResult) { "Online" } else { "Offline" }
        }
        catch {
            $status = "Offline"
        }
        
        [PSCustomObject]@{
            ComputerName = $computer
            Location = $location
            Status = $status
            TestTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
    
    $onlineCount = ($results | Where-Object { $_.Status -eq "Online" }).Count
    Write-Log "Connectivity test complete: $onlineCount/$($results.Count) online"
    
    return $results
}

function Get-PreviousStatus {
    try {
        if (Test-Path $Script:StatusFilePath) {
            $content = Get-Content -Path $Script:StatusFilePath -Raw -ErrorAction Stop
            $data = $content | ConvertFrom-Json -ErrorAction Stop
            return $data.computers
        }
        return @()
    }
    catch {
        Write-Log "Failed to read previous status: $_" -Level WARNING
        return @()
    }
}

function Compare-StateChanges {
    param(
        [array]$CurrentStatus,
        [array]$PreviousStatus
    )
    
    $changes = @()
    
    # Create hashtable for quick lookup of previous status and metadata
    $previousHash = @{}
    foreach ($prev in $PreviousStatus) {
        $previousHash[$prev.ComputerName] = $prev
    }
    
    foreach ($current in $CurrentStatus) {
        $computerName = $current.ComputerName
        $currentState = $current.Status
        $previous = $previousHash[$computerName]
        
        # Track LastSeen (when computer was last online)
        if ($previous) {
            if ($currentState -eq "Online") {
                # Computer is online now - update LastSeen to current time
                $current | Add-Member -NotePropertyName "LastSeen" -NotePropertyValue $current.TestTime -Force
            }
            elseif ($currentState -eq "Offline") {
                # Computer is offline now
                if ($previous.Status -eq "Online") {
                    # Just went offline - LastSeen was the previous check time
                    $current | Add-Member -NotePropertyName "LastSeen" -NotePropertyValue $previous.TestTime -Force
                }
                elseif ($previous.LastSeen) {
                    # Was already offline - keep the previous LastSeen time
                    $current | Add-Member -NotePropertyName "LastSeen" -NotePropertyValue $previous.LastSeen -Force
                }
                else {
                    # Was offline before but no LastSeen - mark as unknown
                    $current | Add-Member -NotePropertyName "LastSeen" -NotePropertyValue "Unknown" -Force
                }
            }
            
            # Track state changes
            if ($previous.Status -and $previous.Status -ne $currentState) {
                $change = [PSCustomObject]@{
                    ComputerName = $computerName
                    PreviousStatus = $previous.Status
                    CurrentStatus = $currentState
                    ChangeTime = $current.TestTime
                }
                $changes += $change
                
                Write-Log "State change detected: $computerName ($($previous.Status) -> $currentState)" -Level WARNING
            }
        }
        else {
            # First time seeing this computer
            if ($currentState -eq "Online") {
                # Online - set LastSeen to now
                $current | Add-Member -NotePropertyName "LastSeen" -NotePropertyValue $current.TestTime -Force
            }
            else {
                # Offline and never seen before - mark as unknown
                $current | Add-Member -NotePropertyName "LastSeen" -NotePropertyValue "Unknown" -Force
            }
        }
    }
    
    return $changes
}

function Update-StatusFile {
    param([array]$Status)
    
    try {
        $data = @{
            lastUpdate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            totalComputers = $Status.Count
            onlineCount = ($Status | Where-Object { $_.Status -eq "Online" }).Count
            offlineCount = ($Status | Where-Object { $_.Status -eq "Offline" }).Count
            computers = $Status
        }
        
        $json = $data | ConvertTo-Json -Depth 10 -Compress:$false
        $json | Set-Content -Path $Script:StatusFilePath -ErrorAction Stop
        
        Write-Log "Updated status file: $Script:StatusFilePath"
    }
    catch {
        Write-Log "Failed to update status file: $_" -Level ERROR
        throw
    }
}

function Update-HistoryFile {
    param(
        [array]$Changes,
        [int]$MaxEvents = 100
    )
    
    if ($Changes.Count -eq 0) {
        return
    }
    
    try {
        # Load existing history
        $history = @()
        if (Test-Path $Script:HistoryFilePath) {
            $content = Get-Content -Path $Script:HistoryFilePath -Raw -ErrorAction Stop
            $historyData = $content | ConvertFrom-Json -ErrorAction Stop
            $history = @($historyData.events)
        }
        
        # Add new changes
        $history = @($Changes) + $history
        
        # Limit to max events
        if ($history.Count -gt $MaxEvents) {
            $history = $history[0..($MaxEvents - 1)]
        }
        
        $data = @{
            lastUpdate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            eventCount = $history.Count
            events = $history
        }
        
        $json = $data | ConvertTo-Json -Depth 10 -Compress:$false
        $json | Set-Content -Path $Script:HistoryFilePath -ErrorAction Stop
        
        Write-Log "Updated history file with $($Changes.Count) new event(s)"
    }
    catch {
        Write-Log "Failed to update history file: $_" -Level ERROR
    }
}

function Start-Monitoring {
    Write-Log "========================================" -Level INFO
    Write-Log "Starting Computer Monitoring System" -Level INFO
    Write-Log "========================================" -Level INFO
    
    # Load configuration
    $Script:Config = Import-Configuration -Path $ConfigPath
    Write-Log "Configuration loaded from: $ConfigPath"
    
    # Import computer list
    $computers = Import-ComputerList -CsvPath $Script:Config.csvFilePath
    
    # Get previous status for comparison
    $previousStatus = Get-PreviousStatus
    
    # Test connectivity
    $currentStatus = Test-ComputerStatus `
        -Computers $computers `
        -TimeoutSeconds $Script:Config.pingSettings.timeoutSeconds `
        -Count $Script:Config.pingSettings.count `
        -ThrottleLimit $Script:Config.pingSettings.parallelThrottle
    
    # Compare states and detect changes
    $changes = Compare-StateChanges -CurrentStatus $currentStatus -PreviousStatus $previousStatus
    
    # Update files
    Update-StatusFile -Status $currentStatus
    Update-HistoryFile -Changes $changes -MaxEvents $Script:Config.historySettings.maxEvents
    
    $onlineCount = ($currentStatus | Where-Object { $_.Status -eq "Online" }).Count
    $offlineCount = ($currentStatus | Where-Object { $_.Status -eq "Offline" }).Count
    $percentage = [math]::Round(($onlineCount / $currentStatus.Count) * 100, 1)
    
    Write-Log "Monitoring cycle complete: $onlineCount online, $offlineCount offline ($percentage%)"
    
    if ($changes.Count -gt 0) {
        Write-Log "Detected $($changes.Count) state change(s) this cycle" -Level WARNING
    }
}

# Main execution
try {
    Start-Monitoring
}
catch {
    Write-Log "Fatal error: $_" -Level ERROR
    exit 1
}
