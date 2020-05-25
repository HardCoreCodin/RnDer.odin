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