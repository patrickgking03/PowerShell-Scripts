Write-Host "Beginning Microsoft 365 License Report..." -ForegroundColor White

# Define Output File
$ReportPath = "$env:USERPROFILE/Desktop/M365_LicenseReport.csv"

# Check & Install Required Module
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Host "Installing Microsoft.Graph.Users module..." -ForegroundColor Yellow
    Install-Module -Name Microsoft.Graph.Users -Force -AllowClobber
}
Import-Module Microsoft.Graph.Users -ErrorAction SilentlyContinue

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Fetch Users and Licenses
$Users = Get-MgUser -All -Property DisplayName, UserPrincipalName, AssignedLicenses
$LicenseReport = @()
foreach ($User in $Users) {
    $LicenseReport += [PSCustomObject]@{
        "Display Name"  = $User.DisplayName
        "UserPrincipalName" = $User.UserPrincipalName
        "License Status" = if ($User.AssignedLicenses.Count -gt 0) { "Assigned" } else { "No License" }
    }
}

# Export Report
$LicenseReport | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report saved to: $ReportPath" -ForegroundColor Green