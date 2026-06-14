/*
    =============================================================================
    Komorebi & YASB AutoHotkey Script
    Description: Hotkeys for komorebi window management.
    =============================================================================
*/

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; --- Focus ---
!h::Run, komorebic.exe focus left, , Hide
!l::Run, komorebic.exe focus right, , Hide
!k::Run, komorebic.exe focus up, , Hide
!j::Run, komorebic.exe focus down, , Hide

; --- Move (Swap in Komorebi) ---
!+h::Run, komorebic.exe move left, , Hide
!+l::Run, komorebic.exe move right, , Hide
!+k::Run, komorebic.exe move up, , Hide
!+j::Run, komorebic.exe move down, , Hide

; --- Workspaces (Focus) ---
!1::Run, komorebic.exe focus-workspace 0, , Hide
!2::Run, komorebic.exe focus-workspace 1, , Hide
!3::Run, komorebic.exe focus-workspace 2, , Hide
!4::Run, komorebic.exe focus-workspace 3, , Hide
!5::Run, komorebic.exe focus-workspace 4, , Hide
!6::Run, komorebic.exe focus-workspace 5, , Hide
!7::Run, komorebic.exe focus-workspace 6, , Hide
!8::Run, komorebic.exe focus-workspace 7, , Hide
!9::Run, komorebic.exe focus-workspace 8, , Hide

; --- Workspaces (Move Window) ---
!+1::Run, komorebic.exe move-to-workspace 0, , Hide
!+2::Run, komorebic.exe move-to-workspace 1, , Hide
!+3::Run, komorebic.exe move-to-workspace 2, , Hide
!+4::Run, komorebic.exe move-to-workspace 3, , Hide
!+5::Run, komorebic.exe move-to-workspace 4, , Hide
!+6::Run, komorebic.exe move-to-workspace 5, , Hide
!+7::Run, komorebic.exe move-to-workspace 6, , Hide
!+8::Run, komorebic.exe move-to-workspace 7, , Hide
!+9::Run, komorebic.exe move-to-workspace 8, , Hide

; --- Layout & Window Ops ---
!t::Run, komorebic.exe toggle-tiling, , Hide
!f::Run, komorebic.exe toggle-maximize, , Hide
!m::Run, komorebic.exe minimize, , Hide
!+q::Run, komorebic.exe close, , Hide
!+r::Run, komorebic.exe reload-configuration, , Hide

; --- Alt+Enter for WezTerm (Exclude Excel) ---
#IfWinNotActive ahk_exe EXCEL.EXE
!Enter::
    Run, wezterm-gui
Return
#IfWinNotActive
