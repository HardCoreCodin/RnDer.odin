package RnDer

Kilobytes :: inline proc(value: int) -> int do return 1024 * value;
Megabytes :: inline proc(value: int) -> int do return 1024 * Kilobytes(value);
Gigabytes :: inline proc(value: int) -> int do return 1024 * Megabytes(value);
Terabytes :: inline proc(value: int) -> int do return 1024 * Gigabytes(value);

MEMORY_SIZE := Gigabytes(1);
MEMORY_BASE := Terabytes(2);
DEFAULT_ALIGNMENT :: 2;

Memory :: struct {
    address: ^u8,
    occupied: int
};
memory: Memory = {nil, 0};

import "core:mem"

allocate :: proc(size: int) -> ^u8 {
    memory.occupied += size;

    address := memory.address;
    memory.address = mem.ptr_offset(address, size);
    return address;
}


Alloc :: inline proc($T: typeid) -> ^T do 
    return cast(^T)allocate(size_of(T));

// MemoryArena :: struct {
//     current, capacity, occupied, allocation_count: int,
//     start: ^u8
// };
// memory: MemoryArena;

// arena_init :: proc(using memory_arena: ^MemoryArena, size: int, ptr: rawptr) {
//     start = cast(^u8)ptr;
//     capacity = size;
//     current = 0;
//     occupied = 0;
//     allocation_count = 0;
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

//     address := cast(^u8)(uintptr(int(uintptr(start)) + current));

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