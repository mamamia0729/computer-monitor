========================================
Computer Monitoring Dashboard
========================================

QUICK START:
1. Double-click "Launch-Dashboard.bat"
2. Open browser to http://localhost:5000
3. Done!

For network access, use: http://10.200.10.37:5000

To stop: Close both PowerShell windows

========================================
DEPLOYMENT TO SERVER TEAM:
See "DEPLOYMENT-GUIDE.md" for full instructions

Quick checklist for server team:
1. Copy entire "computer-monitor" folder to server
2. Run: pip install -r requirements.txt
3. Edit connectivity-report.csv with computer list
4. Test: .\test-system.ps1
5. Launch: .\Launch-Dashboard.bat

For production (24/7 operation):
- Use Windows Service (see DEPLOYMENT-GUIDE.md)
- Use NSSM or Task Scheduler

========================================
FILES:
- Launch-Dashboard.bat    <- START HERE (double-click)
- DEPLOYMENT-GUIDE.md     <- Full deployment instructions
- TECHNICAL-SPEC.txt      <- Technical documentation
- DEMO-GUIDE.md          <- Demo presentation guide

========================================
