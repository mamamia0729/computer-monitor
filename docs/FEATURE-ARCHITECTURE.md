# Feature Architecture Documentation

## Purpose
This document provides detailed technical breakdowns of every major feature in the Computer Monitoring Dashboard. Each feature is explained with its backend, frontend, and integration components for future reference and maintenance.

---

## 1. Real-Time Computer Monitoring

### Overview
Continuously monitors computer availability by pinging devices every 2 minutes and tracking their online/offline state.

### Components

#### 1.1 PowerShell Monitoring Script (monitor.ps1)
- **Main monitoring loop** - Runs infinitely with configurable intervals
- **CSV import function** - Reads `connectivity-report.csv` with computer list
- **Parallel ping execution** - Uses `ForEach-Object -Parallel` for concurrent pings (up to 20 simultaneous)
- **Test-Connection cmdlet** - Performs ICMP ping with 2-second timeout
- **State comparison logic** - Compares current status with previous status to detect changes
- **JSON export** - Writes results to `data/status.json` with timestamps
- **Logging system** - Writes daily logs to `logs/monitor_YYYY-MM-DD.log`
- **Error handling** - Try-catch blocks for network failures and CSV issues

#### 1.2 Configuration File (config.json)
- **monitoringInterval** - Seconds between monitoring cycles (default: 120)
- **maxParallelPings** - Maximum concurrent ping operations (default: 20)
- **pingTimeout** - Seconds to wait for ping response (default: 2)
- **csvPath** - Location of computer list file
- **statusFile** - Output path for current status JSON
- **logPath** - Directory for log files

#### 1.3 Data Storage (data/status.json)
- **Computers array** - List of all monitored computers
- **Per-computer properties**:
  - `computerName` - Device hostname
  - `location` - Physical location (IDF/room)
  - `status` - "Online" or "Offline"
  - `lastSeen` - ISO timestamp of last successful ping
  - `testTime` - ISO timestamp of last monitoring check
- **Metadata**:
  - `lastUpdate` - When the file was last written
  - `totalComputers` - Total count in monitoring list

#### 1.4 Startup Script (start-monitor.ps1)
- **PowerShell 7 detection** - Checks if pwsh.exe is available
- **Fallback to PowerShell 5.1** - Uses powershell.exe if pwsh not found
- **Process launch** - Starts monitor.ps1 in new window with "DO NOT CLOSE" warning
- **Window positioning** - Minimizes window to taskbar

---

## 2. Web Dashboard Interface

### Overview
Provides a responsive web interface accessible from any device on the network to view real-time computer status.

### Components

#### 2.1 Flask Backend (app.py)
- **Flask application initialization** - Creates web server instance
- **Network binding** - Listens on `0.0.0.0:5000` for network access
- **Route: `/`** - Serves main dashboard HTML template
- **Route: `/api/status`** - Returns JSON data from `data/status.json`
- **Route: `/api/history`** - Returns JSON data from `data/history.json`
- **Error handlers** - Returns 404 for missing files, 500 for server errors
- **File reading** - Loads JSON files on each API request for real-time data
- **CORS handling** - Allows cross-origin requests for API endpoints

#### 2.2 Frontend HTML (templates/dashboard.html)
- **Bootstrap 5 framework** - Responsive CSS via CDN
- **Summary statistics cards** - Total, Online, Offline, Success % displayed at top
- **Interactive filters** - Clicking stat cards filters the table
- **Search functionality** - Real-time search as you type
- **Sortable table** - Click column headers to sort by name, location, status, or last seen
- **Status badges** - Color-coded pills (green=online, red=offline)
- **Last seen display** - Shows relative time (e.g., "2 minutes ago")
- **Location grouping** - Groups computers by IDF/location
- **Responsive design** - Works on desktop, tablet, and mobile

#### 2.3 JavaScript Auto-Refresh Logic
- **setInterval function** - Calls `/api/status` every 30 seconds
- **Fetch API** - Retrieves updated JSON data
- **DOM manipulation** - Updates table rows without full page reload
- **Preserve filters** - Maintains current search/filter state during refresh
- **Error handling** - Shows notification if API call fails
- **Loading indicator** - Visual feedback during data refresh
- **Timestamp update** - Shows "Last updated: X seconds ago"

