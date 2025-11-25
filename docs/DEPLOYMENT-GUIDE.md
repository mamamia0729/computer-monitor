# Computer Monitoring System - Deployment Guide

## Quick Start (For Operations Team)

### Option 1: Double-Click Launch (Easiest)
1. Navigate to the `computer-monitor` folder
2. **Double-click `Launch-Dashboard.bat`**
3. Two PowerShell windows will open (monitoring + dashboard)
4. Open browser to: http://localhost:5000
5. **Done!** The system is now running

### Option 2: Manual Launch
1. Open PowerShell in the `computer-monitor` folder
2. Run: `.\start-all.ps1`
3. Open browser to: http://localhost:5000

---

## For Server Team Deployment

### System Requirements
- **OS**: Windows Server 2016+ or Windows 10/11
- **PowerShell**: 5.1 or higher (7.x recommended)
- **Python**: 3.8 or higher
- **Network**: Port 5000 (TCP) for dashboard access
- **Firewall**: ICMP outbound for ping monitoring

### Installation Steps

#### 1. Copy Files
Copy the entire `computer-monitor` folder to the target server:
```
C:\Users\<username>\computer-monitor\
```

Or choose a shared location:
```
C:\MonitoringTools\computer-monitor\
```

#### 2. Install Python Dependencies
Open PowerShell in the folder and run:
```powershell
pip install -r requirements.txt
```

This installs:
- Flask 3.0.0 (web server)
- Flask-CORS 4.0.0 (cross-origin support)

#### 3. Configure Computer List
Edit `connectivity-report.csv` with your computer list:
```csv
ComputerName,Location,Status,TestTime
COMPUTER-01,5F Main IDF,Online,2025-11-25 03:24:00
COMPUTER-02,6F NE,Online,2025-11-25 03:24:00
```

**Format**: ComputerName, Location, Status, TestTime
- Use the helper script to manage: `.\manage-computers.ps1 -Action List`

#### 4. Adjust Settings (Optional)
Edit `config.json` to customize:
```json
{
    "csvPath": "C:\\path\\to\\connectivity-report.csv",
    "statusFile": "data/status.json",
    "historyFile": "data/history.json",
    "logPath": "logs",
    "checkInterval": 120,
    "maxParallel": 20,
    "pingTimeout": 2,
    "dashboardPort": 5000,
    "dashboardHost": "0.0.0.0",
    "refreshInterval": 30
}
```

**Key Settings**:
- `checkInterval`: How often to ping (seconds, default: 120 = 2 minutes)
- `dashboardPort`: Web server port (default: 5000)
- `dashboardHost`: "0.0.0.0" for network access, "127.0.0.1" for local only
- `refreshInterval`: Dashboard auto-refresh (seconds, default: 30)

#### 5. Test the System
```powershell
# Test monitoring script
.\test-system.ps1

# If tests pass, launch the system
.\start-all.ps1
```

---

## Network Access Configuration

### Opening Firewall (For Remote Access)
Run in **Administrator PowerShell**:
```powershell
# Allow inbound on port 5000
New-NetFirewallRule -DisplayName "Computer Monitor Dashboard" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5000 `
    -Action Allow
```

### Finding Network URL
After starting, the system displays:
```
Network Access URL: http://10.200.10.37:5000
(Share this URL with others on your network)
```

Share this URL with anyone who needs dashboard access.

---

## Running as a Windows Service (Production)

For 24/7 unattended operation, run as a Windows Service using **NSSM** (Non-Sucking Service Manager).

### Install NSSM
1. Download from: https://nssm.cc/download
2. Extract `nssm.exe` to `C:\Program Files\nssm\`

### Create Monitoring Service
```powershell
# Run as Administrator
nssm install ComputerMonitor "C:\Program Files\PowerShell\7\pwsh.exe" `
    "-NoProfile -ExecutionPolicy Bypass -File C:\MonitoringTools\computer-monitor\monitor.ps1"

nssm set ComputerMonitor AppDirectory "C:\MonitoringTools\computer-monitor"
nssm set ComputerMonitor DisplayName "Computer Monitoring Service"
nssm set ComputerMonitor Description "Monitors computer availability via ICMP ping"
nssm set ComputerMonitor Start SERVICE_AUTO_START

# Start the service
nssm start ComputerMonitor
```

### Create Dashboard Service
```powershell
# Run as Administrator
nssm install ComputerMonitorDashboard "C:\Program Files\PowerShell\7\pwsh.exe" `
    "-NoProfile -ExecutionPolicy Bypass -File C:\MonitoringTools\computer-monitor\start-dashboard.ps1"

nssm set ComputerMonitorDashboard AppDirectory "C:\MonitoringTools\computer-monitor"
nssm set ComputerMonitorDashboard DisplayName "Computer Monitor Dashboard"
nssm set ComputerMonitorDashboard Description "Web dashboard for computer monitoring"
nssm set ComputerMonitorDashboard Start SERVICE_AUTO_START
nssm set ComputerMonitorDashboard DependOnService ComputerMonitor

# Start the service
nssm start ComputerMonitorDashboard
```

### Service Management
```powershell
# Check service status
Get-Service ComputerMonitor*

