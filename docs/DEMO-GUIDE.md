# Computer Monitoring Dashboard - Demo Guide

**For: Desktop Managers (Non-Technical)**  
**Date: November 24, 2025**

---

## What Is This?

A **real-time dashboard** that shows which computers in our network are online or offline. Think of it like a "status board" that updates automatically.

---

## Why Do We Need This?

### Current Problem:
- We only know computers are offline when users call to report issues
- No visibility into which machines are having problems
- Reactive instead of proactive support

### Solution:
- **See all computers in one place**
- **Know immediately when machines go offline**
- **Be proactive** - fix issues before users complain
- **Perfect for TV displays** - always visible to the team

---

## What Does It Look Like?

### Dashboard View (Web Browser):

```
┌─────────────────────────────────────────────────┐
│   Computer Monitoring Dashboard                 │
│   Last updated: 2025-11-24 10:30:15             │
└─────────────────────────────────────────────────┘

┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  TOTAL   │  │  ONLINE  │  │ OFFLINE  │  │ UPTIME   │
│   125    │  │   116    │  │    9     │  │  92.8%   │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
    ↑             ↑             ↑
 CLICKABLE!   CLICKABLE!   CLICKABLE!

┌───────────────────────────────────────────────────┐
│  Computer Name      Status    Last Checked        │
├───────────────────────────────────────────────────┤
│  WHOU-5186-WKS     🔴 Offline  2025-11-24 09:15   │
│  5604-DSK          🟢 Online   2025-11-24 10:30   │
│  LJA-MXL9206702    🔴 Offline  Unknown            │
│  ...                                              │
└───────────────────────────────────────────────────┘
```

---

## Key Features (What You Can Do)

### 1. **Filter by Status** (Click the Cards)
- Click **"Offline"** card → See ONLY offline computers
- Click **"Online"** card → See ONLY online computers
- Click **"Total"** card → See ALL computers

**Why this matters:** Quickly focus on problem machines

### 2. **Last Seen** Column
- Shows when each offline computer was last detected online
- Example: "2h 15m ago" = Computer went offline 2 hours 15 minutes ago

**Why this matters:** Know how long machines have been down

### 3. **Search Box**
- Type computer name to find it instantly
- Example: Type "WHOU" to see all WHOU computers

**Why this matters:** Quickly check specific machines

### 4. **Auto-Refresh**
- Dashboard updates every 30 seconds automatically
- Monitoring checks all computers every 2 minutes
- **No need to refresh the page manually**

**Why this matters:** Always see current status

---

## Demo Steps (Follow This Script)

### Step 1: Start the Dashboard (5 seconds)
1. Open PowerShell
2. Go to: `C:\Users\tladm\computer-monitor`
3. Run: `.\start-all.ps1`
4. Two windows will open (let them run in background)

### Step 2: Open in Browser (10 seconds)
1. Open any web browser (Chrome, Edge, Firefox)
2. Go to: **http://localhost:5000**
3. Dashboard appears!

### Step 3: Show the Features (2 minutes)

#### A. Overview (30 seconds)
- Point to the 4 summary cards at top
- "We have 125 computers, 116 are online, 9 are offline"
- "That's 92.8% uptime right now"

#### B. Click Filtering (30 seconds)
1. Click the **RED "Offline"** card
2. "Now I'm seeing only the 9 problem computers"
3. Click the **GREEN "Online"** card
4. "Now just the healthy ones"
5. Click **"Total"** to show all again

#### C. Last Seen (30 seconds)
- Point to the "Last Seen" column
- "This shows when each offline computer was last online"
- "Unknown means it was already offline when we started monitoring"

#### D. Search (30 seconds)
- Type a computer name in the search box
- "Instantly finds any computer you're looking for"

### Step 4: Show Network Access (TV Display) (1 minute)

**Important:** This works on ANY device on the same network!

1. Open browser on your phone/tablet/TV
2. Go to: **http://10.200.10.37:5000**
3. Same dashboard appears!

**TV Display Setup:**
- Connect TV browser to: http://10.200.10.37:5000
- Press F11 for fullscreen
- Leave it running 24/7
- Team always sees current status

---

## Benefits Summary

### For Support Team:
✅ See all problems at a glance  
✅ Fix issues before users call  
✅ Know which machines need attention  
✅ Track uptime patterns  

### For Managers:
✅ Monitor team's computer health  
✅ Identify chronic problem machines  
✅ Make data-driven hardware decisions  
✅ Improve user satisfaction  

### Cost:
✅ **FREE** - uses existing hardware  
✅ No licenses or subscriptions  
✅ Runs on one computer (yours)  

---

## Common Questions & Answers

### Q: "Do users need to install anything?"
**A:** NO! Only needs to run on ONE computer (yours). Everyone else just opens a web browser.

### Q: "What if the computer running it turns off?"
**A:** Dashboard stops working until you turn it back on. Recommend: leave your PC on, or move it to a server.

### Q: "Can we monitor more computers?"
**A:** YES! Just add them to the CSV file. No limit.

### Q: "Does it work outside the office?"
**A:** Not currently. It's for office network only. (Could be added later)

### Q: "What if a computer is offline?"
**A:** Dashboard shows it in red immediately (within 2 minutes). Currently just visual - no email alerts yet.

### Q: "Can we add email alerts?"
**A:** YES! That's a potential future enhancement. Dashboard first, alerts next.

---

## Technical Details (If Asked)

**What it monitors:** Network connectivity (ping test)  
**How often:** Every 2 minutes  
**Requirements:** Windows PC, Python (already installed)  
**Runs on:** Your PC at IP 10.200.10.37  
**Port:** 5000 (may need firewall exception)  

---

## After the Demo

### Next Steps:
1. **Decision:** Do you want to use this?
2. **Location:** Which computer should run it 24/7?
3. **TV Setup:** Do we want it on a TV display?
4. **Future:** Should we add email alerts?

### If Approved:
- Move to dedicated computer/server
- Set up Windows startup script (runs automatically)
- Add TV display in support area
- Train team on how to use it
- Consider adding email notifications

---

## Quick Start Commands

**Start everything:**
```powershell
cd C:\Users\tladm\computer-monitor
.\start-all.ps1
```

**Access dashboard:**
- Your computer: http://localhost:5000
- Any device: http://10.200.10.37:5000

**Stop:**
- Close both PowerShell windows

---

## Support Contact

**Created by:** tladm  
**Date:** November 2025  
**Location:** `C:\Users\tladm\computer-monitor\`  
**Full Documentation:** See `README.md` in same folder

---

## Demo Checklist

Before you go to managers:

- [ ] Run `.\start-all.ps1` (both windows open)
- [ ] Open browser to http://localhost:5000 (dashboard loads)
- [ ] Test clicking Offline card (filters work)
- [ ] Test search box (type a computer name)
- [ ] Open on phone/tablet to show network access works
- [ ] Have this guide printed or on second screen

**You got this! 🚀**

The dashboard speaks for itself - it's visual, intuitive, and solves a real problem they understand.
