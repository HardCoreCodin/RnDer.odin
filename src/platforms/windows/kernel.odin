package win

foreign import kernel "system:kernel32.lib"

@(default_calling_convention = "std")
foreign kernel {
    VirtualAlloc :: proc(
        lpAddress        : LPVOID, 
        dwSize           : SIZE_T,
        flAllocationType : DWORD,
        flProtect        : DWORD
    ) -> LPVOID ---;

    GetModuleHandleA :: proc(
        module_name: cstring
    ) -> HMODULE ---;

    OutputDebugStringA :: proc(
        lpOutputString: LPCSTR
    ) ---;

    QueryPerformanceFrequency :: proc(
        lpFrequency: ^LARGE_INTEGER
    ) -> BOOL ---;

    QueryPerformanceCounter :: proc(
        lpPerformanceCount: ^LARGE_INTEGER
    ) -> BOOL ---;
}