#### 2.4 Startup Script (start-dashboard.ps1)
- **Python detection** - Checks for python.exe in PATH
- **Virtual environment check** - Verifies dependencies are installed
- **Flask launch** - Starts `app.py` with network binding
- **Port configuration** - Uses port 5000 by default
- **Process monitoring** - Keeps Flask running in foreground window
- **Window warning** - Shows "DO NOT CLOSE" message

---

## 3. State Change Tracking

### Overview
Detects and records when computers transition between online and offline states for historical analysis.

### Components

#### 3.1 State Comparison Logic (monitor.ps1)
- **Previous state cache** - Stores last known status for each computer
- **Comparison function** - Compares current ping result with cached status
- **Change detection** - Identifies Online→Offline and Offline→Online transitions
- **Timestamp recording** - Records exact time of state change
- **Event logging** - Writes state changes to log file and history JSON

#### 3.2 History Storage (data/history.json)
- **Events array** - Chronological list of state changes
- **Per-event properties**:
  - `computerName` - Device that changed state
  - `previousStatus` - Status before change
  - `newStatus` - Status after change
  - `timestamp` - ISO datetime of change
  - `location` - Physical location of device
- **Retention policy** - Keeps last 100 events (configurable)
- **Circular buffer** - Oldest events are removed when limit reached

#### 3.3 API Endpoint (app.py: /api/history)
- **JSON file read** - Loads `data/history.json`
- **Sorting** - Returns events in reverse chronological order (newest first)
- **Filtering options** - Optional query parameters for date range or computer name
- **Response format** - Returns array of event objects

---

## 4. Last Seen Tracking

### Overview
Tracks when offline computers were last successfully pinged to help identify stale/dead systems.

### Components

#### 4.1 Last Seen Update Logic (monitor.ps1)
- **Successful ping handler** - Updates `lastSeen` timestamp on successful ping
- **Offline ping handler** - Preserves previous `lastSeen` value when ping fails
- **Initial discovery** - Sets `lastSeen` to first successful ping time for new computers
- **Persistence** - Writes `lastSeen` to `data/status.json` for long-term tracking

#### 4.2 Frontend Display (dashboard.html)
- **Relative time calculation** - Converts timestamp to "X minutes/hours/days ago"
- **JavaScript date library** - Uses built-in Date object for calculations
- **Conditional display** - Only shows for offline computers
- **Color coding** - Red text for computers offline >24 hours
- **Tooltip** - Hover to see exact timestamp

#### 4.3 Sorting and Filtering
- **Sort by last seen** - Click "Last Seen" column header
- **Filter by staleness** - Potential filter: "Offline >24 hours"
- **Search integration** - Last seen time included in search index

---

## 5. Location-Based Organization

### Overview
Organizes computers by physical location (IDF rooms, floors, buildings) for easier management.

### Components

#### 5.1 CSV Data Model (connectivity-report.csv)
- **ComputerName column** - Device hostname
- **Location column** - Free-form text describing physical location
- **Status column** - Manually updated or auto-populated
- **TestTime column** - Last monitoring check timestamp

#### 5.2 Location Grouping (dashboard.html)
- **JavaScript grouping logic** - Groups computers by location field
- **Collapsible sections** - Click to expand/collapse location groups
- **Per-location stats** - Shows online/offline count per location
- **Location filter** - Filter table to show only specific locations

#### 5.3 Computer Management Script (scripts/manage-computers.ps1)
- **Add computer** - Adds new computer with name and location to CSV
- **Remove computer** - Removes computer from CSV
- **Update location** - Changes location field for existing computer
- **Import CSV** - Bulk import from external CSV file
- **Export CSV** - Generates formatted CSV for sharing
- **Validation** - Checks for duplicate names, missing fields

---

## 6. Remote RDP Service Restart

### Overview
Allows IT staff to remotely restart RDP services (TermService, UmRdpService) directly from the dashboard without using RDP or PowerShell.

### Components

