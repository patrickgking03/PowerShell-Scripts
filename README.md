# PowerShell Scripts for IT

This repository contains various PowerShell scripts designed for Microsoft 365 management, Windows assessments, and automation tasks. Each script is built to work on both **Windows** and **macOS** where applicable.

## Available Scripts

### [Check-Windows11Readiness.ps1](./Check-Windows11Readiness.ps1)
- **Purpose:** Checks if a device meets the Windows 11 system requirements.
- **How to Run:**
  ```powershell
  .\Check-Windows11Readiness.ps1
  ```

### [Get-AutopilotHardwareHash.ps1](./Get-AutopilotHardwareHash.ps1)
- **Purpose:** Collects a Windows Autopilot hardware hash for device enrollment.
- **How to Run:**
  ```powershell
  .\Get-AutopilotHardwareHash.ps1
  ```

### [Get-M365GroupActivityReport.ps1](./Get-M365GroupActivityReport.ps1)
- **Purpose:** Generates a detailed report on Microsoft 365 group activity, including Teams, SharePoint, and email usage.
- **How to Run:**
  ```powershell
  .\Get-M365GroupActivityReport.ps1
  ```

### [Get-M365GroupMembershipReport.ps1](./Get-M365GroupMembershipReport.ps1)
- **Purpose:** Retrieves Microsoft 365 group membership details, including group owners and SharePoint sites.
- **How to Run:**
  ```powershell
  .\Get-M365GroupMembershipReport.ps1
  ```

### [Get-M365InactiveUsers.ps1](./Get-M365InactiveUsers.ps1)
- **Purpose:** Identifies inactive users in Microsoft 365 based on last login and activity data.
- **How to Run:**
  ```powershell
  .\Get-M365InactiveUsers.ps1
  ```

### [Get-M365LicenseReport.ps1](./Get-M365LicenseReport.ps1)
- **Purpose:** Exports a detailed Microsoft 365 license report, showing assigned and available licenses.
- **How to Run:**
  ```powershell
  .\Get-M365LicenseReport.ps1
  ```

### [Get-TeamsUserCallSettings.ps1](./Get-TeamsUserCallSettings.ps1)
- **Purpose:** Retrieves Microsoft Teams user call settings, including forwarding and delegation details.
- **How to Run:**
  ```powershell
  .\Get-TeamsUserCallSettings.ps1
  ```

## Prerequisites

### Required PowerShell Modules:
Each script will automatically check for required modules and install them if necessary. However, to ensure smooth execution, you can manually install them using:
```powershell
Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
Install-Module -Name MicrosoftTeams -Force -AllowClobber
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber
```

### Running PowerShell Scripts
Ensure PowerShell execution policy allows scripts to run:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
```

## Output Locations
All reports and exported data will be saved to the user's **Desktop** by default.

## Notes
- Scripts are designed to work on **Windows** and **macOS** where applicable.
- Microsoft Teams and SharePoint commands may be limited on macOS.
- Ensure you have administrative privileges when executing scripts that require elevated permissions.

---
**Created & Maintained by Patrick King** | **Last Updated March 18, 2025**