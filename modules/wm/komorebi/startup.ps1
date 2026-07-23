# Start critical background tools at logon as fast as possible

# 1. AutoHotkey
Start-Process "C:\Users\tnaru\Tools\Customization\main.ahk"
Start-Process "C:\Users\tnaru\.config\komorebi\komorebi.ahk"

# 2. Komorebi
$env:PATH += ";C:\Program Files\masir\bin"
Start-Process "C:\Program Files\komorebi\bin\komorebic.exe" -ArgumentList "start --masir" -WindowStyle Hidden

# 3. YASB
Start-Process "C:\Program Files\YASB\yasb.exe"

# 4. PowerToys
Start-Process -FilePath "C:\Users\tnaru\AppData\Local\PowerToys\PowerToys.exe"

# 5. Command Palette (ストアアプリ起動の確実化)
Start-Sleep -Seconds 10
$cmdPalLnk = "C:\Users\tnaru\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft.CmdPal.UI.lnk"
if (Test-Path $cmdPalLnk) {
    Start-Process $cmdPalLnk
} else {
    Start-Process "shell:AppsFolder\Microsoft.CommandPalette_8wekyb3d8bbwe!App"
}
