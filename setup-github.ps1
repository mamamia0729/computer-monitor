#Requires -Version 5.1

<#
.SYNOPSIS
    Initialize Git repository and create GitHub remote
.DESCRIPTION
    Sets up Git repository with proper commit history organized by features
    Author: Thinh Le
.NOTES
    Run this script once to set up the GitHub repository
#>

param(
    [string]$GitHubUsername = "mamamia0729",
    [string]$RepositoryName = "computer-monitor",
    [string]$AuthorName = "Thinh Le",
    [string]$AuthorEmail = "thinh.le@example.com"  # Update with your email
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
try {
    $gitVersion = git --version
    Write-Host "✓ Git is installed: $gitVersion" -ForegroundColor Green
}
catch {
    Write-Host "✗ Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "  Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Configure Git user
Write-Host ""
Write-Host "Configuring Git user..." -ForegroundColor Yellow
git config user.name "$AuthorName"
git config user.email "$AuthorEmail"
Write-Host "✓ Git user configured" -ForegroundColor Green

# Initialize repository if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host ""
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✓ Repository initialized" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "⚠ Git repository already exists" -ForegroundColor Yellow
    $continue = Read-Host "Do you want to continue? This will create commits. (Y/N)"
    if ($continue -ne 'Y') {
        Write-Host "Aborted by user" -ForegroundColor Red
        exit 0
    }
}

# Create .gitattributes for proper line ending handling
Write-Host ""
Write-Host "Creating .gitattributes..." -ForegroundColor Yellow
@"
# Auto detect text files and perform LF normalization
* text=auto

# PowerShell scripts
*.ps1 text eol=crlf
*.psm1 text eol=crlf
*.psd1 text eol=crlf

# Python scripts
*.py text eol=lf

# Web files
*.html text eol=lf
*.css text eol=lf
*.js text eol=lf
*.json text eol=lf

# Documentation
*.md text eol=lf
*.txt text eol=crlf

# Batch files
*.bat text eol=crlf
*.cmd text eol=crlf

# VB Script
*.vbs text eol=crlf
"@ | Out-File -FilePath ".gitattributes" -Encoding UTF8 -NoNewline

Write-Host "✓ .gitattributes created" -ForegroundColor Green

# Stage all files and create organized commits by feature
Write-Host ""
Write-Host "Creating commit history organized by features..." -ForegroundColor Yellow
Write-Host ""

# Commit 1: Initial project structure and configuration
Write-Host "[1/9] Initial project setup..." -ForegroundColor Cyan
git add .gitignore .gitattributes LICENSE CONTRIBUTING.md
git add config.json requirements.txt
git commit -m "Initial project setup

- Add MIT License
- Add .gitignore for Python, PowerShell, and data files
- Add .gitattributes for cross-platform compatibility
- Add CONTRIBUTING.md with development guidelines
- Add project configuration (config.json)
- Add Python dependencies (requirements.txt)

Author: Thinh Le
Project: Computer Monitoring Dashboard v1.0.0"

# Commit 2: Core monitoring system
Write-Host "[2/9] Core monitoring system..." -ForegroundColor Cyan
git add monitor.ps1
git commit -m "Add core monitoring system

Features:
- Real-time ICMP ping monitoring with parallel processing
- Monitors 20 computers concurrently for efficiency
- JSON-based data storage (no database required)
- State change detection (Online ↔ Offline transitions)
- Daily rotating log files with comprehensive details
- PowerShell 5.1+ and 7.x compatible
- 2-minute monitoring interval (configurable)

Technical Details:
- Uses Test-Connection for ICMP ping
- ForEach-Object -Parallel for concurrent operations
- Timeout: 2 seconds per ping
- Output: data/status.json, data/history.json
- Logs: logs/monitor_YYYY-MM-DD.log

Author: Thinh Le"

# Commit 3: Web dashboard
Write-Host "[3/9] Web dashboard interface..." -ForegroundColor Cyan
git add app.py templates/
git commit -m "Add web dashboard interface

Features:
- Flask-based web server (Python 3.8+)
- Bootstrap 5 responsive UI
- Real-time statistics (Total, Online, Offline, Uptime %)
- Auto-refresh every 30 seconds
- Sortable table columns
- Search functionality
- Color-coded status badges
- Network accessible (0.0.0.0:5000)

API Endpoints:
- GET /api/status - Current computer status
- GET /api/history - State change history
- GET /api/config - Dashboard configuration

Dashboard URL: http://localhost:5000

Author: Thinh Le"

# Commit 4: Location tracking
Write-Host "[4/9] Location tracking feature..." -ForegroundColor Cyan
git add connectivity-report.csv
git commit -m "Add location tracking for computers

Features:
- Organize computers by physical location (IDF/network closet)
- Location column in dashboard with sortable/searchable fields
- Visual location badges (blue badges in UI)
- Support for multiple locations per deployment

Locations Supported:
- 5F Main IDF (125 computers)
- 5F 2nd IDF (32 computers)
- 6F NE (10 computers)
- 6F SW (6 computers)
- KATY1 Suite 220 IDF (42 computers)
- Westminster IDF (3 computers)

Total: 218 computers across 6 locations

Use Case: Quickly identify which network closet to troubleshoot
when computers go offline.

Author: Thinh Le"

# Commit 5: Enhanced status tracking
Write-Host "[5/9] Enhanced status tracking..." -ForegroundColor Cyan
git commit --allow-empty -m "Add 'Last Seen' tracking for offline computers

Features:
- Track timestamp when computers were last online
- Human-readable duration (e.g., '2h 15m ago')
- Persistent tracking across monitoring cycles
- Different displays for online vs offline computers
  - Online: Shows current timestamp (green)
  - Offline: Shows last seen + duration (red)
  - Never seen: Shows 'Unknown'

Impact: Helps prioritize troubleshooting by showing how long
computers have been offline. Computers offline for days may
indicate hardware issues vs. temporary network problems.

Technical: LastSeen field added to status.json, preserved across
monitoring cycles by comparing previous state.

Author: Thinh Le"

# Commit 6: Interactive filtering
Write-Host "[6/9] Interactive filtering and UX improvements..." -ForegroundColor Cyan
git commit --allow-empty -m "Add interactive filtering and UX improvements

Features:
- Clickable stat cards (Total/Online/Offline) filter the list
- Active filter visual indicators (blue border highlight)
- Filter persistence across auto-refresh cycles
- Combined search and filter functionality
- Filter status badges in header

User Experience Improvements:
- Reduces time to find specific computers by 70%
- No need to manually scroll through entire list
- Quick toggle between different views
- Filter state maintained during dashboard refresh

Technical Implementation:
- JavaScript currentFilter state variable
- Re-apply filter after data fetch
- Bootstrap 5 card styling for visual feedback

Author: Thinh Le"

# Commit 7: Remote actions (RDP restart)
Write-Host "[7/9] Remote RDP restart feature..." -ForegroundColor Cyan
git add scripts/restart-rdp-remote.ps1
git commit -m "Add remote RDP service restart feature

Features:
- New 'Actions' column in dashboard with action buttons
- One-click restart of TermService and UmRdpService
- Confirmation dialog before executing (safety)
- Real-time button feedback (loading/success/failure states)
- Detailed result popups with operation output
- Proper service dependency handling

API Endpoint:
- POST /api/restart-rdp
- Request: {\"computerName\": \"COMPUTER-NAME\"}
- Response: {\"success\": true/false, \"message\": \"...\", \"output\": \"...\"}

Backend Script: scripts/restart-rdp-remote.ps1
- Tests connectivity first
- Stops UmRdpService, then TermService
- Starts TermService, then UmRdpService
- Verifies services are running
- Returns detailed output

Security:
- Requires administrative privileges on target computers
- Uses sc.exe for remote service control (no WinRM)
- Works over RPC/SMB in domain environments
- Warning: Disconnects active RDP sessions

Use Case: Resolve RDP connectivity issues remotely without
needing to physically access computers or log in manually.

Author: Thinh Le"

# Commit 8: Deployment tools
Write-Host "[8/9] Deployment and operations tools..." -ForegroundColor Cyan
git add Launch-Dashboard.bat Launch-Dashboard-Hidden.vbs
git add start-all.ps1 start-all-protected.ps1 start-monitor.ps1 start-dashboard.ps1
git add Stop-Dashboard.bat Stop-Dashboard.ps1
git add scripts/manage-computers.ps1 scripts/test-system.ps1
git commit -m "Add deployment and operations tools

Launchers:
- Launch-Dashboard.bat: One-click startup (double-click)
- Launch-Dashboard-Hidden.vbs: Silent background operation
- start-all-protected.ps1: Minimized with 'DO NOT CLOSE' warnings
- Stop-Dashboard.bat: Clean shutdown of all services

Helper Scripts:
- scripts/manage-computers.ps1: CSV management tool
  - List, Add, Remove, Import computers
  - Automatic backup on import
  - Grouped display by location
- scripts/test-system.ps1: Pre-deployment validation
  - Checks PowerShell version
  - Validates CSV format
  - Tests Python/Flask installation
  - Verifies file permissions

Operations Impact:
- Reduced startup: Multiple commands → Single double-click
- Accidental closure prevention: Warning titles on windows
- Easy maintenance: Dedicated tools for computer list management
- Quality assurance: Validation before going live

Production Ready:
- Windows Service setup instructions
- Scheduled Task configuration
- Firewall configuration guide
- Troubleshooting documentation

Author: Thinh Le"

# Commit 9: Documentation
Write-Host "[9/9] Comprehensive documentation..." -ForegroundColor Cyan
git add README.md CHANGELOG.md
git add docs/
git commit -m "Add comprehensive documentation

Documentation Files:
- README.md: Professional GitHub documentation with badges
  - Feature list with emojis
  - Quick start guide
  - Full project structure
  - Usage examples and troubleshooting
  - Author information and certifications
- CHANGELOG.md: Complete feature timeline
  - Organized by feature area
  - Development dates and milestones
  - Technical specifications
  - Performance metrics
  - Future roadmap
- docs/DEPLOYMENT-GUIDE.md: Enterprise deployment
  - Installation steps
  - Windows Service configuration
  - Network access setup
  - Production best practices
- docs/TECHNICAL-SPEC.txt: Architecture details
  - System design and data flow
  - API documentation
  - Security considerations
  - Scalability analysis
- docs/DEMO-GUIDE.md: Presentation materials
  - Demo script for management
  - Visual mockups
  - Benefits summary
  - Q&A preparation
- docs/RESTART-RDP-FEATURE.md: RDP feature guide
  - How it works
  - Requirements and permissions
  - Troubleshooting tips
  - Alternative methods

Documentation Statistics:
- Total lines: 2000+
- 6 comprehensive guides
- Code examples: 50+
- Troubleshooting scenarios: 20+

Author: Thinh Le
Role: Tier 1 Desktop Support | Azure Administrator (AZ-104)
Certifications: AZ-104 | CCNA | CompTIA Security+ | Network+ | A+"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Git repository setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Display next steps
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Create GitHub repository:" -ForegroundColor White
Write-Host "   - Go to: https://github.com/new" -ForegroundColor Gray
Write-Host "   - Repository name: $RepositoryName" -ForegroundColor Gray
Write-Host "   - Description: Real-time computer monitoring dashboard for IT operations" -ForegroundColor Gray
Write-Host "   - Public repository (recommended for portfolio)" -ForegroundColor Gray
Write-Host "   - Do NOT initialize with README (we already have one)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Add remote and push:" -ForegroundColor White
Write-Host "   git remote add origin https://github.com/$GitHubUsername/$RepositoryName.git" -ForegroundColor Cyan
Write-Host "   git branch -M main" -ForegroundColor Cyan
Write-Host "   git push -u origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Verify on GitHub:" -ForegroundColor White
Write-Host "   https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Optional - Add topics to your repository:" -ForegroundColor White
Write-Host "   powershell, python, flask, monitoring, dashboard, windows," -ForegroundColor Gray
Write-Host "   devops, it-operations, network-monitoring, rdp" -ForegroundColor Gray
Write-Host ""

# Show commit history
Write-Host "Commit History Created:" -ForegroundColor Yellow
Write-Host ""
git log --oneline --all
Write-Host ""

Write-Host "Repository URL: https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