#### 6.1 Backend API Endpoint (app.py: /api/restart-rdp)
- **POST method** - Accepts JSON payload with computer name
- **Request validation** - Verifies computer name is provided
- **PowerShell script execution** - Calls `scripts/restart-rdp-remote.ps1` with computer name parameter
- **subprocess module** - Executes PowerShell with captured output
- **Timeout handling** - Kills process after 60 seconds if hung
- **Response formatting** - Returns JSON with success/failure status
- **Error handling** - Catches PowerShell errors and returns meaningful messages
- **Logging** - Records all restart attempts in Flask logs

#### 6.2 PowerShell Script (scripts/restart-rdp-remote.ps1)
- **Parameter: ComputerName** - Target computer hostname
- **Connectivity test** - Pings computer before attempting restart
- **Service stop order**:
  1. Stop UmRdpService first (user-mode RDP service)
  2. Stop TermService second (Terminal Services)
- **Wait period** - 5-second delay between stop and start
- **Service start order**:
  1. Start TermService first
  2. Start UmRdpService second
- **Status verification** - Queries service status after restart to confirm success
- **sc.exe usage** - Uses `sc.exe \\computerName stop/start service` for remote control
- **Error handling** - Captures exit codes and error messages
- **Output formatting** - Returns structured output for API parsing
- **Non-interactive mode** - Runs silently without user prompts for API calls
- **Admin privilege requirement** - Requires admin rights on target computer
- **RPC/SMB protocol** - Uses standard Windows remote management (no WinRM needed)

#### 6.3 Frontend JavaScript (dashboard.html)
- **Action button** - "Restart RDP" button in Actions column for each computer row
- **Button states**:
  - Default: Orange button with text "Restart RDP"
  - Clicking: Shows confirmation dialog "Restart RDP services on COMPUTER-NAME?"
  - Processing: Button changes to "Restarting..." with spinning icon, disabled
  - Success: Green button with checkmark icon and "Success" text
  - Failure: Red button with X icon and "Failed" text
- **Confirmation dialog** - Uses browser's `confirm()` for user verification
- **AJAX request** - Posts to `/api/restart-rdp` with computer name
- **Response handling**:
  - Success: Shows success state for 3 seconds, displays alert with output
  - Failure: Shows failed state for 5 seconds, displays alert with error message
- **Auto-reset** - Button returns to default state after timeout
- **Visual feedback** - Button color changes (orange → yellow → green/red)
- **Loading spinner** - Animated icon during processing
- **Alert boxes** - Displays detailed PowerShell output or error messages
- **Timeout handling** - Shows error if no response after 65 seconds

#### 6.4 Supporting Files
- **Original script reference** - Based on user's existing `Restart-TermService.ps1`
- **Service names**:
  - `TermService` - Windows Terminal Services (Remote Desktop)
  - `UmRdpService` - User Mode Remote Desktop Service
- **Documentation** - Full feature docs in `docs/RESTART-RDP-FEATURE.md`

---

## 7. Search and Filter System

### Overview
Provides instant search and filtering capabilities to quickly find specific computers or groups.

### Components

#### 7.1 Search Bar (dashboard.html)
- **Input field** - Real-time search as you type
- **Event listener** - Triggers on `keyup` event
- **Search scope** - Searches across computer name, location, and status
- **Case-insensitive** - Converts search term to lowercase for matching
- **Highlighting** - Can highlight matching text (optional enhancement)
- **Clear button** - X icon to clear search instantly

#### 7.2 Status Filter Buttons
- **Total button** - Shows all computers (removes filters)
- **Online button** - Filters to show only online computers
- **Offline button** - Filters to show only offline computers
- **Active state** - Highlights currently active filter
- **Combine with search** - Works alongside search functionality

#### 7.3 Filter Logic (JavaScript)
- **Filter function** - Iterates through table rows
- **Display toggle** - Sets `display: none` for hidden rows
- **Row counting** - Updates visible row count
- **Empty state** - Shows "No results" message when no matches
- **Preserve sorting** - Maintains current sort order while filtering

---

## 8. Responsive Table with Sorting

### Overview
Displays computer list in a sortable, responsive table that works on all device sizes.

### Components

#### 8.1 Table Structure (dashboard.html)
- **Columns**:
  - Computer Name - Device hostname
  - Location - Physical location
  - Status - Online/Offline badge
  - Last Seen - Relative timestamp for offline computers
  - Actions - Restart RDP button
