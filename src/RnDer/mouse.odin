package RnDer

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

onMouseMovedAbsolute :: inline proc(using mouse: ^Mouse, X, Y: i16) {
	using coords.absolute;
    changed = true;
    x = X;
    y = Y;
}

onMouseMovedRelative :: inline proc(using mouse: ^Mouse, dx, dy: i16) {
	using coords.relative;
    changed = true;
    x += dx;
    y += dy;
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

onMouseLeftButtonDown   :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonDown(&buttons.left, x, y, ticks);
onMouseLeftButtonUp     :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonUp(  &buttons.left, x, y, ticks);
onMouseRightButtonDown  :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonDown(&buttons.right, x, y, ticks);
onMouseRightButtonUp    :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonUp(  &buttons.right, x, y, ticks);
onMouseMiddleButtonDown :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonDown(&buttons.middle, x, y, ticks);
onMouseMiddleButtonUp   :: inline proc(using mouse: ^Mouse, x, y: i16, ticks: u64) do onMouseButtonUp(  &buttons.middle, x, y, ticks);