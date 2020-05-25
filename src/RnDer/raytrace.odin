package RnDer

RAY_TRACER_TITLE :: "RayTrace";
RAY_TRACER_RAYS_PER_PIXEL :: 1;
RAY_TRACER_RAY_COUNT :: RENDER_SIZE * RAY_TRACER_RAYS_PER_PIXEL;

RayTracer :: struct { 
	using renderer: Renderer,
    closest_hit: ^RayHit, 
    ray_directions: ^[RAY_TRACER_RAY_COUNT]vec3,
    inverted_camera_rotation: ^mat3
};

onRenderRT :: proc(engine: ^Engine) {
	using engine;
	using scene;
	using frame_buffer;
	using renderers.ray_tracer;

    for i in 0..<size do
        if rayIntersectsWithSpheres(closest_hit, &ray_directions[i], spheres) do
            shadeClosestHitByNormal(closest_hit, &pixels[i]);
//            shadeRayByDirection(ray_direction++, pixel++);
        else do
            pixels[i].value = 0;
}

generateRaysRT :: proc(engine: ^Engine) {
	using engine;
	using renderers.ray_tracer;
	using active_viewport.controller.camera;

	height: i32 = i32(frame_buffer.height);
	width: i32 = i32(frame_buffer.width);

    z := f32(width) * focal_length;
    z2 := z * z;
    factor, y2_plus_z2: f32;
    
    ray_index: u32 = 0;
    for y: i32 = height - 1; y > -height; y -= 2 {
        y2_plus_z2 = f32(y*y) + z2;
        for x: i32 = 1 - width; x < width; x += 2 {
            factor = 1.0 / sqrtf(f32(x*x) + y2_plus_z2);
            ray_directions[ray_index] = {
                f32(x) * factor,
                f32(y) * factor,
                f32(z) * factor
            };                       
            ray_index += 1;
        }
    }
}

onResizeRT :: proc(engine: ^Engine) {
    generateRaysRT(engine);
}

onZoomRT :: proc(engine: ^Engine) {
    generateRaysRT(engine);
    engine.active_viewport.controller.changed.zoom = false;
}

onRotateRT :: proc(engine: ^Engine) {
	using engine;
	using renderers;
	using active_viewport.controller;
	using camera.transform;

    transposeMatrix3D(rotation, ray_tracer.inverted_camera_rotation);
    changed.orientation = false;
    changed.position = true;
}

onMoveRT :: proc(engine: ^Engine) {
    using engine;
	using renderers;
	using active_viewport.controller;
	using camera.transform;
	
	sphere: ^Sphere;
	using sphere;
	
	for i in 0..<SPHERE_COUNT {
		sphere = &scene.spheres[i];
        sub3D(world_position, position, view_position);
        imul3D(view_position, ray_tracer.inverted_camera_rotation);
    }

    changed.position = false;
}

createRayTracer :: proc(engine: ^Engine) -> ^RayTracer {
	using engine.frame_buffer;

    ray_tracer: ^RayTracer = Alloc(RayTracer);
    using ray_tracer;
    // using renderer;
    title = RAY_TRACER_TITLE;
    on.zoom = onZoomRT;
    on.move = onMoveRT;
    on.rotate = onRotateRT;
    on.resize = onResizeRT;
    on.render = onRenderRT;
    inverted_camera_rotation = createMat3();
    ray_directions = Alloc([RAY_TRACER_RAY_COUNT]vec3);
    closest_hit = Alloc(RayHit);
    using closest_hit;
    position = Alloc(vec3);
    normal = Alloc(vec3);

    return ray_tracer;
}

MAX_COLOR_VALUE :: 0xFF;

shadeClosestHitByNormal :: inline proc(using closestHit: ^RayHit, pixel: ^Pixel) {
    factor: f32 = 4.0 * MAX_COLOR_VALUE / distance;
    R: f32 = factor * (normal.x + 1.0);
    G: f32 = factor * (normal.y + 1.0);
    B: f32 = factor * (normal.z + 1.0);

    pixel.color.R = R > MAX_COLOR_VALUE ? MAX_COLOR_VALUE : u8(R);
    pixel.color.G = G > MAX_COLOR_VALUE ? MAX_COLOR_VALUE : u8(G);
    pixel.color.B = B > MAX_COLOR_VALUE ? MAX_COLOR_VALUE : u8(B);
}

rayIntersectsWithSpheres :: proc(
	using closest_hit: ^RayHit, // The hit structure of the closest intersection of the ray with the spheres
    ray_direction: ^vec3,  // The direction that the ray is aiming at
    spheres: []Sphere
) -> bool {
    r, r2, // The radius of the current sphere (and it's square)
    d, d2, // The distance from the origin to the position of the current intersection (and it's square)
    o2c, // The distance from the ray's origin to a position along the ray closest to the current sphere's center
    O2C, // The distance from the ray's origin to that position along the ray for the closest intersection
    r2_minus_d2, // The square of the distance from that position to the current intersection position
    R2_minus_D2: f32; // The square of the distance from that position to the closest intersection position
    R: f32 = 0; // The radius of the closest intersecting sphere
    D: f32 = 100000; // The distance from the origin to the position of the closest intersection yet - squared

    _t, _p: vec3;
    s: ^vec3; // The center position of the sphere of the current intersection
    S: ^vec3; // The center position of the sphere of the closest intersection yet
    p := &_p; // The position of the current intersection of the ray with the spheres
    t := &_t;

    // Loop over all the spheres and intersect the ray against them:
    for sphere in spheres {
        using sphere;
        s = view_position;
        r = radius;
        r2 = r*r;

        o2c = dot3D(ray_direction, s);
        if o2c > 0 {
            scale3D(ray_direction, o2c, p);
            sub3D(s, p, t);
            d2 = dot3D(t, t);
            if d2 <= r2 {
                r2_minus_d2 = r2 - d2;
                d = o2c - r2_minus_d2;
                if ((d > 0) && (d <= D)) {
                    S = s; D = d; R = r; O2C = o2c; R2_minus_D2 = r2_minus_d2;
                    position.x = p.x;
                    position.y = p.y;
                    position.z = p.z;
                }
            }
        }
    }

    if R != 0 {
        if R2_minus_D2 > 0.001 {
            distance = O2C - sqrtf(R2_minus_D2);
            scale3D(ray_direction, distance, position);
        }

        sub3D(position, S, normal);
        if (R != 1) do
            iscale3D(normal, 1 / R);

        return true;
    } else do
        return false;
}