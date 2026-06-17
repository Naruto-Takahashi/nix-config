/*
    =============================================================================
    メイン AutoHotkey スクリプト (Main AutoHotkey Script)
    説明: キーのリマッピング，Vimライクなカーソル移動，およびIME制御の統合
    =============================================================================
*/

; =============================================================================
; 1. グローバル設定 (Global Settings)
; =============================================================================
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; 外部ライブラリの読み込み (IME制御関数群)
#Include %A_ScriptDir%\lib\ime_functions.ahk

; =============================================================================
; 2. キー・リマッピング設定 (Key Remappings)
; =============================================================================

; --- CapsLock単押しでEscape（かつIME OFF），長押しでCtrl化 ---
; ※レジストリや他ソフト等で CapsLock が F13 にマップされていることを前提とします．
*F13::
    Send, {LCtrl down}
    KeyWait, F13
    Send, {LCtrl up}
    if (A_PriorKey == "F13") {
        SendInput, {Esc}
        Sleep 10
        IME_SET(0) ; 英語入力（IME OFF）へ強制切り替え
    }
Return

; --- 物理左Controlキー単押しでEscape（かつIME OFF）にする設定 ---
~LCtrl Up::
    if (A_PriorKey == "LControl") {
        SendInput, {Esc}
        Sleep 10
        IME_SET(0) ; 英語入力（IME OFF）へ強制切り替え
    }
Return

; =============================================================================
; 3. スペースキー拡張設定 (SandS & Vim Mode)
; =============================================================================

; --- SandS (Space and Shift) 挙動の定義 ---
; 単押し時：スペース文字を出力
Space Up::Send, {Space}
; Shift + Space時：スペース文字を出力（連続入力可能）
+Space::Send, {Space}

; --- Vim風カーソル移動 (Space + HJKL) ---
Space & h::Send {Blind}{Left}
; NOTE: 下方向への移動
Space & j::Send {Blind}{Down}
; NOTE: 上方向への移動
Space & k::Send {Blind}{Up}
Space & l::Send {Blind}{Right}

; --- ナビゲーションの拡張定義 ---
Space & a::Send {Blind}{Home} ; 行頭移動
Space & e::Send {Blind}{End}  ; 行末移動

; --- テキスト編集用ショートカット ---
Space & u:: Send, ^z          ; 元に戻す (Undo)
Space & b:: Send, {Backspace} ; バックスペース (Backspace)
Space & x:: Send, {Delete}    ; デリート (Delete)
^Space::    Send, ^{Space}    ; Ctrl + Space のパススルー（衝突回避）
!Space::    Send, !{Space}    ; Alt + Space のパススルー（衝突回避）

; =============================================================================
; 4. 仮想デスクトップ操作 (Virtual Desktop Operations)
; =============================================================================

; --- 仮想デスクトップの切り替え (次へ) ---
; 右Winキーまたは右Ctrlキー単押しで動作
RWin:: Send, {LWin down}{LCtrl down}{Right}{LCtrl up}{LWin up}
RCtrl::Send, {LWin down}{LCtrl down}{Right}{LCtrl up}{LWin up}

; --- アクティブウィンドウを次のデスクトップへ移動 ---
; Alt + 右Winキーまたは右Ctrlキーで動作
!RWin:: SendInput, {LWin down}{LCtrl down}{LAlt down}{Right}{LAlt up}{LCtrl up}{LWin up}
!RCtrl::SendInput, {LWin down}{LCtrl down}{LAlt down}{Right}{LAlt up}{LCtrl up}{LWin up}

; =============================================================================
; 5. IME制御 & Vim連携 (IME & Vim Integration)
; =============================================================================

; --- Mac風のAltキー単押しによるIME切り替え ---
; 左Alt単押し：英語入力（IME OFF）
~LAlt Up::
    if (A_PriorHotkey == "~LAlt")
        IME_SET(0)
    Return
~LAlt::SendInput, {vkE8} ; キーの衝突防止ダミー出力を送信

; 右Alt単押し：日本語入力（IME ON）
~RAlt Up::
    if (A_PriorHotkey == "~RAlt")
        IME_SET(1)
    Return
~RAlt::SendInput, {vkE8} ; キーの衝突防止ダミー出力を送信

; --- Escapeキー押下時に強制的にIMEをOFFにする設定 ---
$Esc::
    SendInput, {LCtrl up}{RCtrl up}{Esc}
    Sleep 10 ; Escapeキーの入力を確実に処理させるための微小ディレイ
    IME_SET(0)
Return

; --- Ctrl + [ 押下時にEscapeかつIMEをOFFにする設定 (Vim/Neovim互換) ---
^[::
    SendInput, {LCtrl up}{RCtrl up}{Esc}
    Sleep 10
    IME_SET(0)
Return

; =============================================================================
; 6. アプリケーション個別ショートカット (Application Shortcuts)
; =============================================================================

; --- Alt + Enter で WezTerm を起動する設定（Excelでのセル内改行を邪魔しないよう除外） ---
#IfWinNotActive ahk_exe EXCEL.EXE
!Enter::
    Run, wezterm-gui
Return
#IfWinNotActive

; =============================================================================
; 7. エクスプローラー統合 (Everything検索連携)
; =============================================================================

#IfWinActive ahk_class CabinetWClass
; エクスプローラー上で Ctrl + F を押した際，開いているフォルダパスを対象に Everything で検索する
^f::
    path := GetExplorerPath()
    if (path) {
        ; TODO: Everything 1.5a のパスが異なる場合は適宜書き換える
        everythingPath := "C:\Program Files\Everything 1.5a\Everything.exe"
        
        if FileExist(everythingPath) {
            Run, "%everythingPath%" -path "%path%"
        } else {
            MsgBox, 16, エラー, Everything 1.5a が以下のパスに見つかりませんでした．:`n%everythingPath%`n`nインストールパスをご確認ください．
        }
    } else {
        Send, ^f
    }
Return
#IfWinActive

; アクティブなエクスプローラーから現在のカレントディレクトリパスを取得する関数
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
