/*
    =============================================================================
    Komorebi & YASB AutoHotkey Script
    Description: Hotkeys for komorebi window management.
    =============================================================================
*/

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; --- Focus ---
!h::Run, komorebic focus left, , Hide
!l::Run, komorebic focus right, , Hide
!k::Run, komorebic focus up, , Hide
!j::Run, komorebic focus down, , Hide

; --- Move (Swap in Komorebi) ---
!+h::Run, komorebic move left, , Hide
!+l::Run, komorebic move right, , Hide
!+k::Run, komorebic move up, , Hide
!+j::Run, komorebic move down, , Hide

; --- Workspaces (Focus) ---
!1::Run, komorebic focus-workspace 0, , Hide
!2::Run, komorebic focus-workspace 1, , Hide
!3::Run, komorebic focus-workspace 2, , Hide
!4::Run, komorebic focus-workspace 3, , Hide
!5::Run, komorebic focus-workspace 4, , Hide
!6::Run, komorebic focus-workspace 5, , Hide
!7::Run, komorebic focus-workspace 6, , Hide
!8::Run, komorebic focus-workspace 7, , Hide
!9::Run, komorebic focus-workspace 8, , Hide

; --- Workspaces (Move Window) ---
!+1::Run, komorebic move-to-workspace 0, , Hide
!+2::Run, komorebic move-to-workspace 1, , Hide
!+3::Run, komorebic move-to-workspace 2, , Hide
!+4::Run, komorebic move-to-workspace 3, , Hide
!+5::Run, komorebic move-to-workspace 4, , Hide
!+6::Run, komorebic move-to-workspace 5, , Hide
!+7::Run, komorebic move-to-workspace 6, , Hide
!+8::Run, komorebic move-to-workspace 7, , Hide
!+9::Run, komorebic move-to-workspace 8, , Hide

; --- Layout & Window Ops ---
!t::Run, komorebic toggle-tiling, , Hide
!f::Run, komorebic toggle-maximize, , Hide
!m::Run, komorebic minimize, , Hide
!+q::Run, komorebic close, , Hide
!+r::Run, komorebic reload-configuration, , Hide

; --- Alt+Enter for WezTerm (Exclude Excel) ---
#IfWinNotActive ahk_exe EXCEL.EXE
!Enter::
    Run, wezterm-gui
Return
#IfWinNotActive
