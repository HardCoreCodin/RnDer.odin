package RnDer

RAY_CASTER_TITLE :: "RayCaster";
RAY_CASTER_RAYS_PER_PIXEL :: 1;
RAY_CASTER_RAY_COUNT :: RENDER_MAX_WIDTH * RAY_CASTER_RAYS_PER_PIXEL;

RayCaster :: struct { 
    using renderer: Renderer,
    ray_directions: ^[RAY_CASTER_RAY_COUNT]vec2
};

onRenderRC :: proc(engine: ^Engine) {
    using engine;
    using active_viewport.controller.camera;
    RO := transform2D.position;
    RD := &renderers.ray_caster.ray_directions[0];
}

generateRays2D :: inline proc(engine: ^Engine) {
    using engine;
    using frame_buffer;
    using renderers.ray_caster;
    using active_viewport.controller.camera;
    using transform2D.rotation;
    right, ray: vec2;
    scale2D(X, (1 - f32(width)) / 2, &right);
    scale2D(Y, f32(height) * focal_length / 2, &ray);
    iadd2D(&ray, &right);
    for i in 0..<width {
        scale2D(&ray, 1 / sqrtf(ray.x*ray.x + ray.y*ray.y), &ray_directions[i]);
        iadd2D(&ray, X);
    }
}

onZoomRC :: proc(engine: ^Engine) { generateRays2D(engine); }
onRotateRC :: proc(engine: ^Engine) { generateRays2D(engine);}
onMoveRC :: proc(engine: ^Engine) {}
onResizeRC :: proc(engine: ^Engine) { generateRays2D(engine); }

createRayCaster :: proc(engine: ^Engine) -> ^RayCaster {
    using engine.frame_buffer;

    ray_caster: ^RayCaster = Alloc(RayCaster);
    using ray_caster;

    title = RAY_CASTER_TITLE;
    on.zoom = onZoomRC;
    on.move = onMoveRC;
    on.rotate = onRotateRC;
    on.resize = onResizeRC;
    on.render = onRenderRC;
    ray_directions = Alloc([RAY_CASTER_RAY_COUNT]vec2);
    
    return ray_caster;
}