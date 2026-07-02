set WshShell = CreateObject("WScript.Shell")
WshShell.Run "rundll32.exe user32.dll,LockWorkStation", 0, False