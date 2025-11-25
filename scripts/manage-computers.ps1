#Requires -Version 5.1

<#
.SYNOPSIS
    Helper script to manage computer list
.DESCRIPTION
    Add, remove, or update computers in the monitoring list
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Add', 'Remove', 'List', 'Import')]
    [string]$Action = 'List',
    
    [Parameter(Mandatory=$false)]
    [string]$ComputerName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location,
    
    [Parameter(Mandatory=$false)]
    [string]$ImportFile
)

$CsvPath = "C:\Users\tladm\connectivity-report.csv"

function Show-Menu {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Computer List Management" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage Examples:" -ForegroundColor Yellow
    Write-Host "  .\manage-computers.ps1 -Action List" -ForegroundColor Gray
    Write-Host "  .\manage-computers.ps1 -Action Add -ComputerName 'PC-001' -Location '5F Main IDF'" -ForegroundColor Gray
    Write-Host "  .\manage-computers.ps1 -Action Remove -ComputerName 'PC-001'" -ForegroundColor Gray
    Write-Host "  .\manage-computers.ps1 -Action Import -ImportFile 'newlist.csv'" -ForegroundColor Gray
    Write-Host ""
}

switch ($Action) {
    'List' {
        Write-Host "`nCurrent Computer List:" -ForegroundColor Cyan
        Write-Host "======================" -ForegroundColor Cyan
        
        if (Test-Path $CsvPath) {
            $computers = Import-Csv $CsvPath
            
            # Group by location
            $byLocation = $computers | Group-Object Location
            
            foreach ($group in $byLocation) {
                Write-Host "`n$($group.Name): $($group.Count) computers" -ForegroundColor Yellow
            }
            
            Write-Host "`nTotal: $($computers.Count) computers" -ForegroundColor Green
            Write-Host ""
            
            # Show summary
            $computers | Group-Object Location | Select-Object Name, Count | Format-Table -AutoSize
        }
        else {
            Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
        }
    }
    
    'Add' {
        if (-not $ComputerName -or -not $Location) {
            Write-Host "ERROR: -ComputerName and -Location are required for Add action" -ForegroundColor Red
            Show-Menu
            exit 1
        }
        
        $computers = Import-Csv $CsvPath
        
        # Check if computer already exists
        if ($computers.ComputerName -contains $ComputerName) {
            Write-Host "WARNING: Computer '$ComputerName' already exists in the list" -ForegroundColor Yellow
            $confirm = Read-Host "Update location? (Y/N)"
            if ($confirm -ne 'Y') {
                Write-Host "Cancelled" -ForegroundColor Yellow
                exit 0
            }
            
            # Update existing
            $computers = $computers | ForEach-Object {
                if ($_.ComputerName -eq $ComputerName) {
                    $_.Location = $Location
                }
                $_
            }
        }
        else {
            # Add new
            $newComputer = [PSCustomObject]@{
                ComputerName = $ComputerName
                Location = $Location
                Status = 'Online'
                TestTime = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
            }
            $computers = @($computers) + $newComputer
        }
        
        # Save
        $computers | Export-Csv $CsvPath -NoTypeInformation -Force
        Write-Host "✓ Computer '$ComputerName' added/updated in location '$Location'" -ForegroundColor Green
        Write-Host "Total computers: $($computers.Count)" -ForegroundColor Cyan
    }
    
    'Remove' {
        if (-not $ComputerName) {
            Write-Host "ERROR: -ComputerName is required for Remove action" -ForegroundColor Red
            Show-Menu
            exit 1
        }
        
        $computers = Import-Csv $CsvPath
        $originalCount = $computers.Count
        
        $computers = $computers | Where-Object { $_.ComputerName -ne $ComputerName }
        
        if ($computers.Count -eq $originalCount) {
            Write-Host "WARNING: Computer '$ComputerName' not found in list" -ForegroundColor Yellow
        }
        else {
            $computers | Export-Csv $CsvPath -NoTypeInformation -Force
            Write-Host "✓ Computer '$ComputerName' removed" -ForegroundColor Green
            Write-Host "Remaining computers: $($computers.Count)" -ForegroundColor Cyan
        }
    }
    
    'Import' {
        if (-not $ImportFile) {
            Write-Host "ERROR: -ImportFile is required for Import action" -ForegroundColor Red
            Show-Menu
            exit 1
        }
        
        if (-not (Test-Path $ImportFile)) {
            Write-Host "ERROR: File not found: $ImportFile" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Importing from: $ImportFile" -ForegroundColor Yellow
        
        # Read new file
        $newComputers = Import-Csv $ImportFile
        
        # Check if Location column exists
        if (-not ($newComputers[0].PSObject.Properties.Name -contains 'Location')) {
            Write-Host "ERROR: Import file must have 'Location' column" -ForegroundColor Red
            Write-Host "Expected columns: ComputerName, Location" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "Found $($newComputers.Count) computers" -ForegroundColor Cyan
        
        # Confirm
        $confirm = Read-Host "Replace current list? (Y/N)"
        if ($confirm -eq 'Y') {
            # Add Status and TestTime if missing
            $newComputers = $newComputers | ForEach-Object {
                if (-not $_.Status) {
                    $_ | Add-Member -NotePropertyName 'Status' -NotePropertyValue 'Online' -Force
                }
                if (-not $_.TestTime) {
                    $_ | Add-Member -NotePropertyName 'TestTime' -NotePropertyValue (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') -Force
                }
                $_
            }
            
            # Backup old file
            $backupPath = "$CsvPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $CsvPath $backupPath
            Write-Host "Backup created: $backupPath" -ForegroundColor Gray
            
            # Save new file
            $newComputers | Export-Csv $CsvPath -NoTypeInformation -Force
            Write-Host "✓ Computer list updated" -ForegroundColor Green
            Write-Host "Total computers: $($newComputers.Count)" -ForegroundColor Cyan
        }
        else {
            Write-Host "Cancelled" -ForegroundColor Yellow
        }
    }
}
