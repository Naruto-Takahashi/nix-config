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

# 5. Command Palette (ストアアプリなので AUMID 経由で起動; exe 直叩きは不可)
Start-Sleep -Seconds 5
Start-Process "shell:AppsFolder\Microsoft.CommandPalette_8wekyb3d8bbwe!App"
