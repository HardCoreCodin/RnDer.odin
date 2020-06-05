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
import "core:runtime"

foreign { @(link_name="llvm.readcyclecounter") getCycleCount :: proc "c" () -> u64 ---}

foreign import PowrProf "system:PowrProf.lib"
WORD      :: distinct u16;
DWORD     :: distinct u32;
DWORD_PTR :: distinct ^u32;
LONG      :: distinct i32;
ULONG     :: distinct u32;
LPLONG    :: distinct ^i64;
LONGLONG  :: distinct i64;
SHORT     :: distinct i16;
USHORT    :: distinct u16;
INT       :: distinct i32;
UINT      :: distinct u32;
UINT_PTR  :: distinct u64;
PUINT     :: distinct ^u32;
LONG_PTR  :: distinct i64;
ULONG_PTR :: distinct ^u32;
PVOID     :: distinct rawptr;
LPVOID    :: distinct rawptr;
NTSTATUS  :: u32;
POWER_INFORMATION_LEVEL :: enum {
  SystemPowerPolicyAc,
  SystemPowerPolicyDc,
  VerifySystemPolicyAc,
  VerifySystemPolicyDc,
  SystemPowerCapabilities,
  SystemBatteryState,
  SystemPowerStateHandler,
  ProcessorStateHandler,
  SystemPowerPolicyCurrent,
  AdministratorPowerPolicy,
  SystemReserveHiberFile,
  ProcessorInformation,
  SystemPowerInformation,
  ProcessorStateHandler2,
  LastWakeTime,
  LastSleepTime,
  SystemExecutionState,
  SystemPowerStateNotifyHandler,
  ProcessorPowerPolicyAc,
  ProcessorPowerPolicyDc,
  VerifyProcessorPowerPolicyAc,
  VerifyProcessorPowerPolicyDc,
  ProcessorPowerPolicyCurrent,
  SystemPowerStateLogging,
  SystemPowerLoggingEntry,
  SetPowerSettingValue,
  NotifyUserPowerSetting,
  PowerInformationLevelUnused0,
  SystemMonitorHiberBootPowerOff,
  SystemVideoState,
  TraceApplicationPowerMessage,
  TraceApplicationPowerMessageEnd,
  ProcessorPerfStates,
  ProcessorIdleStates,
  ProcessorCap,
  SystemWakeSource,
  SystemHiberFileInformation,
  TraceServicePowerMessage,
  ProcessorLoad,
  PowerShutdownNotification,
  MonitorCapabilities,
  SessionPowerInit,
  SessionDisplayState,
  PowerRequestCreate,
  PowerRequestAction,
  GetPowerRequestList,
  ProcessorInformationEx,
  NotifyUserModeLegacyPowerEvent,
  GroupPark,
  ProcessorIdleDomains,
  WakeTimerList,
  SystemHiberFileSize,
  ProcessorIdleStatesHv,
  ProcessorPerfStatesHv,
  ProcessorPerfCapHv,
  ProcessorSetIdle,
  LogicalProcessorIdling,
  UserPresence,
  PowerSettingNotificationName,
  GetPowerSettingValue,
  IdleResiliency,
  SessionRITState,
  SessionConnectNotification,
  SessionPowerCleanup,
  SessionLockState,
  SystemHiberbootState,
  PlatformInformation,
  PdcInvocation,
  MonitorInvocation,
  FirmwareTableInformationRegistered,
  SetShutdownSelectedTime,
  SuspendResumeInvocation,
  PlmPowerRequestCreate,
  ScreenOff,
  CsDeviceNotification,
  PlatformRole,
  LastResumePerformance,
  DisplayBurst,
  ExitLatencySamplingPercentage,
  RegisterSpmPowerSettings,
  PlatformIdleStates,
  ProcessorIdleVeto,
  PlatformIdleVeto,
  SystemBatteryStatePrecise,
  ThermalEvent,
  PowerRequestActionInternal,
  BatteryDeviceState,
  PowerInformationInternal,
  ThermalStandby,
  SystemHiberFileType,
  PhysicalPowerButtonPress,
  QueryPotentialDripsConstraint,
  EnergyTrackerCreate,
  EnergyTrackerQuery,
  UpdateBlackBoxRecorder,
  SessionAllowExternalDmaDevices,
  PowerInformationLevelMaximum
};

