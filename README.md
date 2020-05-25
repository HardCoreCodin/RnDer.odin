# RnDer.odin

A collection of pure-software render engines witten in Odin

- No hardware acceleration
- No SIMD (yet)
- No Multithreading (yet)
- No BVH (yet)
- Zero dependencies
- Custom win32 binding (no bitmap, no gdi, except for SetDIBitsToDevice) 
- Custom math library (no trigonometric functions, no 'real' square-root)
- Custom text rendering (with embedded font data)
- Raw mouse input (no window-bound cursor tracking)
- 2 navigation modes: 
  - Maya-style (mouse orbits, middle mouse pans, mouse wheel dollys)
  - 1's person shooter (mouse orients, WASD moves, mouse wheel zooms)

