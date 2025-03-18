Write-Host "Beginning Microsoft 365 Group Activity Report..." -ForegroundColor White

# Define Admin Site URL (Replace with actual tenant admin URL)
$AdminSiteUrl = "https://YOURTENANT-admin.sharepoint.com"

# Define Report Path
$ReportPath = "$env:USERPROFILE\Desktop\M365_GroupActivityReport.csv"

# Detect OS
$IsMac = $PSVersionTable.OS -match "Darwin"
if ($IsMac) {
    Write-Host "Running on macOS - Limited functionality available." -ForegroundColor Yellow
} else {
    Write-Host "Running on Windows - Full functionality available." -ForegroundColor Green
}

# Ensure Required Modules Are Installed
$Modules = @("ExchangeOnlineManagement")
if (-not $IsMac) { 
    $Modules += "Microsoft.Online.SharePoint.PowerShell"
    $Modules += "MicrosoftTeams"
}
foreach ($Module in $Modules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Host "Installing module: $Module..." -ForegroundColor Yellow
        Install-Module -Name $Module -Force -AllowClobber
    }
    Import-Module $Module -ErrorAction SilentlyContinue
}

# Connect to Exchange Online
Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
try {
    Connect-ExchangeOnline -ShowBanner:$false -ShowProgress:$false -ErrorAction Stop
    Write-Host "Connected to Exchange Online." -ForegroundColor Green
} catch {
    Write-Host "Error: Could not connect to Exchange Online." -ForegroundColor Red
    exit
}

# Connect to SharePoint Online (Only for Windows)
$SPOConnected = $false
if (-not $IsMac) {
    Write-Host "Connecting to SharePoint Online..." -ForegroundColor Yellow
    try {
        Connect-SPOService -Url $AdminSiteUrl -ErrorAction Stop
        Write-Host "Connected to SharePoint Online." -ForegroundColor Green
        $SPOConnected = $true
    } catch {
        Write-Host "Warning: Could not connect to SharePoint Online." -ForegroundColor Yellow
    }
}

# Connect to Microsoft Teams (Only for Windows)
$TeamsConnected = $false
if (-not $IsMac) {
    Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Yellow
    try {
        Connect-MicrosoftTeams -ErrorAction Stop
        Write-Host "Connected to Microsoft Teams." -ForegroundColor Green
        $TeamsConnected = $true
    } catch {
        Write-Host "Warning: Could not connect to Microsoft Teams." -ForegroundColor Yellow
    }
}

# Fetch Groups
Write-Host "Fetching Microsoft 365 Groups..." -ForegroundColor Yellow
$Groups = Get-Recipient -RecipientTypeDetails GroupMailbox -ResultSize Unlimited | Sort-Object DisplayName
Write-Host "Found $($Groups.Count) groups." -ForegroundColor Green

# Initialize Report Data
$Report = @()
$Today = Get-Date
$WarningDate = $Today.AddDays(-90)

# Process Groups
foreach ($Group in $Groups) {
    $G = Get-UnifiedGroup -Identity $Group.DistinguishedName
    Write-Host "Processing: $($G.DisplayName)" -ForegroundColor Cyan
    
    # Get Group Details
    $ManagedBy = if ($G.ManagedBy) {
        (Get-Mailbox -Identity $G.ManagedBy[0] -ErrorAction SilentlyContinue).DisplayName
    } else { "No Owners" }
    
    # Get Mailbox Activity
    $MailboxData = Get-MailboxFolderStatistics -Identity $G.Alias -FolderScope Inbox -IncludeOldestAndNewestItems
    $LastConversation = if ($MailboxData.NewestItemReceivedDate) { $MailboxData.NewestItemReceivedDate } else { "No conversations" }
    $NumberConversations = $MailboxData.ItemsInFolder
    
    # Determine Mailbox Status
    $MailboxStatus = if ($LastConversation -le $WarningDate) {
        "Inactive"
    } elseif ($NumberConversations -lt 20) {
        "Low Activity"
    } else {
        "Active"
    }
    
    # Check SharePoint Activity
    $SPOActivity = "Not Checked"
    $SPOStorage = "N/A"
    if ($SPOConnected -and $G.SharePointSiteURL) {
        try {
            $Site = Get-SPOSite -Identity $G.SharePointSiteUrl -ErrorAction SilentlyContinue
            if ($Site) {
                $SPOStorage = [Math]::Round(($Site.StorageUsageCurrent / 1024), 2)
                $SPOActivity = "Active"
            } else {
                $SPOActivity = "No activity"
            }
        } catch {
            $SPOActivity = "Error checking"
        }
    }
    
    # Check Teams Activity
    $TeamsEnabled = $TeamsConnected -and ($null -ne $TeamsList[$G.ExternalDirectoryObjectId])
    
    # Generate Report Data
    $Report += [PSCustomObject]@{
        "Group Name" = $G.DisplayName
        "Status" = $MailboxStatus
        "Managed By" = $ManagedBy
        "Members" = $G.GroupMemberCount
        "Guests" = $G.GroupExternalMemberCount
        "Description" = $G.Notes
        "Mailbox Status" = $MailboxStatus
        "Team Enabled" = $TeamsEnabled
        "Last Chat" = $LastConversation
        "Chats" = $NumberConversations
        "Last Conversation" = $LastConversation
        "Conversations" = $NumberConversations
        "SPO Activity" = $SPOActivity
        "SPO Storage GB" = $SPOStorage
        "SPO Status" = if ($G.SharePointSiteURL) { "Exists" } else { "Not Created" }
        "Creation Date" = $G.WhenCreated
        "Days Old" = (New-TimeSpan -Start $G.WhenCreated -End $Today).Days
        "Warnings" = if ($MailboxStatus -eq "Inactive" -or $SPOActivity -eq "No activity") { "Yes" } else { "No" }
    }
}

# Export Report
$Report | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report saved to: $ReportPath" -ForegroundColor Green
Write-Host "Script execution completed successfully." -ForegroundColor Green