# Stop services
nssm stop ComputerMonitorDashboard
nssm stop ComputerMonitor

# Restart services
nssm restart ComputerMonitor
nssm restart ComputerMonitorDashboard

# Remove services (uninstall)
nssm remove ComputerMonitorDashboard confirm
nssm remove ComputerMonitor confirm
```

---

## Scheduled Task (Alternative to Service)

If you don't want to use NSSM, use Windows Task Scheduler:

### Create Scheduled Task
```powershell
# Run as Administrator
$action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\MonitoringTools\computer-monitor\start-all.ps1" `
    -WorkingDirectory "C:\MonitoringTools\computer-monitor"

$trigger = New-ScheduledTaskTrigger -AtStartup

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName "Computer Monitoring System" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Starts computer monitoring and dashboard at system startup"
```

### Manage Scheduled Task
```powershell
# Start task manually
Start-ScheduledTask -TaskName "Computer Monitoring System"

# Check status
Get-ScheduledTask -TaskName "Computer Monitoring System"

# Disable task
Disable-ScheduledTask -TaskName "Computer Monitoring System"

# Remove task
Unregister-ScheduledTask -TaskName "Computer Monitoring System" -Confirm:$false
```

---

## Troubleshooting

### Dashboard won't load
1. Check if Python Flask is running: `Get-Process -Name python*`
2. Check logs: `logs\monitor_YYYY-MM-DD.log`
3. Test port 5000: `Test-NetConnection -ComputerName localhost -Port 5000`

### Monitoring not working
1. Check PowerShell version: `$PSVersionTable.PSVersion` (needs 5.1+)
2. Check CSV exists: `Test-Path connectivity-report.csv`
3. Check permissions: Run PowerShell as Administrator
4. Check network: Test ping manually `Test-Connection COMPUTERNAME`

### Cannot access dashboard from network
1. Check firewall: `Get-NetFirewallRule -DisplayName "*Computer Monitor*"`
2. Check binding: Dashboard must use `0.0.0.0` in config.json
3. Get local IP: `Get-NetIPAddress -AddressFamily IPv4`

### Services won't stay running
1. Check logs in `logs\` folder
2. Verify Python/PowerShell paths in service config
3. Check Windows Event Viewer for service errors

---

## File Structure

```
computer-monitor/
├── Launch-Dashboard.bat      ← DOUBLE-CLICK THIS to start
├── start-all.ps1             ← Starts both services
├── start-monitor.ps1         ← Monitoring service only
├── start-dashboard.ps1       ← Dashboard service only
├── monitor.ps1               ← Main monitoring logic
├── app.py                    ← Flask web server
├── config.json               ← Configuration file
├── connectivity-report.csv   ← Computer list (EDIT THIS)
├── manage-computers.ps1      ← Helper to manage computer list
├── test-system.ps1           ← System validation
├── requirements.txt          ← Python dependencies
├── data/
│   ├── status.json           ← Current status (auto-generated)
│   └── history.json          ← State changes (auto-generated)
├── logs/
│   └── monitor_*.log         ← Daily logs
└── templates/
    └── dashboard.html        ← Dashboard UI
```

---

## Security Considerations

### Network Security
- Dashboard has no authentication (consider adding if needed)
- Restrict firewall to specific IP ranges if sensitive
- Use HTTPS reverse proxy (IIS/nginx) for production

### Access Control
- Run services under dedicated service account (not SYSTEM)
- Grant minimum permissions to CSV file and data folder
- Consider read-only access to CSV for monitoring script

### Monitoring Traffic
- ICMP ping only (no credentials sent)
- No data transmitted to external servers
- All data stored locally in JSON files

---

## Maintenance

### Daily
- Monitor dashboard for offline computers
- No action needed (system runs automatically)

### Weekly
- Check logs for errors: `logs\monitor_*.log`
- Verify CSV list is up-to-date

### Monthly
- Update Python packages: `pip install --upgrade -r requirements.txt`
- Clean old log files (keep last 30 days)
- Review and update computer list

---

## Support Contacts

**System Owner**: Desktop Support Team  
**Technical Contact**: [Your Name/Team]  
**Documentation**: See TECHNICAL-SPEC.txt for detailed architecture

---

## Quick Reference Commands

```powershell
# Start system
.\Launch-Dashboard.bat

# Check if running
Get-Process -Name pwsh,python* | Where-Object {$_.Path -like "*computer-monitor*"}

# Stop system (close all PowerShell windows)
Get-Process -Name pwsh | Where-Object {$_.MainWindowTitle -like "*Computer Monitor*"} | Stop-Process

# View logs
Get-Content .\logs\monitor_*.log -Tail 50

# Update computer list
.\manage-computers.ps1 -Action List
.\manage-computers.ps1 -Action Add -ComputerName "NEW-PC" -Location "5F Main IDF"
.\manage-computers.ps1 -Action Remove -ComputerName "OLD-PC"

# Test connectivity
Test-Connection -ComputerName COMPUTER-NAME -Count 1

# View current status
Get-Content .\data\status.json | ConvertFrom-Json | Format-Table
```
