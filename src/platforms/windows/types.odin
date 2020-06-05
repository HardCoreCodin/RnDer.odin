package win

FALSE     :: 0;
NULL      :: 0;
SIZE_T    :: u64;
BOOL      :: b32;
BYTE      :: byte;
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
HANDLE    :: distinct rawptr;
HWND      :: distinct HANDLE;
HRGN      :: distinct HANDLE;
HDC       :: distinct HANDLE;
HINSTANCE :: distinct HANDLE;
HICON     :: distinct HANDLE;
HCURSOR   :: distinct HANDLE;
HMENU     :: distinct HANDLE;
HBITMAP   :: distinct HANDLE;
HBRUSH    :: distinct HANDLE;
HGDIOBJ   :: distinct HANDLE;
HMODULE   :: distinct HANDLE;
HMONITOR  :: distinct HANDLE;
HRAWINPUT :: distinct HANDLE;
HRESULT   :: distinct INT;
HKL       :: distinct HANDLE;
WPARAM    :: distinct UINT_PTR;
LPARAM    :: distinct LONG_PTR;
LRESULT   :: distinct LONG_PTR;
LPCSTR    :: cstring;
LPSTR     :: ^u8;