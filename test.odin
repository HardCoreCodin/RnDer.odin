package test

import "core:mem"
import "core:fmt"


// Kilobytes :: inline proc(value: int) -> int do return 1024 * value;
// Megabytes :: inline proc(value: int) -> int do return 1024 * Kilobytes(value);
// Gigabytes :: inline proc(value: int) -> int do return 1024 * Megabytes(value);
// Terabytes :: inline proc(value: int) -> int do return 1024 * Gigabytes(value);

// MEMORY_SIZE := Gigabytes(1);
// MEMORY_BASE := Terabytes(2);
// DEFAULT_ALIGNMENT :: 2 * size_of(^u8);

// MemoryArena :: struct {
//     current, capacity, occupied, allocation_count: int,
//     start: ^u8
// };

// arena_init :: proc(using memory_arena: ^MemoryArena, size: int, ptr: rawptr) {
// 	start = cast(^u8)ptr;
// 	capacity = size;
// 	current = 0;
// 	occupied = 0;
// 	allocation_count = 0;
// }

// arena_allocate :: proc(using 
//     memory_arena: ^MemoryArena, 
//     size: int,
//     alignment: int = DEFAULT_ALIGNMENT
// ) -> ^u8 {
//     if alignment & (alignment - 1) != 0 do return nil;

//     allocation_size := size; 
//     modulo := (alignment - 1) & current;
//     if modulo != 0 do allocation_size += alignment - modulo;

//     occupied += allocation_size;
//     if occupied > capacity do return nil;

// 	address := cast(^u8)uintptr(int(uintptr(start)) + current);

//     allocation_count += 1;
//     current += allocation_size;

//     return address;
// }

// arena_deallocate :: proc(using memory_arena: ^MemoryArena) {
//     switch allocation_count {
//         case 0: return;
//         case 1: 
//             allocation_count = 0; 
//             current = 0;
//         case:
//             allocation_count -= 1;
//     }
// }

// Alloc :: inline proc($T: typeid) -> ^T do 
//     return cast(^T)arena_allocate(&memory, size_of(T));

// memory: MemoryArena;

// 

// sqrtf :: proc(number: f32) -> f32 {
//     i: i32;
//     x, y: f32;
//     x = number * 0.5;
//     y = number;
//     i = (cast(^i32)(&y))^;
//     i = 0x5f3759df - (i >> 1);
//     y = (cast(^f32)(&i))^;
//     y = y * (1.5 - (x * y * y));
//     y = y * (1.5 - (x * y * y));
    
//     return number * y;
// }

// UpdateWindowTitle :: proc();

// my_proc: UpdateWindowTitle;


HUD_LENGTH :: 100;
HUD_WIDTH :: 12;
HUD_RIGHT :: 100;
HUD_TOP :: 10;
HUD_COLOR :: 0x0000FF00;
HUD_String :: struct {data: ^byte, len:  int};

template :: "Width  : 1___\nHeight : 2___\nFPS    : 3___\nMs/F   : 4___\nMode   :  5__\nRat    :  6__\nPerf   : 7___";

	
HUD ::struct {
    text: [len(template)]byte,
    str: string,
    labels: struct { width, height, fps, msf, mode, rat, perf: []byte},
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
    hud := new(HUD);
    using hud;

    is_visible = true;
    str = transmute(string)HUD_String{&text[0], len(template)};

    using labels;
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

updateHUDCounters :: proc(using hud: ^HUD, perf: ^Perf) {
    printNumberIntoString(uint(perf.avg.frames_per_second), labels.fps);
    printNumberIntoString(uint(perf.avg.milliseconds_per_frame), labels.msf);
}
updateHUDDimensions :: proc(using hud: ^HUD, width, height: u32) {
    printNumberIntoString(uint(width), labels.width);
    printNumberIntoString(uint(height), labels.height);
}

printNumberIntoString :: proc (
    number: uint, 
    slice: []byte
) {
    last := len(slice) - 1;
    if number == 0 {
        for i in 0..<last do slice[i] = ' ';
        slice[last] = '0';
    } else {
        prior := number;
        current := number;
        for i := last; i >= 0; i -= 1 {
            if current > 0 {
                prior = current;
                current /= 10;
                chr := '0' + prior - current * 10;
                slice[i] = u8(chr);
            } else do slice[i] = ' ';
        }
    }
}
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
    nanoseconds_per_tick: f64
};

import strings "core:strings"

main :: proc() {
	// size :: 1024;
	// ram: [size]byte;

	// arena_init(&memory, size, &ram[0]);

	// v: ^Vector2 = Alloc(Vector2);
	// v.x = 123;
	// v.y = 567.89;

	// count :: 5;
	// vs: ^[count]Vector2 = Alloc([count]Vector2);
	// fmt.println(vs^);
	Color :: struct #packed { B, G, R, A: u8 };
	Pixel :: struct #raw_union { color: Color, value: u32};
	vec3 :: struct {x,y,z: f32};
	arr: [5]Pixel;
	ap:= &arr;

    for i in 0..<5 do
        arr[i].value = 2;
	fmt.println(arr[2].color);
	// changer(arr[:]);
	// fmt.println(arr[2]);

	// // arr[2].x = 2;

	// for i in 0..<len(ap) do fmt.println(ap[i]);	

	// p :: proc() {
	// 	fmt.println(sqrtf(81));			
	// }

	// my_proc = p;
	// my_proc();

	// perf: Perf;
	// perf.avg.frames_per_second = 59;
	// perf.avg.milliseconds_per_frame = 17;

	// hud := createHUD();

	// updateHUDDimensions(hud, 640, 480);
	// updateHUDCounters(hud, &perf);

	// setControllerModeInHUD(hud, true);
	// setRationalModeInHUD (hud, true);

	// fmt.println(hud.str);
}