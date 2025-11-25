# Restart RDP Service Feature

## Overview
The dashboard now includes an "Actions" column with a "Restart RDP" button for each computer. This allows you to remotely restart the Remote Desktop Services (TermService) and UmRdpService on any computer directly from the web interface.

## How It Works

### User Interface
- New "Actions" column appears on the right side of the computer table
- Orange "Restart RDP" button for each computer
- Clicking the button shows a confirmation dialog
- Button shows real-time status:
  - **Restarting...** (spinning icon) - Operation in progress
  - **Success** (green checkmark) - Service restarted successfully
  - **Failed** (red X) - Operation failed
- Button automatically resets after 3-5 seconds

### What Happens When You Click
1. **Confirmation**: Dialog asks for confirmation
2. **API Call**: Browser sends request to Flask backend
3. **PowerShell Execution**: Flask calls `restart-rdp-remote.ps1`
4. **Service Restart**: Script performs these steps:
   - Tests connectivity to target computer
   - Stops UmRdpService
   - Stops TermService
   - Starts TermService
   - Starts UmRdpService
   - Verifies services are running
5. **Result Display**: Shows success/failure message with details

### Technical Details

#### Backend (Flask)
- **Endpoint**: `/api/restart-rdp` (POST)
- **Request**: `{"computerName": "COMPUTER-NAME"}`
- **Response**: `{"success": true/false, "message": "...", "output": "..."}`

#### PowerShell Script
- **Location**: `restart-rdp-remote.ps1`
- **Usage**: `.\restart-rdp-remote.ps1 -ComputerName "COMPUTER-NAME"`
- **Requirements**: 
  - Administrative privileges on target computer
  - Network connectivity
  - RPC/SMB access (WinRM not required)

## Requirements

### Permissions
You need **administrative privileges** on target computers to restart services. This typically means:
- Your account is in the local Administrators group on the target computer
- Or your account has been delegated service control permissions

### Network Requirements
- Target computer must be online
- Port 445 (SMB) must be accessible
- No firewall blocking RPC traffic

### Domain Environment
Since you're in a domain environment:
- Domain admin accounts can restart services on any domain computer
- Service accounts with proper delegation can also work
- Standard user accounts will fail unless explicitly granted permissions

## Security Considerations

### Important Warnings
⚠️ **Restarting RDP services will disconnect active RDP sessions**
- Users connected via Remote Desktop will be disconnected
- Their work may be lost if not saved
- Use with caution during business hours

### Access Control
The dashboard has **no authentication** by default. This means:
- Anyone who can access the dashboard can restart services
- Consider adding authentication if this is a concern
- Alternatively, restrict dashboard access via firewall rules

### Audit Trail
All restart operations are logged:
- Flask logs show API requests
- PowerShell script output shows operation details
- Windows Event Viewer on target computers logs service changes

## Troubleshooting

### Button Shows "Failed"
**Possible causes:**
1. Computer is offline - Check if computer is responding to ping
2. No administrative access - Verify your credentials have admin rights
3. Firewall blocking - Check Windows Firewall on target computer
4. Services already stopped - Check service status manually

**How to diagnose:**
- Check the error message in the popup alert
- Look at Flask terminal window for detailed error output
- Try running the script manually:
  ```powershell
  .\restart-rdp-remote.ps1 -ComputerName "COMPUTER-NAME"
  ```

### Button Shows "Error"
**Possible causes:**
1. Flask server issue - Check if Flask is still running
2. PowerShell script missing - Verify `restart-rdp-remote.ps1` exists
3. Network timeout - Operation took longer than 60 seconds

### Services Don't Start After Restart
**If TermService won't start:**
- Check Event Viewer on target computer (Event ID 7000 or 7001)
- Common causes: Corrupted registry keys, conflicting services
- May need to manually investigate on the target computer

### Permission Denied Errors
**If you get "Access Denied":**
1. Run this command to verify admin access:
   ```powershell
   sc.exe \\COMPUTER-NAME query TermService
   ```
2. If that fails, you need to:
   - Use a domain admin account
   - Or be added to local Administrators group on target computer
   - Or be granted specific service control permissions

## Usage Examples

### Scenario 1: User Can't Connect to RDP
1. Check dashboard - computer shows "Online"
2. Click "Restart RDP" button
3. Confirm the restart
4. Wait 10-15 seconds for operation to complete
5. Ask user to try connecting again

### Scenario 2: Bulk Restart Multiple Computers
Currently, you need to click each button individually. For bulk operations:
1. Note which computers need restart
2. Click "Restart RDP" on each one
3. Wait for each to complete before moving to next

**Future enhancement idea**: Add "Select multiple" feature for bulk operations

### Scenario 3: Scheduled Maintenance
For planned restarts during maintenance windows:
1. Filter for specific location (e.g., "5F Main IDF")
2. Restart RDP services on computers one by one
3. Verify each shows "Success" before proceeding

## Alternative Methods

If the dashboard button doesn't work, you can:

### Method 1: Use Original PowerShell Script
```powershell
.\Restart-TermService.ps1
# Then enter computer name when prompted
```

### Method 2: Use Remote-ServiceRestart Script
```powershell
.\Remote-ServiceRestart.ps1 -ComputerName "COMPUTER-NAME" -RDPOnly
```

### Method 3: Manual via sc.exe
```powershell
sc.exe \\COMPUTER-NAME stop UmRdpService
sc.exe \\COMPUTER-NAME stop TermService
Start-Sleep -Seconds 5
sc.exe \\COMPUTER-NAME start TermService
sc.exe \\COMPUTER-NAME start UmRdpService
```

## Future Enhancements

Possible improvements:
1. **Bulk operations** - Select multiple computers and restart all at once
2. **Authentication** - Add user login to dashboard for security
3. **Scheduling** - Schedule automatic restarts during maintenance windows
4. **More actions** - Add buttons for other common tasks (restart computer, restart print spooler, etc.)
5. **Real-time status** - Show live service status without restarting
6. **History log** - Track who restarted what and when
7. **Email notifications** - Alert when restart completes/fails

## Related Files

- `restart-rdp-remote.ps1` - PowerShell script that performs the restart
- `app.py` - Flask backend with `/api/restart-rdp` endpoint
- `templates/dashboard.html` - Frontend with "Restart RDP" button
- `Restart-TermService.ps1` - Original interactive script (in user home folder)
- `Remote-ServiceRestart.ps1` - Alternative restart script (in user home folder)

## Support

If you encounter issues:
1. Check the error message in the popup alert
2. Look at Flask terminal output for detailed logs
3. Try running `restart-rdp-remote.ps1` manually
4. Verify your account has admin rights on target computer
5. Check Windows Event Viewer on target computer
