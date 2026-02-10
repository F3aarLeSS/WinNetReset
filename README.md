# WinNetReset

Windows Network Reset utility to fix common network issues.

Designed for **local use** and **transparency**.

---

## ✨ Features

- Reset IP (release / renew)
- Flush DNS cache
- Reset Winsock & TCP/IP stack
- Simple Windows GUI
- No telemetry
- No background services
- No registry changes

---

## ⚠️ Important Security Notice

This tool is built using **PowerShell** and packaged as an EXE.

Some antivirus software may flag the EXE as suspicious due to heuristic detection.  
This is a **false positive**.

### This tool does NOT:
- Collect data
- Connect to the internet
- Persist on startup
- Modify registry keys

You are encouraged to review the source code before running.

---

## ▶ Usage

### Option 1: Run EXE
1. Right-click `WinNetReset.exe`
2. Select **Run as administrator**

### Option 2: Run PowerShell Script (Direct)

```powershell
https://raw.githubusercontent.com/F3aarLeSS/WinNetReset/refs/heads/main/WinNetreset.ps1
