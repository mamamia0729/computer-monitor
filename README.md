# Computer Monitoring Dashboard

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Python](https://img.shields.io/badge/Python-3.8%2B-green)
![License](https://img.shields.io/badge/license-MIT-green)

A lightweight, web-based real-time monitoring dashboard for Windows computers in a domain environment. Monitor computer availability, track state changes, and remotely restart RDP services—all from a modern, responsive web interface.

## ✨ Features

- **Real-time Monitoring**: Continuous ICMP ping checks every 2 minutes
- **Web Dashboard**: Clean, responsive interface accessible from any device
- **Location Tracking**: Organize computers by IDF/location
- **State Change Detection**: Track when computers go online/offline
- **Last Seen Tracking**: View when offline computers were last online
- **Auto-refresh**: Dashboard updates every 30 seconds
- **Search & Filter**: Quickly find computers by name or status
- **Remote Actions**: Restart RDP services directly from the dashboard
- **No Database Required**: Uses lightweight JSON file storage
- **WinRM Not Required**: Works with standard RPC/SMB in domain environments

## 🚀 Quick Start

### Prerequisites

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or higher (PowerShell 7.x recommended)
- Python 3.8 or higher
- Administrative privileges for monitoring services
- Network access to target computers (ICMP, port 445)

### Installation

1. **Clone the repository**
   ```powershell
   git clone https://github.com/mamamia0729/computer-monitor.git
   cd computer-monitor
   ```

2. **Install Python dependencies**
   ```powershell
   pip install -r requirements.txt
   ```

3. **Configure your computer list**
   
   Edit `connectivity-report.csv` with your computers:
   ```csv
   ComputerName,Location,Status,TestTime
   COMPUTER-01,5F Main IDF,Online,2025-11-25 03:24:00
   COMPUTER-02,6F NE,Online,2025-11-25 03:24:00
   ```

4. **Launch the system**
   
   **Option 1 - Double-click launcher** (easiest):
   ```
   Double-click: Launch-Dashboard.bat
   ```
   
   **Option 2 - PowerShell**:
   ```powershell
   .\start-all-protected.ps1
   ```

5. **Open dashboard**
   
   Navigate to: `http://localhost:5000`
   
   For network access: `http://YOUR-IP:5000`

## 📁 Project Structure

```
computer-monitor/
├── README.md                      # This file
├── LICENSE                        # MIT License
├── requirements.txt               # Python dependencies
├── config.json                    # Configuration settings
├── connectivity-report.csv        # Computer list (edit this)
│
├── Core Scripts
├── monitor.ps1                    # Main monitoring logic
├── app.py                         # Flask web server
│
├── Startup Scripts
├── Launch-Dashboard.bat           # Easy double-click launcher
├── Launch-Dashboard-Hidden.vbs    # Silent background launcher
├── start-all.ps1                  # Start both services
├── start-all-protected.ps1        # Protected start with warnings
├── start-monitor.ps1              # Start monitoring only
├── start-dashboard.ps1            # Start dashboard only
├── Stop-Dashboard.bat             # Stop all services
├── Stop-Dashboard.ps1             # Stop script logic
│
├── scripts/                       # Helper scripts
│   ├── manage-computers.ps1       # Computer list management
│   ├── restart-rdp-remote.ps1     # RDP service restart logic
│   └── test-system.ps1            # System validation
│
├── templates/                     # HTML templates
│   └── dashboard.html             # Dashboard UI
│
├── data/                          # Data files (auto-generated)
│   ├── status.json                # Current computer status
│   └── history.json               # State change history
│
├── logs/                          # Log files (auto-generated)
│   └── monitor_*.log              # Daily logs
│
└── docs/                          # Documentation
    ├── DEPLOYMENT-GUIDE.md        # Full deployment instructions
    ├── TECHNICAL-SPEC.txt         # Technical architecture
    ├── DEMO-GUIDE.md              # Demo presentation guide
    ├── DEMO-CHEATSHEET.txt        # Quick reference
    └── RESTART-RDP-FEATURE.md     # RDP restart feature docs
```

## 🎯 Usage

### Starting the System

**Daily Use (Recommended)**:
```
Double-click: Launch-Dashboard.bat
```
This launches both monitoring and dashboard with "DO NOT CLOSE" warnings in minimized windows.

**Hidden Mode** (No windows):
```
Double-click: Launch-Dashboard-Hidden.vbs
```
Runs completely in background with no visible windows.

### Stopping the System

```
Double-click: Stop-Dashboard.bat
```

Or close the PowerShell windows from the taskbar.

### Using the Dashboard

1. **View Status**: Dashboard shows all computers with online/offline status
2. **Filter**: Click stat cards (Total/Online/Offline) to filter the list
3. **Search**: Type in the search box to find specific computers
4. **Sort**: Click column headers to sort
5. **Restart RDP**: Click "Restart RDP" button to remotely restart RDP services

### Managing Computer List

```powershell
# View current list
.\scripts\manage-computers.ps1 -Action List

# Add a computer
.\scripts\manage-computers.ps1 -Action Add -ComputerName "NEW-PC" -Location "5F Main IDF"

# Remove a computer
.\scripts\manage-computers.ps1 -Action Remove -ComputerName "OLD-PC"

# Import new list from CSV
.\scripts\manage-computers.ps1 -Action Import -ImportFile "newlist.csv"
```

## ⚙️ Configuration

Edit `config.json` to customize settings:

```json
{
    "csvPath": "connectivity-report.csv",
    "statusFile": "data/status.json",
    "historyFile": "data/history.json",
    "logPath": "logs",
    "monitoringInterval": 120,
    "maxParallelPings": 20,
    "pingTimeout": 2,
    "dashboardSettings": {
        "host": "0.0.0.0",
        "port": 5000,
        "refreshIntervalSeconds": 30
    }
}
```

## 🔧 Advanced Deployment

### Running as Windows Service (24/7 Operation)

See [docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md) for complete instructions.

### Network Access Configuration

**Open firewall** (Administrator PowerShell):
```powershell
New-NetFirewallRule -DisplayName "Computer Monitor Dashboard" `
    -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
```

## 🛠️ Troubleshooting

### Dashboard won't load
- Check if Flask is running: `Get-Process python*`
- Check logs: `Get-Content .\logs\monitor_*.log -Tail 50`
- Test port: `Test-NetConnection -ComputerName localhost -Port 5000`

### Monitoring not working
- Verify PowerShell version: `$PSVersionTable.PSVersion`
- Check CSV exists: `Test-Path connectivity-report.csv`
- Test connectivity: `Test-Connection COMPUTER-NAME`

See [docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md) for more troubleshooting tips.

## 📊 Technical Details

- **Backend**: PowerShell for monitoring, Python Flask for web server
- **Frontend**: HTML/CSS/JavaScript with Bootstrap 5
- **Data Storage**: JSON files (no database required)
- **Monitoring Method**: ICMP ping via `Test-Connection`
- **Service Control**: Remote service restart via `sc.exe` (no WinRM)
- **Parallel Processing**: PowerShell `ForEach-Object -Parallel`
- **Compatible**: PowerShell 5.1+ and 7.x

## 🔒 Security Considerations

- **No Authentication**: Dashboard has no login by default
- **Admin Required**: Restarting services requires admin rights on target computers
- **RDP Disconnection**: Restarting RDP services disconnects active sessions
- **Audit Trail**: All actions logged in Windows Event Viewer and application logs

## 📝 Documentation

- **[FEATURE-ARCHITECTURE.md](docs/FEATURE-ARCHITECTURE.md)** - Detailed component breakdowns for all features
- **[DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)** - Complete deployment instructions
- **[TECHNICAL-SPEC.txt](docs/TECHNICAL-SPEC.txt)** - Technical architecture
- **[DEMO-GUIDE.md](docs/DEMO-GUIDE.md)** - Presentation guide
- **[RESTART-RDP-FEATURE.md](docs/RESTART-RDP-FEATURE.md)** - RDP restart feature docs

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built for IT operations teams managing large Windows computer fleets. Designed to work without WinRM in domain-joined environments.

## 👨‍💻 Author

Author: Thinh Le

---

**Made with ❤️ for Desktop Support Teams**
