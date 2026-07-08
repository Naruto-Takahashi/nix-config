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

; --- モニタ構成変化 (WM_DISPLAYCHANGE) で komorebi/YASB を自動復旧 ---
; ケーブル抜き差しでワークスペース表示が崩れる問題対策
Gui, +LastFound
OnMessage(0x007E, "HandleDisplayChange")

HandleDisplayChange(wParam, lParam) {
    ; イベントは連発するためデバウンスして1回だけ実行
    SetTimer, ReapplyDisplayConfig, -5000
}

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
; komorebi 0.1.41 でピクセル指定が廃止され increase/decrease に変更。
; resize-edge は対象辺が画面端だと無効なため、位置に依らず効く resize-axis を使う
!u::Run, komorebic resize-axis horizontal decrease, , Hide
!p::Run, komorebic resize-axis horizontal increase, , Hide
!o::Run, komorebic resize-axis vertical increase, , Hide
!i::Run, komorebic resize-axis vertical decrease, , Hide

; --- Window Operations ---
!f::Run, komorebic toggle-monocle, , Hide
!m::Run, komorebic minimize, , Hide
!t::Run, komorebic toggle-tiling, , Hide
!b::Run, komorebic flip-layout horizontal-and-vertical, , Hide
!r::Run, komorebic retile, , Hide
; モニタ再接続で表示が崩れたとき等に手動で復旧 (自動復旧と同じ処理)
!+r::Gosub, ReapplyDisplayConfig

ReapplyDisplayConfig:
    Run, komorebic reload-configuration, , Hide
    Sleep, 1500
    Run, "C:\Program Files\YASB\yasbc.exe" reload, , Hide
Return
!+q::Run, komorebic close, , Hide
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
; move-to-monitor-workspace はフォーカス追従するため focus の追撃は不要
; Monitor 0 (Workspaces 1-5)
!+vk31::Run, komorebic move-to-monitor-workspace 0 0, , Hide
!+vk32::Run, komorebic move-to-monitor-workspace 0 1, , Hide
!+vk33::Run, komorebic move-to-monitor-workspace 0 2, , Hide
!+vk34::Run, komorebic move-to-monitor-workspace 0 3, , Hide
!+vk35::Run, komorebic move-to-monitor-workspace 0 4, , Hide
; Monitor 1 (Workspaces 6-9)
!+vk36::Run, komorebic move-to-monitor-workspace 1 0, , Hide
!+vk37::Run, komorebic move-to-monitor-workspace 1 1, , Hide
!+vk38::Run, komorebic move-to-monitor-workspace 1 2, , Hide
!+vk39::Run, komorebic move-to-monitor-workspace 1 3, , Hide

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

; --- Monitor Hotplug (Auto Reload on Display Change) ---
; WM_DISPLAYCHANGE event (0x007E) to detect monitor plug/unplug
OnMessage(0x007E, "OnDisplayChange")

OnDisplayChange(wParam, lParam)
{
    ; Prevent rapid firing (chattering) by waiting 3 seconds before executing
    SetTimer, ReloadDisplayConfig, -3000
    return
}

ReloadDisplayConfig:
    Run, komorebic.exe replace-configuration "C:\Users\tnaru\komorebi.json", , Hide
    Run, powershell.exe -Command "Stop-Process -Name yasb -Force; Start-Sleep -Seconds 1; Start-Process 'C:\Program Files\YASB\yasb.exe'", , Hide
return

