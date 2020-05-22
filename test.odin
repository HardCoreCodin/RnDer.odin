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

sqrtf :: proc(number: f32) -> f32 {
    i: i32;
    x, y: f32;
    x = number * 0.5;
    y = number;
    i = (cast(^i32)(&y))^;
    i = 0x5f3759df - (i >> 1);
    y = (cast(^f32)(&i))^;
    y = y * (1.5 - (x * y * y));
    y = y * (1.5 - (x * y * y));
    
    return number * y;
}

UpdateWindowTitle :: proc();

my_proc: UpdateWindowTitle;

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

	// arr: [5]vec3;
	// ap:= &arr;

	// for ii in arr[:] do ii.x = 1;

	// changer(arr[:]);
	// fmt.println(arr[2]);

	// // arr[2].x = 2;

	// for i in 0..<len(ap) do fmt.println(ap[i]);	

	p :: proc() {
		fmt.println(sqrtf(81));			
	}

	my_proc = p;
	my_proc();
}