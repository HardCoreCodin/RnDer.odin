package RnDer

Keyboard :: struct {
    forward, up, right, first, 
    back,  down, left, second,
    hud: struct {
        key_code: u32, 
        is_pressed: bool 
    }
};

createKeyboard :: proc() -> ^Keyboard {
    keyboard: ^Keyboard = Alloc(Keyboard);
    using keyboard;

    up.is_pressed = false;
    down.is_pressed = false;
    left.is_pressed = false;
    right.is_pressed = false;
    forward.is_pressed = false;
    back.is_pressed = false;
    hud.is_pressed = false;
    first.is_pressed = false;
    second.is_pressed = false;

    return keyboard;
};

onKeyDown :: inline proc(using keyboard: ^Keyboard, key_code: u32) {
    switch key_code {
        case hud.key_code:          hud.is_pressed = true;
        case up.key_code:            up.is_pressed = true;
        case down.key_code:        down.is_pressed = true;
        case left.key_code:        left.is_pressed = true;
        case right.key_code:      right.is_pressed = true;
        case forward.key_code:  forward.is_pressed = true;
        case back.key_code:        back.is_pressed = true;
        case first.key_code:      first.is_pressed = true;
        case second.key_code:    second.is_pressed = true;
    }
}

onKeyUp :: inline proc(using keyboard: ^Keyboard, key_code: u32) {
    switch key_code {
        case hud.key_code:          hud.is_pressed = false;
        case up.key_code:            up.is_pressed = false;
        case down.key_code:        down.is_pressed = false;
        case left.key_code:        left.is_pressed = false;
        case right.key_code:      right.is_pressed = false;
        case forward.key_code:  forward.is_pressed = false;
        case back.key_code:        back.is_pressed = false;
        case first.key_code:      first.is_pressed = false;
        case second.key_code:    second.is_pressed = false;
    }
}

MOUSE_CLICK_TICKS :: 10000;

MouseCoords :: struct { 
    x, y: i16, 
    changed: bool 
};
MouseButton :: struct { 
    up, down: struct { 
        ticks: u64, 
        coords: MouseCoords
    }, 
    is_down, clicked: bool
};
Mouse :: struct {
    is_captured, double_clicked: bool,
    wheel: struct { 
        scroll: f32, 
        changed: bool
    },
    coords: struct { 
        absolute, relative: MouseCoords
    },
    buttons: struct { 
        left, right, middle: MouseButton
    }
};

createMouse :: proc() -> ^Mouse {
    mouse: ^Mouse = Alloc(Mouse);
    using mouse;
    using coords;

    is_captured = false;
    double_clicked = false;
    absolute.changed = false;
    relative.changed = false;

    wheel.changed = false;
    wheel.scroll = 0;

    absolute.x = 0;
    absolute.y = 0;
    relative.x = 0;
    relative.y = 0;

    using buttons;
    left.is_down = false;
    left.clicked = false;
    left.up.ticks = 0;
    left.down.ticks = 0;

    right.is_down = false;
    right.clicked = false;
    right.down.ticks = 0;
    right.up.ticks = 0;

    middle.is_down = false;
    middle.clicked = false;
    middle.down.ticks = 0;
    middle.up.ticks = 0;

    return mouse;
}

onMouseMoved :: inline proc(coords: ^MouseCoords, x, y: i16) {
    coords.changed = true;
    coords.x = x;
    coords.y = y;
}

onMouseButtonDown :: inline proc(using button: ^MouseButton, x, y: i16, ticks: u64) {
    down.ticks = ticks;
    down.coords.x = x;
    down.coords.y = y;
    is_down = true;
}

onMouseButtonUp :: inline proc(using button: ^MouseButton, x, y: i16, ticks: u64) {
    up.ticks = ticks;
    up.coords.x = x;
    up.coords.y = y;
    is_down = false;
    clicked = ticks - down.ticks < MOUSE_CLICK_TICKS;
}

onMouseWheelScrolled :: inline proc(using mouse: ^Mouse, scrolled: f32) {
    wheel.scroll = scrolled;
    wheel.changed = true;
}

onMouseMovedAbsolute    :: inline proc(using mouse: ^Mouse, x, y: i16) do onMouseMoved(&coords.absolute, x, y);
onMouseMovedRelative    :: inline proc(using mouse: ^Mouse, x, y: i16) do onMouseMoved(&coords.relative, x, y);
onMouseLeftButtonDown   :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonDown(&buttons.left, x, y, ticks);
onMouseLeftButtonUp     :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonUp(  &buttons.left, x, y, ticks);
onMouseRightButtonDown  :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonDown(&buttons.right, x, y, ticks);
onMouseRightButtonUp    :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonUp(  &buttons.right, x, y, ticks);
onMouseMiddleButtonDown :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonDown(&buttons.middle, x, y, ticks);
onMouseMiddleButtonUp   :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonUp(  &buttons.middle, x, y, ticks);

