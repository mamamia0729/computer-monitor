# GitHub Setup Guide

## Quick Start - Push to GitHub in 3 Steps

### Step 1: Update Your Email (Important!)

Edit `setup-github.ps1` and update your email on line 17:
```powershell
[string]$AuthorEmail = "your.actual.email@example.com"
```

### Step 2: Run Setup Script

```powershell
.\setup-github.ps1
```

This will:
- ✅ Initialize Git repository
- ✅ Configure Git user (Thinh Le)
- ✅ Create 9 organized commits by feature
- ✅ Show you next steps

### Step 3: Create GitHub Repository & Push

1. **Create repository on GitHub**:
   - Go to: https://github.com/new
   - Repository name: `computer-monitor`
   - Description: `Real-time computer monitoring dashboard for IT operations teams`
   - **Public** repository (recommended for portfolio)
   - **Do NOT** initialize with README
   - Click "Create repository"

2. **Push to GitHub**:
   ```powershell
   git remote add origin https://github.com/mamamia0729/computer-monitor.git
   git branch -M main
   git push -u origin main
   ```

3. **Done!** Visit: https://github.com/mamamia0729/computer-monitor

---

## What the Setup Script Does

### Creates 9 Feature-Based Commits:

1. **Initial project setup** - License, .gitignore, config
2. **Core monitoring system** - PowerShell monitoring with parallel processing
3. **Web dashboard interface** - Flask + Bootstrap UI
4. **Location tracking** - Organize by IDF/network closet (218 computers, 6 locations)
5. **Enhanced status tracking** - "Last Seen" timestamps
6. **Interactive filtering** - Clickable stat cards, filter persistence
7. **Remote RDP restart** - One-click service restart from dashboard
8. **Deployment tools** - Launchers, helper scripts, management tools
9. **Documentation** - README, CHANGELOG, guides (2000+ lines)

Each commit has:
- ✅ Detailed description
- ✅ Feature list
- ✅ Technical details
- ✅ Use cases
- ✅ Author attribution

---

## After Pushing to GitHub

### Add Repository Topics

Make your repo discoverable by adding topics:
1. Go to your repository on GitHub
2. Click "⚙️ Settings" or the gear icon near "About"
3. Add these topics:
   ```
   powershell
   python
   flask
   monitoring
   dashboard
   windows
   devops
   it-operations
   network-monitoring
   rdp
   system-administration
   enterprise
   ```

### Update Repository Description

Add this description in GitHub repository settings:
```
🖥️ Real-time computer monitoring dashboard for Windows environments. 
Monitor 200+ computers, track state changes, and remotely restart RDP 
services—all from a modern web interface. Built for IT operations teams.
```

### Pin to Profile

Consider pinning this repository to your GitHub profile to showcase:
1. Go to your profile: https://github.com/mamamia0729
2. Click "Customize your pins"
3. Select `computer-monitor`

---

## Troubleshooting

### "Email is not configured"
Edit `setup-github.ps1` and set your actual email on line 17.

### "Git repository already exists"
The script will ask if you want to continue. Choose "Y" to proceed.

### "Permission denied"
Make sure you're logged into GitHub and have permission to push.

### "Remote already exists"
If you see this error:
```powershell
git remote remove origin
git remote add origin https://github.com/mamamia0729/computer-monitor.git
```

---

## Commit History Preview

Your commit history will look like this:

```
9c4a1f2 Add comprehensive documentation
8b3c5d1 Add deployment and operations tools  
7a2b9c8 Add remote RDP service restart feature
6d8e4f3 Add interactive filtering and UX improvements
5c7a2b9 Add 'Last Seen' tracking for offline computers
4b6d8e1 Add location tracking for computers
3a5c7d9 Add web dashboard interface
2b4d6f8 Add core monitoring system
1a3c5e7 Initial project setup
```

Each commit is properly authored by **Thinh Le** with full descriptions.

---

## Portfolio Tips

This project demonstrates:

✅ **PowerShell Automation** (2,500+ lines)
- Parallel processing
- Remote administration
- Error handling
- Enterprise-scale monitoring

✅ **Python Web Development** (Flask, REST API)
- Backend API design
- JSON data handling
- Subprocess management

✅ **Full-Stack Development** (Bootstrap 5, JavaScript)
- Responsive UI design
- Real-time updates
- Interactive filtering
- User experience optimization

✅ **DevOps & Operations** (Documentation, Deployment)
- Windows Service deployment
- Production best practices
- Comprehensive documentation
- Enterprise tooling

✅ **Problem Solving** (Real-world enterprise solution)
- Scaled to 200+ computers
- Domain environment compatible
- No WinRM required
- Security-conscious design

Perfect for showcasing on your resume and LinkedIn!

---

## Questions?

If you encounter any issues:
1. Check the error message carefully
2. Verify Git is installed: `git --version`
3. Ensure you have GitHub access
4. Check your email is configured in `setup-github.ps1`

**Repository URL**: https://github.com/mamamia0729/computer-monitor
