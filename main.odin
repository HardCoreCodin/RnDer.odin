package window_manager;

import win32 "core:sys/win32"
import fmt "core:fmt"

ErrorStr :: cstring;

Window :: struct {
    hInstance : win32.Hinstance,
    hwnd : win32.Hwnd,
    width : u32,
    height : u32,
};

window : ^Window;

WndProc :: proc "std" (
    hwnd : win32.Hwnd, 
    uMsg : u32, 
    wParam : win32.Wparam, 
    lParam : win32.Lparam
) -> win32.Lresult {
    using win32;
    switch (uMsg)
    {
        case WM_DESTROY:
        {
            post_quit_message(0);
            return 0;
        }
        case WM_PAINT:
        {
            ps : Paint_Struct = {};
            hdc : Hdc = begin_paint(hwnd, &ps);

            // fill_rect(hdc, &ps.rcPaint, COLOR_BACKGROUND);

            end_paint(hwnd, &ps);
            return 0;
        }
    }
    return def_window_proc_a(hwnd, uMsg, wParam, lParam);
}

handle_msgs :: proc(window : ^Window) -> bool
{
    using win32;
    msg : Msg = {};
    cont : bool = true;
    for peek_message_a(&msg, nil, 0, 0, PM_REMOVE)
    { 
        if msg.message == WM_QUIT do cont = false;
        translate_message(&msg);
        dispatch_message_a(&msg);
    }
    return cont;
}

main :: proc() {
    using win32;


    target_ticks_per_frame = perf.ticks_per_second / 60;

    // Register the window class.
    CLASS_NAME: cstring = "Main Window";

    wc : Wnd_Class_Ex_A = {}; 

    hInstance := transmute(Hinstance)(get_module_handle_a(nil));

    wc.size = size_of(Wnd_Class_Ex_A);
    wc.wnd_proc = WndProc;
    wc.instance = hInstance;
    wc.class_name = CLASS_NAME;

    if register_class_ex_a(&wc) == 0 do return;

    hwnd := create_window_ex_a(
        0,
        CLASS_NAME,
        windowName,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,

        CW_USEDEFAULT, CW_USEDEFAULT, 640, 480,
        
        nil,
        nil,
        hInstance,
        nil,
    );

    if hwnd == nil do return;

    window := new(Window);
    window.hInstance = hInstance;
    window.hwnd = hwnd;
    window.width = width;
    window.height = height;
}