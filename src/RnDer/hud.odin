package RnDer

HUD_WIDTH :: 12;
HUD_RIGHT :: 100;
HUD_TOP :: 10;
String :: struct {data: ^byte, len:  int};

template :: `
Width  : 1___
Height : 2___
FPS    : 3___
Ms/F   : 4___
Mode   :  5__
Rat    :  6__
Zoom   : 7___`;

	
HUD ::struct {
	_buf: [len(template)]byte
    text: []byte,
    str: string,
    pixel: Pixel,
    labels: struct { width, height, fps, msf, mode, rat, zoom, perf: []byte},
    is_visible: bool,
    debug_perf: ^Perf
};

setControllerModeInHUD :: proc(using hud: ^HUD, is_fps: bool) {
    using labels;
    mode[0] = is_fps ? 'F' : 'O';
    mode[1] = is_fps ? 'p' : 'r';
    mode[2] = is_fps ? 's' : 'b';
}

setRationalModeInHUD :: proc(using hud: ^HUD, is_rat: bool) {
	using labels;
    rat[0] = 'O';
    rat[1] = is_rat ? 'N' : 'f';
    rat[2] = is_rat ? ' ' : 'f';
}

createHUD :: proc() -> ^HUD {
    hud := Alloc(HUD);
    using hud;

    is_visible = true;
    text = _buf[:];
    str = transmute(string)String{&_buf[0], len(text)};
	pixel.color.G = 0xFF;

    using labels;
    for c, i in template {
        switch c {
            case '1':  width  = _buf[i:i+4];
            case '2':  height = _buf[i:i+4];
            case '3':  fps    = _buf[i:i+4];
            case '4':  msf    = _buf[i:i+4];
            case '5':  mode   = _buf[i:i+3];
            case '6':  rat    = _buf[i:i+3];
            case '7':  zoom   = _buf[i:i+4];
        }
        _buf[i] = byte(c);
    }

    setControllerModeInHUD(hud, false);
    setRationalModeInHUD(hud, false);

    return hud;
}

updateHUDCounters :: proc(using hud: ^HUD, perf: ^Perf) {
    printNumberIntoString(u16(perf.avg.frames_per_second), labels.fps);
    printNumberIntoString(u16(perf.avg.milliseconds_per_frame), labels.msf);
}

updateHUDDimensions :: proc(using hud: ^HUD, width, height: u16) {
    printNumberIntoString(width, labels.width);
    printNumberIntoString(height, labels.height);
}

updateHUDZoom :: proc(using hud: ^HUD, zoom_amount: f32) {
	zoom :=  u16(zoom_amount < 0 ? 0 : (zoom_amount < 1 ? 1 / zoom_amount : zoom_amount)); 
	printNumberIntoString(zoom, labels.zoom);
}