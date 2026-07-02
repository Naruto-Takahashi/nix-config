# Start critical background tools at logon as fast as possible

# 1. AutoHotkey
Start-Process "C:\Users\tnaru\.config\komorebi\komorebi.ahk"

# 2. Komorebi
Start-Process "komorebi.exe" -ArgumentList "start --masir" -WindowStyle Hidden

# 3. YASB
Start-Process "C:\Program Files\YASB\yasb.exe"

# 4. PowerToys
Start-Process -FilePath "C:\Users\tnaru\AppData\Local\PowerToys\PowerToys.exe"
