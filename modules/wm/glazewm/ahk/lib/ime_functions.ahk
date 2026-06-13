; =============================================================================
; IME Control Functions
; =============================================================================

; -----------------------------------------------------------------------------
; Function: IME_GET
; Description: Returns the current IME status (1: ON, 0: OFF).
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
; Function: IME_SET
; Description: Sets the IME status (1: ON, 0: OFF).
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