- **Bootstrap table classes** - `table`, `table-striped`, `table-hover`
- **Responsive wrapper** - `table-responsive` class for horizontal scroll on mobile
- **Row attributes** - Data attributes for sorting and filtering

#### 8.2 Column Sorting (JavaScript)
- **Clickable headers** - Click column header to sort
- **Sort direction** - Toggles between ascending/descending
- **Sort indicators** - Up/down arrow icons show current sort
- **Sort types**:
  - Alphabetical - For computer name and location
  - Status-based - Online before offline (or vice versa)
  - Chronological - For last seen timestamps
- **Multi-column sort** - Hold Shift for secondary sort (optional)

#### 8.3 Mobile Responsiveness
- **Breakpoints** - Different layouts for phone, tablet, desktop
- **Card view** - Optional card layout for phones instead of table
- **Column collapsing** - Hide less important columns on small screens
- **Touch-friendly** - Large tap targets for mobile users

---

## 9. Logging and Audit Trail

### Overview
Comprehensive logging of all monitoring activity and user actions for troubleshooting and compliance.

### Components

#### 9.1 PowerShell Logging (monitor.ps1)
- **Daily log files** - Named `monitor_YYYY-MM-DD.log`
- **Log levels** - INFO, WARNING, ERROR
- **Logged events**:
  - Monitoring cycle start/end
  - Successful pings
  - Failed pings
  - State changes
  - Configuration loading
  - Errors and exceptions
- **Log rotation** - Keeps 30 days of logs by default
- **Timestamp format** - ISO 8601 with timezone

#### 9.2 Flask Logging (app.py)
- **Console output** - Prints all HTTP requests to terminal
- **API call logging** - Records all `/api/*` requests
- **Error logging** - Full stack traces for exceptions
- **Restart operation logging** - Records computer name, user (if auth added), timestamp, result

#### 9.3 Windows Event Viewer Integration
- **Service restart events** - Logged on target computer when services restart
- **Event IDs**:
  - 7035 - Service started successfully
  - 7036 - Service entered stopped state
  - 7040 - Service start type changed
- **Source** - Service Control Manager
- **Location** - System log on target computer

---

## 10. Configuration Management

### Overview
Centralized configuration file for easy customization without modifying code.

### Components

#### 10.1 Configuration File Structure (config.json)
- **File paths**:
  - `csvPath` - Computer list CSV location
  - `statusFile` - Current status JSON output
  - `historyFile` - State change history JSON
  - `logPath` - Directory for log files
- **Monitoring settings**:
  - `monitoringInterval` - Seconds between checks
  - `maxParallelPings` - Concurrent ping limit
  - `pingTimeout` - Ping timeout seconds
- **Dashboard settings**:
  - `host` - Flask bind address (0.0.0.0 for network access)
  - `port` - Flask port number
  - `refreshIntervalSeconds` - Dashboard auto-refresh interval

#### 10.2 Configuration Loading (monitor.ps1)
- **JSON parsing** - Uses `Get-Content | ConvertFrom-Json`
- **Default values** - Falls back to hardcoded defaults if config missing
- **Validation** - Checks for required fields
- **Error handling** - Graceful failure if config is malformed

#### 10.3 Configuration Loading (app.py)
- **JSON parsing** - Uses `json.load()`
- **Environment variables** - Can override config with env vars
- **Hot reload** - Can reload config without restarting (optional)

---

## 11. Parallel Processing Optimization

### Overview
Uses PowerShell's parallel execution to monitor multiple computers simultaneously for faster checks.

### Components

#### 11.1 ForEach-Object -Parallel (monitor.ps1)
- **Parallel block** - Executes ping operations concurrently
- **ThrottleLimit parameter** - Controls max concurrent operations (default: 20)
- **Thread safety** - Uses thread-safe collection for results
- **Variable passing** - Uses `$using:` scope modifier for outer variables
- **Error isolation** - Errors in one ping don't affect others

#### 11.2 Performance Benefits
- **Speed improvement** - Can ping 100 computers in ~10 seconds instead of 200+ seconds
- **Network efficiency** - Utilizes network bandwidth more effectively
- **Scalability** - Handles 500+ computers without significant slowdown
- **CPU usage** - Minimal CPU overhead due to network-bound operations