PROCESSOR_POWER_INFORMATION :: struct {
  Number,
  MaxMhz,
  CurrentMhz,
  MhzLimit,
  MaxIdleState,
  CurrentIdleState: ULONG
};

foreign import kernel "system:kernel32.lib"

SYSTEM_INFO :: struct {
  DUMMYUNIONNAME: struct #raw_union {
    dwOemId: DWORD,
    DUMMYSTRUCTNAME: struct {
    	wProcessorArchitecture : WORD,
    	wReserved              : WORD
    }
  },
  dwPageSize                  : DWORD,
  lpMinimumApplicationAddress : LPVOID,
  lpMaximumApplicationAddress : LPVOID,
  dwActiveProcessorMask       : DWORD_PTR,
  dwNumberOfProcessors        : DWORD,
  dwProcessorType             : DWORD,
  dwAllocationGranularity     : DWORD,
  wProcessorLevel             : WORD,
  wProcessorRevision          : WORD
};
LPSYSTEM_INFO :: ^SYSTEM_INFO;

@(default_calling_convention = "std")
foreign kernel {
	GetSystemInfo :: proc(lpSystemInfo: LPSYSTEM_INFO) ---;
}

@(default_calling_convention = "std")
foreign PowrProf {
    CallNtPowerInformation :: proc(
        InformationLevel   : POWER_INFORMATION_LEVEL,
        InputBuffer        : PVOID,
        InputBufferLength  : ULONG,
        OutputBuffer       : PVOID,
        OutputBufferLength : ULONG
    ) -> NTSTATUS ---;
}


main :: proc() {
	sys_info: SYSTEM_INFO;
	sys_info_ptr: LPSYSTEM_INFO = &sys_info;
	GetSystemInfo(sys_info_ptr);

	processor_count := sys_info.dwNumberOfProcessors;
	fmt.printf("Processor count: %d\n", processor_count);

	info := make_slice([]PROCESSOR_POWER_INFORMATION, processor_count);
	info_size := size_of(PROCESSOR_POWER_INFORMATION)*processor_count;
	
	CallNtPowerInformation(
		POWER_INFORMATION_LEVEL.ProcessorInformation, nil, 0, 
		PVOID(&info[0]), 
		ULONG(info_size)
	);
	fmt.printf("Processor Mhz: %d\n", info[0].MaxMhz);
}

