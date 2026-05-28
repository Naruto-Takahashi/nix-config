/*
    =============================================================================
    Main AutoHotkey Script
    Description: Key remappings, Vim-like navigation, and IME integration.
    =============================================================================
*/

; =============================================================================
; Global Settings
; =============================================================================
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Load external libraries
#Include %A_ScriptDir%\lib\ime_functions.ahk

; =============================================================================
; Key Remapping
; =============================================================================

; --- CapsLock -> Left Control (Hold) / Escape (Tap) ---
; Remaps F13 (mapped from CapsLock in Registry/Software) to Left Control.
; If F13 is released without pressing any other keys, it sends Escape.
*F13::
    Send, {LCtrl down}
    KeyWait, F13
    Send, {LCtrl up}
    if (A_PriorKey == "F13") {
        Send, {Esc}
    }
Return

; --- Physical Left Control -> Escape on Tap ---
; If the physical Left Control key is pressed and released without any other key, it sends Escape.
~LCtrl Up::
    if (A_PriorKey == "LControl") {
        Send, {Esc}
    }
Return

; =============================================================================
; Space Key Enhancements (SandS & Vim Mode)
; =============================================================================

; --- SandS (Space and Shift) Behavior ---
; Tap Space: Output Space
Space Up::Send, {Space}
; Shift + Space: Output Space (allows repeat)
+Space::Send, {Space}


; --- Vim Navigation (Space + HJKL) ---
Space & h::Send {Blind}{Left}
Space & j::Send {Blind}{Down}
Space & k::Send {Blind}{Up}
Space & l::Send {Blind}{Right}

; --- Navigation Extras ---
Space & a::Send {Blind}{Home}
Space & e::Send {Blind}{End}

; --- Editing Shortcuts ---
Space & u:: Send, ^z          ; Undo
Space & b:: Send, {Backspace} ; Backspace
Space & x:: Send, {Delete}    ; Delete
^Space::    Send, ^{Space}    ; Ctrl + Space (Pass-through)
!Space::    Send, !{Space}    ; Alt + Space (Pass-through)


; =============================================================================
; Virtual Desktop Operations
; =============================================================================

; --- Switch Desktop (Right) ---
; RWin or RCtrl -> Switch to next desktop
RWin:: Send, {LWin down}{LCtrl down}{Right}{LCtrl up}{LWin up}
RCtrl::Send, {LWin down}{LCtrl down}{Right}{LCtrl up}{LWin up}

; --- Move Window to Next Desktop ---
; Alt + RWin/RCtrl -> Move active window to next desktop
!RWin:: SendInput, {LWin down}{LCtrl down}{LAlt down}{Right}{LAlt up}{LCtrl up}{LWin up}
!RCtrl::SendInput, {LWin down}{LCtrl down}{LAlt down}{Right}{LAlt up}{LCtrl up}{LWin up}


; =============================================================================
; IME & Vim Integration
; =============================================================================

; --- Alt Key IME Switching (Mac-style) ---
; Left Alt: IME OFF (English)
~LAlt Up::
    if (A_PriorHotkey == "~LAlt")
        IME_SET(0)
    Return
~LAlt::SendInput, {vkE8} ; Void

; Right Alt: IME ON (Japanese)
~RAlt Up::
    if (A_PriorHotkey == "~RAlt")
        IME_SET(1)
    Return
~RAlt::SendInput, {vkE8} ; Void

; --- Vim Escape & IME OFF ---
; Pressing Escape sends Esc and forces IME OFF
$Esc::
    SendInput, {LCtrl up}{RCtrl up}{Esc}
    Sleep 10 ; Slight delay to ensure Esc processes before IME switch
    IME_SET(0)
Return

; --- Ctrl + [ -> Escape & IME OFF ---
^[::
    SendInput, {LCtrl up}{RCtrl up}{Esc}
    Sleep 10
    IME_SET(0)
Return


; =============================================================================
; Explorer Integration (Everything Search)
; =============================================================================

#IfWinActive ahk_class CabinetWClass
^f::
    path := GetExplorerPath()
    if (path) {
        ; Confirmed path for Everything 1.5a
        everythingPath := "C:\Program Files\Everything 1.5a\Everything.exe"
        
        if FileExist(everythingPath) {
            Run, "%everythingPath%" -path "%path%"
        } else {
            MsgBox, 16, Error, Everything 1.5a not found at:`n%everythingPath%`n`nPlease check the installation path.
        }
    } else {
        Send, ^f
    }
Return
#IfWinActive

GetExplorerPath() {
    WinGetClass, winClass, A
    if (winClass ~= "Progman|WorkerW")
        return A_Desktop
    else {
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.hwnd == WinExist("A"))
                return window.Document.Folder.Self.Path
        }
    }
}
