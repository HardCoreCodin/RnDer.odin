package main

import "RnDer"

engine: ^RnDer.Engine;
default_context: runtime.Context;

when ODIN_OS == "windows" {
    import "core:runtime"
    import win "platforms/windows"

    window_class: win.WNDCLASSA;
    window: win.HWND;
    win_dc: win.HDC;
    info: win.BITMAPINFO;
    win_rect: win.RECT;

    raw_inputs: ^win.RAWINPUT;
    raw_input_handle: win.HRAWINPUT;
    raw_input_device: win.RAWINPUTDEVICE;
    raw_input_size: win.UINT;
    raw_input_size_ptr: win.PUINT = cast(win.PUINT)(&raw_input_size); 
    raw_input_header_size: win.UINT = size_of(win.RAWINPUTHEADER);

    getRawInput :: inline proc(data: win.LPVOID = nil) -> win.UINT do return
        win.GetRawInputData(raw_input_handle, win.RID_INPUT, data, raw_input_size_ptr, raw_input_header_size);

    hasRawInput :: inline proc() -> bool do return getRawInput() == 0 && raw_input_size != 0;
    hasRawMouseInput :: inline proc(lParam: win.LPARAM) -> bool {
        raw_input_handle = transmute(win.HRAWINPUT)(uintptr(win.INT(lParam)));
        return (
            hasRawInput() &&
            getRawInput(win.LPVOID(raw_inputs)) == raw_input_size && 
            raw_inputs.header.dwType == win.RIM_TYPEMOUSE
        );
    }

    ticks_of_last_frame, ticks_of_current_frame, target_ticks_per_frame: u64;
    perf_counter: win.LARGE_INTEGER;

    printDebugString :: proc(str: cstring) { 
        win.OutputDebugStringA(win.LPCSTR(str)); 
    }

    updateWindowTitle :: proc() {
        win.SetWindowTextA(window, engine.active_viewport.renderer.title); 
    }
    
    getTicks :: proc() -> u64 { 
        win.QueryPerformanceCounter(&perf_counter); 
        return u64(perf_counter.QuadPart); 
    }

    WndProc:: proc "std" (
        hWnd: win.HWND, 
        message: win.UINT, 
        wParam: win.WPARAM, 
        lParam: win.LPARAM
    ) -> win.LRESULT {
        context = default_context;

        using win;
        using RnDer;
        using engine;
        using frame_buffer;

        switch message {
            case WM_DESTROY:
                is_running = false;
                PostQuitMessage(0);

            case WM_SIZE:
                GetClientRect(window, &win_rect);

                using info.bmiHeader;
                biWidth = win_rect.right - win_rect.left;
                biHeight = win_rect.top - win_rect.bottom;

                width = u16(biWidth);
                height = u16(-biHeight);
                size = u32(width) * u32(height);

                resize(engine);
                updateAndRender(engine);

            case WM_PAINT:
                updateAndRender(engine);

                ticks_of_current_frame = getTicks();
                for (ticks_of_current_frame - ticks_of_last_frame < target_ticks_per_frame) do
                    ticks_of_current_frame = getTicks();

                SetDIBitsToDevice(win_dc,
                    0, 0, DWORD(width), DWORD(height),
                    0, 0, 0, UINT(height),
                    cast(^u32)(pixels), 
                    &info, DIB_RGB_COLORS
                );

                ValidateRgn(window, nil);

                ticks_of_last_frame = getTicks();

            case WM_SYSKEYDOWN, WM_KEYDOWN:
                if u32(wParam) == VK_ESCAPE do
                    is_running = false;
                else do
                    onKeyDown(keyboard, u32(wParam));

            case WM_SYSKEYUP, WM_KEYUP:
                onKeyUp(keyboard, u32(wParam));

            case WM_LBUTTONDOWN:
                QueryPerformanceCounter(&perf_counter);
                onMouseLeftButtonDown(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)), u64(perf_counter.QuadPart));

            case WM_RBUTTONDOWN:
                QueryPerformanceCounter(&perf_counter);
                onMouseRightButtonDown(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)), u64(perf_counter.QuadPart));
                mouse.is_captured = true;
                SetCapture(window);
                ShowCursor(false);

            case WM_MBUTTONDOWN:
                QueryPerformanceCounter(&perf_counter);
                onMouseMiddleButtonDown(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)), u64(perf_counter.QuadPart));
                mouse.is_captured = true;
                SetCapture(window);
                ShowCursor(false);

            case WM_LBUTTONUP:
                QueryPerformanceCounter(&perf_counter);
                onMouseLeftButtonUp(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)), u64(perf_counter.QuadPart));

            case WM_RBUTTONUP:
                QueryPerformanceCounter(&perf_counter);
                onMouseRightButtonUp(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)), u64(perf_counter.QuadPart));
                mouse.is_captured = false;
                ReleaseCapture();
                ShowCursor(true);

            case WM_MBUTTONUP:
                QueryPerformanceCounter(&perf_counter);
                onMouseMiddleButtonUp(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)), u64(perf_counter.QuadPart));
                mouse.is_captured = false;
                ReleaseCapture();
                ShowCursor(true);

            case WM_LBUTTONDBLCLK:
                mouse.double_clicked = true;
                if mouse.is_captured {
                    mouse.is_captured = false;
                    ReleaseCapture();
                    ShowCursor(true); 
                } else {
                    mouse.is_captured = true;
                    SetCapture(window);
                    ShowCursor(false);
                }

            case WM_MOUSEWHEEL:
                onMouseWheelScrolled(mouse, f32(GET_WHEEL_DELTA_WPARAM(wParam)) / f32(WHEEL_DELTA));

            case WM_MOUSEMOVE:
                onMouseMovedAbsolute(mouse, i16(GET_X_LPARAM(lParam)), i16(GET_Y_LPARAM(lParam)));

            case WM_INPUT:
                if hasRawMouseInput(lParam) {
                    using raw_inputs.data.mouse;
                    if lLastX != 0 || lLastY != 0 do
                        onMouseMovedRelative(mouse, i16(lLastX), i16(lLastY));
                }

            case:
                return DefWindowProcA(hWnd, message, wParam, lParam);
        }

        return 0;
    }

    run :: proc() {
        default_context = runtime.default_context();

        using win;
        using RnDer;


        // Initialize the memory:
        address := VirtualAlloc(
                LPVOID(uintptr(MEMORY_BASE)),
                u64(MEMORY_SIZE),
                MEM_RESERVE|MEM_COMMIT, PAGE_READWRITE);
        when ODIN_DEBUG do assert(address != nil, "Failed to allocate virtual memory!");

        memory.address = cast(^u8)address;
    
        performance_frequency: LARGE_INTEGER;
        QueryPerformanceFrequency(&performance_frequency);
        engine = createEngine(updateWindowTitle, printDebugString, getTicks, u64(performance_frequency.QuadPart));

        WINDOW_CLASS: cstring = "RnDer";
        HInstance := transmute(HINSTANCE)(GetModuleHandleA(nil));
        
        target_ticks_per_frame = engine.perf.ticks_per_second / 60;

        using engine;

        keyboard.up.key_code      = 'R';
        keyboard.down.key_code    = 'F';
        keyboard.left.key_code    = 'A';
        keyboard.right.key_code   = 'D';
        keyboard.forward.key_code = 'W';
        keyboard.back.key_code    = 'S';
        keyboard.first.key_code   = '1';
        keyboard.second.key_code  = '2';
        keyboard.hud.key_code     = VK_TAB;

        using info.bmiHeader;
        biSize        = size_of(info.bmiHeader);
        biCompression = BI_RGB;
        biBitCount    = 32;
        biPlanes      = 1;

        using window_class;
        lpszClassName  = WINDOW_CLASS;
        hInstance      = HInstance;
        lpfnWndProc    = WndProc;
        style          = CS_OWNDC|CS_HREDRAW|CS_VREDRAW|CS_DBLCLKS;
        hCursor        = LoadCursorA(nil, IDC_ARROW);

        RegisterClassA(&window_class);

        window = CreateWindowA(
                WINDOW_CLASS,
                engine.active_viewport.renderer.title, WS_OVERLAPPEDWINDOW,
                CW_USEDEFAULT,
                CW_USEDEFAULT,
                500, 400, 
                nil, nil, hInstance, nil
        );
        when ODIN_DEBUG do assert(window != nil, "Failed to create window!");

        raw_inputs = cast(^RAWINPUT)(allocate(Kilobytes(1)));
        // raw_inputs = cast(^RAWINPUT)(arena_allocate(&memory, Kilobytes(1)));

        raw_input_device.usUsagePage = 0x01;
        raw_input_device.usUsage = 0x02;
        err := RegisterRawInputDevices(&raw_input_device, 1, size_of(raw_input_device));
        when ODIN_DEBUG do assert(bool(err), "Failed to register raw input device!");

        win_dc = GetDC(window);
        ShowWindow(window, 10);

        message: MSG;
        ticks_of_last_frame = getTicks();

        for is_running {
            for PeekMessageA(&message, nil, 0, 0, PM_REMOVE) {
                TranslateMessage(&message);
                DispatchMessageA(&message);
            }
            InvalidateRgn(window, nil, false);
        }
    }
}

main :: proc() {
    run();
}