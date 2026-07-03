# Windows Desktop Environment Setup Script for Komorebi, YASB, and Tools
# Run this script as Administrator in PowerShell

Write-Host "Starting Windows customization setup..." -ForegroundColor Green

# 1. Install required applications via Winget
$apps = @(
    "LGUG2Z.komorebi",
    "LGUG2Z.masir",
    "karlstav.cava",
    "DEVCOM.JetBrainsMonoNerdFont",
    "Microsoft.PowerToys"
)

Write-Host "Installing/Updating applications..." -ForegroundColor Cyan
foreach ($app in $apps) {
    Write-Host "Installing $app..." -ForegroundColor Yellow
    winget install -e --id $app --accept-source-agreements --accept-package-agreements
}

# 2. Create directory for Customization tools
$customDir = "C:\Users\tnaru\Tools\Customization"
if (!(Test-Path $customDir)) {
    New-Item -ItemType Directory -Path $customDir -Force | Out-Null
}

# 3. Register Scheduled Task for Startup
$taskName = "Start-Custom-WM-Environment"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File C:\Users\tnaru\Tools\Customization\startup.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "tnaru" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Write-Host "Registering Scheduled Task: $taskName..." -ForegroundColor Cyan
# Check if task already exists and unregister
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings

Write-Host "Setup completed! Please log out and log back in to verify the environment." -ForegroundColor Green
