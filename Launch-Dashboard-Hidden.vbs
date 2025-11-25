Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Launch monitor.ps1 hidden (no window)
strMonitorCmd = "pwsh.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & strScriptPath & "\monitor.ps1"""
objShell.Run strMonitorCmd, 0, False

' Wait 3 seconds for monitor to initialize
WScript.Sleep 3000

' Launch dashboard minimized (in system tray area)
strDashboardCmd = "pwsh.exe -WindowStyle Minimized -ExecutionPolicy Bypass -File """ & strScriptPath & "\start-dashboard.ps1"""
objShell.Run strDashboardCmd, 7, False

' Wait 3 seconds for dashboard to start
WScript.Sleep 3000

' Show notification
MsgBox "Computer Monitoring Dashboard started!" & vbCrLf & vbCrLf & _
       "Dashboard: http://localhost:5000" & vbCrLf & vbCrLf & _
       "Services running in background." & vbCrLf & _
       "To stop: Use Task Manager or run Stop-Dashboard.bat", _
       vbInformation, "Monitoring System Started"
