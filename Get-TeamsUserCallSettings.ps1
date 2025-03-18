Write-Host "Beginning Microsoft Teams User Call Settings Report..." -ForegroundColor White

# Define Output File
$ReportPath = "$env:USERPROFILE\Desktop\Teams_UserCallSettings.csv"

# Connect to Microsoft Teams
Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Yellow
Connect-MicrosoftTeams

# Fetch Users and Export
$Users = Get-CsOnlineUser -ResultSize 10000
$Users | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "Report saved to: $ReportPath" -ForegroundColor Green