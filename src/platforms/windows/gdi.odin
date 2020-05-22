package win

foreign import gdi "system:gdi32.lib"

@(default_calling_convention = "std")
foreign gdi {
    SetDIBitsToDevice :: proc(
        hdc       : HDC,
        xDest     : int,
        yDest     : int,
        w         : DWORD,
        h         : DWORD,
        xSrc      : int,
        ySrc      : int,
        StartScan : UINT,
        cLines    : UINT,
        lpvBits   : rawptr,
        lpbmi     : ^BITMAPINFO,
        ColorUse  : UINT
    ) -> int ---;
}
