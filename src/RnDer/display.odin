package RnDer


// Performance Counters:
// =====================

Perf :: struct {
    delta: struct {ticks        : u64, seconds: f32},
    accum: struct {ticks, frames: u64              },
    ticks: struct {before, after: u64},
    avg: struct {
        frames_per_tick, 
        ticks_per_frame: f64,

        frames_per_second, 
        milliseconds_per_frame, 
        microseconds_per_frame, 
        nanoseconds_per_frame: u64
    },
    ticks_per_interval, 
    ticks_per_second: u64,

    seconds_per_tick, 
    milliseconds_per_tick, 
    microseconds_per_tick, 
    nanoseconds_per_tick: f64,

    getTicks: GetTicks
};

createPerf :: proc(getTicksCB: GetTicks, sys_ticks_per_second: u64) -> ^Perf {
    perf := Alloc(Perf); 
    using perf;

    ticks_per_second = sys_ticks_per_second;
    getTicks = getTicksCB;
    ticks.before = getTicks();
    seconds_per_tick = 1.0 / f64(ticks_per_second);
    milliseconds_per_tick = 1000.0 / f64(ticks_per_second);
    microseconds_per_tick = 1000.0 * milliseconds_per_tick;
    nanoseconds_per_tick = 1000.0 * microseconds_per_tick;
    ticks_per_interval = ticks_per_second / 4;

    return perf;
}

accumPerf :: inline proc(using perf: ^Perf) {
    accum.ticks += delta.ticks;
    accum.frames += 1;
}
    
sumPerf :: inline proc(using perf: ^Perf) {
    avg.frames_per_tick = f64(accum.frames) / f64(accum.ticks);
    avg.ticks_per_frame = f64(accum.ticks) / f64(accum.frames);
    avg.frames_per_second = u64(avg.frames_per_tick * f64(ticks_per_second));
    avg.milliseconds_per_frame = u64(f64(avg.ticks_per_frame) * milliseconds_per_tick);
    avg.microseconds_per_frame = u64(f64(avg.ticks_per_frame) * microseconds_per_tick);
    avg.nanoseconds_per_frame = u64(f64(avg.ticks_per_frame) * nanoseconds_per_tick);
    accum.ticks = 0;
    accum.frames = 0;
}

startPerf :: inline proc(using perf: ^Perf) do 
    ticks.before = getTicks();

endPerf :: inline proc(using perf: ^Perf) { 
    ticks.after = getTicks();
    delta.ticks = ticks.after - ticks.before;
    accumPerf(perf);
    sumPerf(perf);
}

startFramePerf :: inline proc (using perf: ^Perf) {
    ticks.after, ticks.before = ticks.before, getTicks();
    delta.ticks = ticks.before - ticks.after;
    delta.seconds = f32(f64(delta.ticks) * seconds_per_tick);
}

endFramePerf :: inline proc(using perf: ^Perf) {
    ticks.after = getTicks();
    delta.ticks = ticks.after - ticks.before;
    accumPerf(perf);
    if accum.ticks >= ticks_per_interval do sumPerf(perf);
}

printPerf :: inline proc(using perf: ^Perf, hud: ^HUD) {
    if accum.ticks != 0 do 
        printNumberIntoString(u16(avg.nanoseconds_per_frame), hud.perf);
}


// Heads-Up Display:
// =================

HUD_LENGTH :: 100;
HUD_WIDTH :: 12;
HUD_RIGHT :: 100;
HUD_TOP :: 10;
HUD_COLOR :: 0x0000FF00;

template :: `Width  : ___1
Height : 2___
FPS    : 3___
Ms/F   : 4___
Mode   :  5__
Rat    :  6__
Perf   : 7___`;

HUD ::struct {
    text: [len(template)]u8,
    width, height, fps, msf, mode, rat, perf: []u8,
    is_visible: bool,
    debug_perf: ^Perf
};

setControllerModeInHUD :: proc(using hud: ^HUD, is_fps: bool) {
    mode[0] = is_fps ? 'F' : 'O';
    mode[1] = is_fps ? 'p' : 'r';
    mode[2] = is_fps ? 's' : 'b';
}

setRationalModeInHUD :: proc(using hud: ^HUD, is_rat: bool) {
    rat[0] = 'O';
    rat[1] = is_rat ? 'N' : 'f';
    rat[2] = is_rat ? ' ' : 'f';
}

createHUD :: proc() -> ^HUD {
    hud := Alloc(HUD);
    using hud;

    is_visible = true;

    for c, i in template {
        switch c {
            case '1':  width  = text[i:i+4];
            case '2':  height = text[i:i+4];
            case '3':  fps    = text[i:i+4];
            case '4':  msf    = text[i:i+4];
            case '5':  mode   = text[i:i+3];
            case '6':  rat    = text[i:i+3];
            case '7':  perf   = text[i:i+4];
        }
        text[i] = u8(c);
    }

    setControllerModeInHUD(hud, false);
    setRationalModeInHUD(hud, false);

    return hud;
}

updateHUDCounters :: proc(hud: ^HUD, perf: ^Perf) {
    printNumberIntoString(u16(perf.avg.frames_per_second), hud.fps);
    printNumberIntoString(u16(perf.avg.milliseconds_per_frame), hud.msf);
}

updateHUDDimensions :: proc "contextless" (hud: ^HUD, frame_buffer: ^FrameBuffer) {
    printNumberIntoString(frame_buffer.width, hud.width);
    printNumberIntoString(frame_buffer.height, hud.height);
}
