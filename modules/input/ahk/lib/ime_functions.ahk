; =============================================================================
; IME 制御関数ライブラリ (IME Control Functions)
; =============================================================================

; -----------------------------------------------------------------------------
; 関数名: IME_GET
; 説明: 現在のIME状態を取得します (1: ON / 0: OFF)．
; -----------------------------------------------------------------------------
IME_GET(WinTitle="A") {
    ControlGet, hwnd, HWND,,, %WinTitle%
    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize ? A_PtrSize : 4
        VarSetCapacity(stGTI, cbSize := 4 + 4 + (ptrSize * 6) + 16, 0)
        NumPut(cbSize, stGTI, 0, "UInt")
        DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", &stGTI)
        hwnd := NumGet(stGTI, 8 + ptrSize, "Ptr") ? NumGet(stGTI, 8 + ptrSize, "Ptr") : hwnd
    }
    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "UPtr", 0x005   ; IMC_GETOPENSTATUS
        , "Ptr", 0)
}

; -----------------------------------------------------------------------------
; 関数名: IME_SET
; 説明: IMEの状態を設定します (1: ON / 0: OFF)．
; -----------------------------------------------------------------------------
IME_SET(setSts, WinTitle="A") {
    ControlGet, hwnd, HWND,,, %WinTitle%
    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize ? A_PtrSize : 4
        VarSetCapacity(stGTI, cbSize := 4 + 4 + (ptrSize * 6) + 16, 0)
        NumPut(cbSize, stGTI, 0, "UInt")
        DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", &stGTI)
        hwnd := NumGet(stGTI, 8 + ptrSize, "Ptr") ? NumGet(stGTI, 8 + ptrSize, "Ptr") : hwnd
    }
    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; WM_IME_CONTROL
        , "UPtr", 0x006   ; IMC_SETOPENSTATUS
        , "Ptr", setSts)
}
