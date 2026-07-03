/*
    =============================================================================
    Komorebi & YASB AutoHotkey Script (GlazeWM Keybinding Reproduction)
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

; --- Resize (Reproducing GlazeWM alt+u/p/o/i) ---
!u::Run, komorebic resize-edge right -50, , Hide
!p::Run, komorebic resize-edge right 50, , Hide
!o::Run, komorebic resize-edge bottom 50, , Hide
!i::Run, komorebic resize-edge bottom -50, , Hide

; --- Window Operations ---
!f::Run, komorebic toggle-monocle, , Hide
!m::Run, komorebic minimize, , Hide
!t::Run, komorebic toggle-tiling, , Hide
!b::Run, komorebic flip-layout horizontal-and-vertical, , Hide!+q::Run, komorebic close, , Hide
!+w::Run, komorebic close, , Hide

; --- Workspaces (Cycle) ---
!a::Run, komorebic cycle-workspace previous, , Hide
!s::Run, komorebic cycle-workspace next, , Hide

; --- Workspaces (Direct Focus) ---
; Monitor 0 (Workspaces 1-5)
!1::Run, komorebic focus-monitor-workspace 0 0, , Hide
!2::Run, komorebic focus-monitor-workspace 0 1, , Hide
!3::Run, komorebic focus-monitor-workspace 0 2, , Hide
!4::Run, komorebic focus-monitor-workspace 0 3, , Hide
!5::Run, komorebic focus-monitor-workspace 0 4, , Hide
; Monitor 1 (Workspaces 6-9)
!6::Run, komorebic focus-monitor-workspace 1 0, , Hide
!7::Run, komorebic focus-monitor-workspace 1 1, , Hide
!8::Run, komorebic focus-monitor-workspace 1 2, , Hide
!9::Run, komorebic focus-monitor-workspace 1 3, , Hide

; --- Workspaces (Move Window & Follow Focus) ---
; Monitor 0 (Workspaces 1-5)
!+1::
    Run, komorebic move-to-monitor-workspace 0 0, , Hide
    Run, komorebic focus-monitor-workspace 0 0, , Hide
Return
!+2::
    Run, komorebic move-to-monitor-workspace 0 1, , Hide
    Run, komorebic focus-monitor-workspace 0 1, , Hide
Return
!+3::
    Run, komorebic move-to-monitor-workspace 0 2, , Hide
    Run, komorebic focus-monitor-workspace 0 2, , Hide
Return
!+4::
    Run, komorebic move-to-monitor-workspace 0 3, , Hide
    Run, komorebic focus-monitor-workspace 0 3, , Hide
Return
!+5::
    Run, komorebic move-to-monitor-workspace 0 4, , Hide
    Run, komorebic focus-monitor-workspace 0 4, , Hide
Return
; Monitor 1 (Workspaces 6-9)
!+6::
    Run, komorebic move-to-monitor-workspace 1 0, , Hide
    Run, komorebic focus-monitor-workspace 1 0, , Hide
Return
!+7::
    Run, komorebic move-to-monitor-workspace 1 1, , Hide
    Run, komorebic focus-monitor-workspace 1 1, , Hide
Return
!+8::
    Run, komorebic move-to-monitor-workspace 1 2, , Hide
    Run, komorebic focus-monitor-workspace 1 2, , Hide
Return
!+9::
    Run, komorebic move-to-monitor-workspace 1 3, , Hide
    Run, komorebic focus-monitor-workspace 1 3, , Hide
Return

; --- Move Workspace to Monitor ---
!+a::Run, komorebic move-workspace-to-monitor 0, , Hide
!+f::Run, komorebic move-workspace-to-monitor 1, , Hide

; --- App Launchers ---
; ALT+Y: WezTerm で yazi
!y::Run, wezterm-gui start -- wsl.exe --cd ~ -e zsh -ic yazi
; ALT+V: Vivaldi
!v::Run, C:\Users\tnaru\AppData\Local\Vivaldi\Application\vivaldi.exe

; --- Alt+Enter for WezTerm (Exclude Excel) ---
#IfWinNotActive ahk_exe EXCEL.EXE
!Enter::
    Run, wezterm-gui
Return
#IfWinNotActive
