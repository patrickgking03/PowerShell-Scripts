Write-Host "Beginning Autopilot Hardware Hash Collection..." -ForegroundColor White

# Define Output Directory
$OutputFolder = "$env:USERPROFILE\Desktop\HardwareHash"
$OutputFile = "$OutputFolder\Autopilot_HardwareHash.csv"

# Create Directory if Not Exists
if (-not (Test-Path $OutputFolder)) { New-Item -Type Directory -Path $OutputFolder | Out-Null }

# Check for Autopilot Script
if (-not (Get-Command Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Get-WindowsAutopilotInfo..." -ForegroundColor Yellow
    Install-Script -Name Get-WindowsAutopilotInfo -Force
}

# Generate Hardware Hash
Write-Host "Generating hardware hash..." -ForegroundColor Yellow
Get-WindowsAutopilotInfo.ps1 -OutputFile $OutputFile

Write-Host "Hardware hash saved to: $OutputFile" -ForegroundColor Green
