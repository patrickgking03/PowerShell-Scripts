Write-Host "Beginning Microsoft 365 Group Membership Report..." -ForegroundColor White

# Define Output File
$ReportPath = "$env:USERPROFILE\Desktop\M365_GroupMembershipReport.csv"

# Ensure Required Modules Are Installed
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing Exchange Online module..." -ForegroundColor Yellow
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}
Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue

# Connect to Exchange Online if not already connected
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.Exchange" })) {
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
    try {
        Connect-ExchangeOnline -ShowBanner:$false -ShowProgress:$false -ErrorAction Stop
        Write-Host "Connected to Exchange Online." -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to connect to Exchange Online." -ForegroundColor Red
        exit
    }
}

# Fetch Groups
Write-Host "Fetching Microsoft 365 Groups..." -ForegroundColor Yellow
$Groups = Get-UnifiedGroup -ResultSize Unlimited
Write-Host "Found $($Groups.Count) groups." -ForegroundColor Green

# Process Groups
$GroupData = $Groups | ForEach-Object {
    [PSCustomObject]@{
        "Group Name"  = $_.DisplayName
        "Members"     = (Get-UnifiedGroupLinks -Identity $_.Identity -LinkType Members -ResultSize Unlimited).Count
        "Owners"      = (Get-UnifiedGroupLinks -Identity $_.Identity -LinkType Owners -ResultSize Unlimited).Count
    }
}

# Export Report
$GroupData | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report saved to: $ReportPath" -ForegroundColor Green

Write-Host "Script execution completed successfully." -ForegroundColor Green