other :: proc() {
	using fmt;

	// size :: 1024;
	// ram: [size]byte;

	// arena_init(&memory, size, &ram[0]);

	// v: ^Vector2 = Alloc(Vector2);
	// v.x = 123;
	// v.y = 567.89;

	// count :: 5;
	// vs: ^[count]Vector2 = Alloc([count]Vector2);
	// println(vs^);
	// Color :: struct #packed { B, G, R, A: u8 };
	// Pixel :: struct #raw_union { color: Color, value: u32};
	// vec3 :: struct {x,y,z: f32};
	// arr: [5]Pixel;
	// ap:= &arr;

	// sd1: #simd[33]f64 = {1,2,3,4,5,6,7,8, 11,12,13,14,15,16,17,18, 19, 1,2,3,4,5,6,7,8, 11,12,13,14,15,16,17,18};
	// sd2: #simd[33]f64 = {11,12,13,14,15,16,17,18, 1,2,3,4,5,6,7,8, 9, 1,2,3,4,5,6,7,8, 11,12,13,14,15,16,17,18};
	// sd3: #simd[33]f64 = sd2 * sd1;

	// sd4: #simd[4]f32 = 3;

	
	// normal: [3]f32 = {0.2, 0.3, 0.4};
	// color : [3]u8;

	// MAX_COLOR_VALUE :: 0xFF;
	// distance :f32 = 4.9;
 //    factor: f32 = 4.0 * MAX_COLOR_VALUE / distance;
 //    R: f32 = factor * (normal.x + 1.0);
 //    G: f32 = factor * (normal.y + 1.0);
 //    B: f32 = factor * (normal.z + 1.0);

 //    color.r = R > MAX_COLOR_VALUE ? MAX_COLOR_VALUE : u8(R);
 //    color.g = G > MAX_COLOR_VALUE ? MAX_COLOR_VALUE : u8(G);
 //    color.b = B > MAX_COLOR_VALUE ? MAX_COLOR_VALUE : u8(B);

	// println(color);

	// v1: [2]f32 = {1, 2};
	// v2: [2]f32 = {3, 4};
	
	// inline for i in 0..1 {
	// 	 v1[i] += v2[i];
	// }
	
	vec2 :: [2]f32;
	vec4 :: [4]f32; 
	mat2 :: [2][2]f32;
	SIMD128 :: #simd [4]f32;

	SIMD_vec4 :: struct #raw_union {
		vec: vec4,
		simd: SIMD128
	};

	println(getCycleCount());

	matmul_simd2 :: proc(v: ^vec2, m: ^mat2) -> vec2 {
		simd_m: SIMD_vec4;
		simd_m.vec = {
			m[0][0], m[1][0], 
			m[0][1], m[1][1]
		};
		simd_v: SIMD_vec4;
		simd_v.vec = {
			v[0], v[1], 
			v[0], v[1]
		}; 
		simd_v.simd *= simd_m.simd;
		return {
			simd_v.vec[0] + simd_v.vec[1], 
			simd_v.vec[2] + simd_v.vec[3]
		};
	}

	matmul_simd :: proc(v: ^vec2, m: ^mat2) -> vec2 {
		// Prepare data for simd:
		mat: vec4 = {
			m[0][0], m[1][0], 
			m[0][1], m[1][1]
		};
		vec: vec4 = {
			v[0], v[1], 
			v[0], v[1]
		}; 

		// Declare simd:
		simd_m := transmute(SIMD128)mat;
		simd_v := transmute(SIMD128)vec;

		// Perform simd op:
		simd_v *= simd_m;

		// Exctract result:
		vec = transmute(vec4)simd_v;
		return {
			vec[0] + vec[1], 
			vec[2] + vec[3]
		};
	}

	matmul :: inline proc(v: ^vec2, m: ^mat2) -> vec2 do
		return {
			v[0]*m[0][0] + v[1]*m[1][0], 
			v[0]*m[0][1] + v[1]*m[1][1]
		};

	o: vec2;
	v: vec2 = {5, 6};
	m: mat2 = {
		{1, 2},
		{3, 4}
	};

	o = matmul(&v, &m);
	println(o);

	o = matmul_simd2(&v, &m);
	println(o);

	// inline for i in 0..2 do color[i] = u8(clamp(factor * (normal[i] + 1.0), 0, MAX_COLOR_VALUE));
    
    // color.r = u8(clamp(factor * (normal.x + 1.0), 0, MAX_COLOR_VALUE));
    // color.g = u8(clamp(factor * (normal.y + 1.0), 0, MAX_COLOR_VALUE));
    // color.b = u8(clamp(factor * (normal.z + 1.0), 0, MAX_COLOR_VALUE));

	// println(color);

 //    RGB : [3]f32 = {R,G,B};
	// MIN : [3]f32 = {0,0,0};
	// MAX : [3]f32 = MAX_COLOR_VALUE;

	// COL = clamp(RGB, MIN, MAX);

	// println(sd3);
    // for i in 0..<5 do
        // arr[i].value = 2;
	// println(arr[2].color);
	// changer(arr[:]);
	// println(arr[2]);

	// // arr[2].x = 2;

	// for i in 0..<len(ap) do println(ap[i]);	

	// p :: proc() {
	// 	println(sqrtf(81));			
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

	// println(hud.str);
}