---

## 12. Batch Launcher System

### Overview
Provides easy one-click launch options for the entire system without requiring PowerShell knowledge.

### Components

#### 12.1 Batch Launcher (Launch-Dashboard.bat)
- **Starts monitoring** - Calls `start-monitor.ps1`
- **Starts dashboard** - Calls `start-dashboard.ps1`
- **Separate windows** - Opens two PowerShell windows
- **Window titles** - Custom titles with "DO NOT CLOSE" warning
- **Minimized start** - Windows start minimized to taskbar
- **User feedback** - Prints "Starting..." messages

#### 12.2 VBScript Silent Launcher (Launch-Dashboard-Hidden.vbs)
- **Hidden execution** - Runs batch file with `WindowStyle = 0`
- **No console windows** - Completely background execution
- **No UAC prompt** - Runs with current user privileges
- **Task tray icon** - No visible windows at all

#### 12.3 Stop Script (Stop-Dashboard.bat)
- **Process discovery** - Finds PowerShell processes running monitor.ps1 and app.py
- **Graceful shutdown** - Uses `Stop-Process` instead of `Kill`
- **Confirmation prompt** - Optional confirmation before stopping
- **Process cleanup** - Ensures both monitor and dashboard are stopped

---

## 13. Error Handling and Recovery

### Overview
Comprehensive error handling to ensure system continues running despite network issues, file problems, or other failures.

### Components

#### 13.1 PowerShell Error Handling (monitor.ps1)
- **Try-Catch blocks** - Wraps all critical operations
- **Error logging** - Writes detailed error messages to log
- **Continue on error** - Single computer failure doesn't stop monitoring loop
- **Retry logic** - Retries failed operations 3 times before giving up
- **Fallback values** - Uses safe defaults when data is missing

#### 13.2 Flask Error Handling (app.py)
- **404 handler** - Returns friendly message for missing pages
- **500 handler** - Returns error details without exposing stack traces
- **File not found** - Returns empty JSON array if data files missing
- **JSON parse errors** - Returns error message if JSON is malformed
- **API error responses** - Structured JSON errors for all API endpoints

#### 13.3 Frontend Error Handling (dashboard.html)
- **Fetch errors** - Shows notification if API call fails
- **JSON parse errors** - Handles malformed API responses
- **Empty data handling** - Shows "No computers found" message
- **Network timeout** - Shows "Connection lost" warning after timeout
- **Retry mechanism** - Automatically retries failed API calls

---

## 14. Documentation System

### Overview
Comprehensive documentation for users, operators, and developers.

### Components

#### 14.1 Main README (README.md)
- **Quick start guide** - Get up and running in 5 minutes
- **Feature overview** - Summary of capabilities
- **Installation instructions** - Step-by-step setup
- **Usage examples** - Common workflows
- **Troubleshooting** - Common issues and solutions
- **Links to detailed docs** - Points to other documentation files

#### 14.2 Deployment Guide (docs/DEPLOYMENT-GUIDE.md)
- **Windows Service setup** - Run as service for 24/7 operation
- **Firewall configuration** - Open necessary ports
- **Network access** - Allow remote dashboard access
- **Security hardening** - Best practices for production
- **Backup procedures** - How to backup data and config

#### 14.3 Technical Specification (docs/TECHNICAL-SPEC.txt)
- **Architecture diagrams** - System component relationships
- **Data flow** - How data moves through the system
- **File formats** - Detailed CSV and JSON schemas
- **API documentation** - All endpoints with examples
- **Performance specs** - Expected speeds and limits

#### 14.4 Feature Documentation (docs/RESTART-RDP-FEATURE.md)
- **Feature overview** - What it does
- **How it works** - Step-by-step process
- **Component breakdown** - Backend, frontend, script details
- **Requirements** - Permissions, network, environment
- **Troubleshooting** - Common issues specific to feature
- **Usage examples** - Real-world scenarios

#### 14.5 Demo Guide (docs/DEMO-GUIDE.md)
- **Presentation outline** - How to demo the system
- **Key talking points** - What to highlight
- **Common questions** - Anticipated audience questions
- **Setup checklist** - Pre-demo preparation

