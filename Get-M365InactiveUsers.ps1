Write-Host "Beginning Microsoft 365 Inactive Users Report..." -ForegroundColor White

# Define Output File
$ReportPath = "$env:USERPROFILE\Desktop\M365_InactiveUsers.csv"

# Check & Install Required Module
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Host "Installing Microsoft.Graph.Users module..." -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph.Users -Force -AllowClobber
}
Import-Module Microsoft.Graph.Users -ErrorAction SilentlyContinue

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All"

# Fetch Users
$InactiveThreshold = (Get-Date).AddDays(-90)
$Users = Get-MgUser -All -Property DisplayName, UserPrincipalName, SignInActivity
$InactiveUsers = $Users | Where-Object { $_.SignInActivity.LastSignInDateTime -lt $InactiveThreshold }

# Export Report
$InactiveUsers | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report saved to: $ReportPath" -ForegroundColor Green