/*
    =============================================================================
    komorebi & YASB 用 AutoHotkey スクリプト (GlazeWM のキーバインド再現)
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

; --- フォーカス移動 ---
!h::Run, komorebic focus left, , Hide
!l::Run, komorebic focus right, , Hide
!k::Run, komorebic focus up, , Hide
!j::Run, komorebic focus down, , Hide

; --- ウィンドウ移動 (スワップ) ---
!+h::Run, komorebic move left, , Hide
!+l::Run, komorebic move right, , Hide
!+k::Run, komorebic move up, , Hide
!+j::Run, komorebic move down, , Hide

; --- リサイズ (GlazeWM の alt+u/p/o/i を再現) ---
; komorebi 0.1.41 でピクセル指定が廃止され increase/decrease に変更。
; resize-edge は対象辺が画面端だと無効なため、位置に依らず効く resize-axis を使う
!u::Run, komorebic resize-axis horizontal decrease, , Hide
!p::Run, komorebic resize-axis horizontal increase, , Hide
!o::Run, komorebic resize-axis vertical increase, , Hide
!i::Run, komorebic resize-axis vertical decrease, , Hide

; --- ウィンドウ操作 ---
!f::Run, komorebic toggle-monocle, , Hide
!m::Run, komorebic minimize, , Hide
!t::Run, komorebic toggle-tiling, , Hide
!b::Run, komorebic flip-layout horizontal-and-vertical, , Hide
!r::Run, komorebic retile, , Hide
; モニタ再接続で表示が崩れたとき等に手動で復旧 (自動復旧と同じ処理)
!+r::Gosub, ReapplyDisplayConfig

!+q::Run, komorebic close, , Hide
!+w::Run, komorebic close, , Hide

; --- 追跡から外れたウィンドウの手動復旧 ---
; komorebi は WinEvent 通知の取りこぼしで稀にウィンドウの追跡を失うことがある。
; その場でフォーカス中のウィンドウを再登録できるようにする。
!+m::Run, komorebic manage, , Hide

; --- ワークスペース (巡回) ---
!a::Run, komorebic cycle-workspace previous, , Hide
!s::Run, komorebic cycle-workspace next, , Hide

; --- ワークスペース (直接ジャンプ) ---
; モニタ0 (ワークスペース 1-5)
!1::Run, komorebic focus-monitor-workspace 0 0, , Hide
!2::Run, komorebic focus-monitor-workspace 0 1, , Hide
!3::Run, komorebic focus-monitor-workspace 0 2, , Hide
!4::Run, komorebic focus-monitor-workspace 0 3, , Hide
!5::Run, komorebic focus-monitor-workspace 0 4, , Hide
; モニタ1 (ワークスペース 6-9)
!6::Run, komorebic focus-monitor-workspace 1 0, , Hide
!7::Run, komorebic focus-monitor-workspace 1 1, , Hide
!8::Run, komorebic focus-monitor-workspace 1 2, , Hide
!9::Run, komorebic focus-monitor-workspace 1 3, , Hide

; --- ワークスペース (ウィンドウを移動してフォーカス追従) ---
; move-to-monitor-workspace はフォーカス追従するため focus の追撃は不要
; モニタ0 (ワークスペース 1-5)
!+vk31::Run, komorebic move-to-monitor-workspace 0 0, , Hide
!+vk32::Run, komorebic move-to-monitor-workspace 0 1, , Hide
!+vk33::Run, komorebic move-to-monitor-workspace 0 2, , Hide
!+vk34::Run, komorebic move-to-monitor-workspace 0 3, , Hide
!+vk35::Run, komorebic move-to-monitor-workspace 0 4, , Hide
; モニタ1 (ワークスペース 6-9)
!+vk36::Run, komorebic move-to-monitor-workspace 1 0, , Hide
!+vk37::Run, komorebic move-to-monitor-workspace 1 1, , Hide
!+vk38::Run, komorebic move-to-monitor-workspace 1 2, , Hide
!+vk39::Run, komorebic move-to-monitor-workspace 1 3, , Hide

; --- ワークスペースごとモニタへ移動 ---
!+a::Run, komorebic move-workspace-to-monitor 0, , Hide
!+f::Run, komorebic move-workspace-to-monitor 1, , Hide

; --- アプリ起動 ---
; ALT+Y: WezTerm で yazi
!y::Run, wezterm-gui start -- wsl.exe --cd ~ -e zsh -ic yazi
; ALT+V: Vivaldi
!v::Run, C:\Users\tnaru\AppData\Local\Vivaldi\Application\vivaldi.exe

; --- Alt+Enter で WezTerm (Excel では無効) ---
#IfWinNotActive ahk_exe EXCEL.EXE
!Enter::
    Run, wezterm-gui
Return
#IfWinNotActive

; --- モニタ抜き差し時の自動復旧処理本体 ---
ReapplyDisplayConfig:
    ; reload-configuration では再検出モニタにワークスペース定義が再適用
    ; されないため、replace-configuration で明示的に再適用する
    Run, komorebic replace-configuration "C:\Users\tnaru\.config\komorebi\komorebi.json", , Hide
    ; 再適用完了を待つ (早すぎると YASB が古い状態を読んで再構築する)
    Sleep, 4000
    ; YASB のウィジェットも watch_config 経由で再構築 (バー再起動なし)
    Run, %ComSpec% /c copy /y "C:\Users\tnaru\.config\yasb\config.yaml" "%A_Temp%\yasb-reapply.yaml" & copy /y "%A_Temp%\yasb-reapply.yaml" "C:\Users\tnaru\.config\yasb\config.yaml", , Hide
    Sleep, 2000
    ; komorebi イベントを発火させて YASB のラベルを最新状態に更新する
    ; (ALT+6 で治るのと同じ原理。focus-monitor 0 は実害のない no-op)
    Run, komorebic focus-monitor 0, , Hide
Return

