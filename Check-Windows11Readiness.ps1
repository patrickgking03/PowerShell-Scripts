Write-Host "Beginning Windows 11 Readiness Check..." -ForegroundColor White

# Define Minimum System Requirements
$MinMemoryGB = 4
$MinStorageGB = 64
$MinLogicalCores = 2
$MinClockSpeedMHz = 1000
$TPMRequiredVersion = "2.0"

# Check Memory
$Memory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
$MemoryCheck = if ($Memory -ge $MinMemoryGB) { "PASS" } else { "FAIL" }

# Check Storage
$Storage = (Get-Partition | Get-Volume | Where-Object { $_.DriveLetter -eq (Get-Location).Path[0] }).SizeRemaining / 1GB
$StorageCheck = if ($Storage -ge $MinStorageGB) { "PASS" } else { "FAIL" }

# Check CPU
$CPU = Get-CimInstance Win32_Processor
$CPUCheck = if ($CPU.NumberOfLogicalProcessors -ge $MinLogicalCores -and $CPU.MaxClockSpeed -ge $MinClockSpeedMHz) { "PASS" } else { "FAIL" }

# Check TPM
$TPM = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm
$TPMCheck = if ($TPM.SpecVersion -ge $TPMRequiredVersion) { "PASS" } else { "FAIL" }

# Output Results
Write-Host "Memory: $Memory GB - " -NoNewline
Write-Host $MemoryCheck -ForegroundColor $(if ($MemoryCheck -eq "PASS") { "Green" } else { "Red" })

Write-Host "Storage: $Storage GB - " -NoNewline
Write-Host $StorageCheck -ForegroundColor $(if ($StorageCheck -eq "PASS") { "Green" } else { "Red" })

Write-Host "CPU: $($CPU.NumberOfLogicalProcessors) Cores, $($CPU.MaxClockSpeed) MHz - " -NoNewline
Write-Host $CPUCheck -ForegroundColor $(if ($CPUCheck -eq "PASS") { "Green" } else { "Red" })

Write-Host "TPM: Version $($TPM.SpecVersion) - " -NoNewline
Write-Host $TPMCheck -ForegroundColor $(if ($TPMCheck -eq "PASS") { "Green" } else { "Red" })

# Final Decision
if ($MemoryCheck -eq "PASS" -and $StorageCheck -eq "PASS" -and $CPUCheck -eq "PASS" -and $TPMCheck -eq "PASS") {
    Write-Host "Your device is ready for Windows 11!" -ForegroundColor Green
} else {
    Write-Host "Your device does NOT meet Windows 11 requirements." -ForegroundColor Red
}