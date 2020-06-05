package win

foreign import user "system:user32.lib"

@(default_calling_convention = "std")
foreign user {
    GetDC :: proc(
        hWnd: HWND
    ) -> HDC ---;

    LoadCursorA :: proc(
        hInstance    : HINSTANCE,
        lpCursorName : LPSTR
    ) -> HCURSOR ---;

    PeekMessageA :: proc(
        lpMsg         : LPMSG,
        hWnd          : HWND,
        wMsgFilterMin : UINT,
        wMsgFilterMax : UINT,
        wRemoveMsg    : UINT
    ) -> BOOL ---;
    
    TranslateMessage :: proc(
        lpMsg: ^MSG
    ) -> BOOL ---;

    RegisterClassA :: proc(
        lpWndClass: ^WNDCLASSA
    ) -> WORD ---;

    DispatchMessageA :: proc(
        msg: ^MSG
    ) -> LRESULT ---;

    ValidateRgn :: proc(
        hWnd    : HWND,
        hRgn    : HRGN
    ) -> BOOL ---;

    InvalidateRgn :: proc(
        hWnd    : HWND,
        hRgn    : HRGN,
        bErase  : BOOL
    ) -> BOOL ---;

    GetRawInputData :: proc(
        hRawInput   : HRAWINPUT,
        uiCommand   : UINT,
        pData       : LPVOID,
        pcbSize     : PUINT,
        cbSizeHeader: UINT
    ) -> UINT ---;
    
    DefWindowProcA :: proc(
        hWnd   : HWND,
        Msg    : UINT,
        wParam : WPARAM,
        lParam : LPARAM
    ) -> LRESULT ---;

    SetCapture :: proc(hWnd: HWND) -> HWND ---;
    ReleaseCapture :: proc() -> BOOL ---;
    PostQuitMessage :: proc(nExitCode: INT) ---;
    ShowCursor :: proc(bShow: BOOL) ---;
    ShowWindow :: proc(
        hWnd: HWND,
        nCmdShow: INT
    ) -> BOOL ---;

    RegisterRawInputDevices :: proc(
        pRawInputDevices : PCRAWINPUTDEVICE,
        uiNumDevices     : UINT,
        cbSize           : UINT
    ) -> BOOL ---;

    CreateWindowExA :: proc(
        dwExStyle    : DWORD,
        lpClassName  : LPCSTR,
        lpWindowName : LPCSTR,
        dwStyle      : DWORD,
        X            : INT,
        Y            : INT,
        nWidth       : INT,
        nHeight      : INT,
        hWndParent   : HWND,
        hMenu        : HMENU,
        hInstance    : HINSTANCE,
        lpParam      : LPVOID
    ) -> HWND ---;
    
    SetWindowTextA :: proc(
        hWnd     : HWND,
        lpString : LPCSTR
    ) -> BOOL ---;
    
    GetClientRect :: proc(
        hWnd   : HWND,
        lpRect : LPRECT
    ) -> BOOL ---;
}

CreateWindowA :: inline proc(
    lpClassName  : LPCSTR,
    lpWindowName : LPCSTR,
    dwStyle      : DWORD,
    X            : INT,
    Y            : INT,
    nWidth       : INT,
    nHeight      : INT,
    hWndParent   : HWND,
    hMenu        : HMENU,
    hInstance    : HINSTANCE,
    lpParam      : LPVOID
) -> HWND do return CreateWindowExA(
    0,
    lpClassName,
    lpWindowName,
    dwStyle,
    X,
    Y,
    nWidth,
    nHeight,
    hWndParent,
    hMenu,
    hInstance,
    lpParam
);