---

## Component Dependency Map

This shows how the major components interact:

```
CSV File (connectivity-report.csv)
    ↓
PowerShell Monitor (monitor.ps1)
    ↓
JSON Data Files (status.json, history.json)
    ↓
Flask Backend (app.py)
    ↓
REST API Endpoints (/api/status, /api/history, /api/restart-rdp)
    ↓
Frontend JavaScript (dashboard.html)
    ↓
User Interface (Browser)

PowerShell Scripts (restart-rdp-remote.ps1)
    ↑
Flask Backend (app.py)
```

---

## File Reference Guide

| File | Purpose | Type | Called By |
|------|---------|------|-----------|
| `monitor.ps1` | Main monitoring loop | PowerShell | `start-monitor.ps1` |
| `app.py` | Flask web server | Python | `start-dashboard.ps1` |
| `dashboard.html` | Web UI | HTML/JS | Flask (`app.py`) |
| `config.json` | Configuration | JSON | `monitor.ps1`, `app.py` |
| `connectivity-report.csv` | Computer list | CSV | `monitor.ps1` |
| `status.json` | Current status | JSON | `monitor.ps1` (write), `app.py` (read) |
| `history.json` | State changes | JSON | `monitor.ps1` (write), `app.py` (read) |
| `restart-rdp-remote.ps1` | RDP restart | PowerShell | `app.py` |
| `manage-computers.ps1` | Computer management | PowerShell | User/Admin |
| `start-monitor.ps1` | Monitoring launcher | PowerShell | `start-all.ps1`, User |
| `start-dashboard.ps1` | Dashboard launcher | PowerShell | `start-all.ps1`, User |
| `start-all.ps1` | Combined launcher | PowerShell | User |
| `Launch-Dashboard.bat` | Easy launcher | Batch | User |
| `Launch-Dashboard-Hidden.vbs` | Silent launcher | VBScript | User |
| `Stop-Dashboard.bat` | System shutdown | Batch | User |

---

## Future Enhancement Ideas

Based on the current architecture, here are potential additions:

1. **Authentication System**
   - Add user login to Flask backend
   - Role-based access control (viewer vs admin)
   - Active Directory integration for SSO

2. **Advanced Filtering**
   - Custom filter builder (status + location + last seen)
   - Saved filter presets
   - Export filtered results to CSV

3. **Bulk Operations**
   - Select multiple computers (checkboxes)
   - Bulk restart RDP services
   - Bulk computer management (add/remove/update)

4. **Alerting System**
   - Email notifications when computers go offline
   - Webhook integration (Teams, Slack)
   - SMS alerts for critical systems

5. **Historical Analytics**
   - Uptime percentage charts
   - Outage duration reports
   - Trend analysis (which computers fail most often)

6. **Additional Actions**
   - Restart computer remotely
   - Restart print spooler service
   - Wake-on-LAN for offline computers
   - Remote shutdown/logoff

7. **Dashboard Enhancements**
   - Dark mode toggle
   - Customizable refresh intervals per user
   - Dashboard widgets (charts, graphs)
   - Export reports to PDF

8. **Performance Improvements**
   - WebSocket for real-time updates (no polling)
   - Redis caching for faster API responses
   - Database backend for larger deployments

---

## Maintenance Guidelines

### Regular Tasks
- **Weekly**: Review logs for errors
- **Monthly**: Verify computer list is up to date
- **Quarterly**: Update Python and PowerShell dependencies
- **Annually**: Review and update documentation

### Troubleshooting Checklist
1. Check if both monitor and dashboard processes are running
2. Verify JSON files exist and are not corrupted
3. Check logs for error messages
4. Test network connectivity to target computers
5. Verify PowerShell and Python versions
6. Check Windows Firewall rules

### Backup Strategy
- **Config files**: Backup `config.json` before changes
- **Computer list**: Backup `connectivity-report.csv` weekly
- **Historical data**: Backup `data/*.json` files monthly
- **Logs**: Archive old logs quarterly

---

**Document Version**: 1.0
**Last Updated**: 2025-11-25
**Author**: Thinh Le
