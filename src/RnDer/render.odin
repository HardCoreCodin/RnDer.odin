package RnDer

Color :: struct #packed { B, G, R, A: u8 };
Pixel :: struct #raw_union { color: Color, value: u32};

PIXEL_SIZE :: 4;
RENDER_SIZE :: PIXEL_SIZE * 4 * 1024 * 1024;
RENDER_MAX_WIDTH :: 3840;
RENDER_MAX_HEIGHT :: 2160;

FrameBuffer :: struct {
    width, height: u16,
    size: u32,
    pixels: ^[RENDER_SIZE]Pixel
};

createFrameBuffer :: proc() -> ^FrameBuffer {
    frame_buffer: = Alloc(FrameBuffer);
    using frame_buffer;

    width = RENDER_MAX_WIDTH;
    height = RENDER_MAX_HEIGHT;
    size = u32(width) * u32(height);
    pixels = Alloc([RENDER_SIZE]Pixel);

    return frame_buffer;
}

RendererCallbacks :: struct {
    zoom,
    move,
    rotate,
    resize,
    render: EngineCallback
};

RendererType :: enum {
    RAY_TRACER,
    RAY_CASTER
}

Renderer :: struct {
    type: RendererType,
    title: cstring,
    on: RendererCallbacks
};

RayHit :: struct { 
    distance: f32,
    position, normal: ^vec3
};