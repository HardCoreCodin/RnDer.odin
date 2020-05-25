package RnDer

Camera :: struct {
    focal_length: f32,
    transform:   ^Transform3D,
    transform2D: ^Transform2D
};

createCamera :: proc() -> ^Camera {
    camera := Alloc(Camera);
    using camera;

    focal_length = 2;
    transform = createTransform3D();


    transform2D = Alloc(Transform2D);

    using transform2D;
    rotation = Alloc(mat2);
    rotation.X = cast(^vec2)(transform.rotation.X);
    rotation.Y = cast(^vec2)(transform.rotation.Y);
    
    right = rotation.X;
    forward = rotation.Y;
    
    position = cast(^vec2)(transform.position);

    return camera;
}

Controller :: struct {
    camera: ^Camera, 
    zoom_amount: f32,
    changed: struct { 
        position, 
        orientation, 
        zoom: bool
    },
    on: struct {
        update,
        mouseMoved,
        mouseScrolled: EngineCallback
    }
};

// First Person Shooter controller:
// ================================

FpsController :: struct { using controller: Controller,
    max_velocity, 
    max_acceleration, 
    orientation_speed, 
    zoom_speed: f32,
    
    target_velocity, 
    current_velocity,
    movement: ^vec3
};

onMouseScrolledFps :: proc(using engine: ^Engine) {
    using controllers.fps;
    camera.focal_length += zoom_speed * mouse.wheel.scroll;
    zoom_amount = camera.focal_length;
    changed.zoom = true;
}

onMouseMovedFps :: proc(using engine: ^Engine) {
    using controllers.fps;
    using camera.transform;
    using mouse.coords;
    
    x := f32(relative.x);
    y := f32(relative.y);

    if x != 0 do yaw3D(  -x * orientation_speed, yaw);
    if y != 0 do pitch3D(-y * orientation_speed, pitch);
    matMul3D(pitch, yaw, rotation);

    changed.orientation = true;
}

onUpdateFps :: proc(using engine: ^Engine) {
    using controllers.fps;

    // Compute the target velocity:
    target_velocity.x = 0;
    target_velocity.y = 0;
    target_velocity.z = 0;
    if keyboard.right.is_pressed   do target_velocity.x += max_velocity;
    if keyboard.left.is_pressed    do target_velocity.x -= max_velocity;
    if keyboard.up.is_pressed      do target_velocity.y += max_velocity;
    if keyboard.down.is_pressed    do target_velocity.y -= max_velocity;
    if keyboard.forward.is_pressed do target_velocity.z += max_velocity;
    if keyboard.back.is_pressed    do target_velocity.z -= max_velocity;

    // Update the current velocity:
    delta_time := perf.delta.seconds > 1 ? 1.0 : perf.delta.seconds;
    approach3D(current_velocity, target_velocity, delta_time * max_acceleration);

    changed.position = current_velocity.x != 0 || 
                       current_velocity.y != 0 || 
                       current_velocity.z != 0;
    if changed.position {
        // Update the current position:
        using camera.transform;
        scale3D(current_velocity, delta_time, movement);
        position.y += movement.y;
        position.z += movement.x * yaw.X.z + movement.z * yaw.Z.z;
        position.x += movement.x * yaw.X.x + movement.z * yaw.Z.x;
    }
}

createFpsController :: proc(camera: ^Camera) -> ^FpsController {
    fps_controller := Alloc(FpsController);
    fps_controller.camera = camera;

    using fps_controller;
    target_velocity = Alloc(vec3);
    current_velocity = Alloc(vec3);
    movement = Alloc(vec3);

    on.update = onUpdateFps;
    on.mouseMoved = onMouseMovedFps;
    on.mouseScrolled = onMouseScrolledFps;

	zoom_amount = camera.focal_length;
    max_velocity = 8;
    max_acceleration = 20;
    orientation_speed = 7.0 / 10000;
    zoom_speed = 1;

    return fps_controller;
}

// Orbit controller:
// ================================

OrbController :: struct { using controller: Controller,
    pan_speed, 
    dolly_speed, 
    orbit_speed, 
    dolly_amount, 
    dolly_ratio, 
    target_distance: f32,
    
    target_position,
    scaled_right, 
    scaled_up,
    movement: ^vec3
};

onMouseScrolledOrb :: inline proc(using engine: ^Engine) { // Dolly
    using controllers.orb;
    using camera.transform;
    
    scale3D(forward, dolly_ratio, movement);
    add3D(position, movement, target_position);

    dolly_amount += dolly_speed * mouse.wheel.scroll;
    if      dolly_amount == 0 { dolly_ratio = target_distance; }
    else if dolly_amount >  0 { dolly_ratio = target_distance / dolly_amount; }
    else                      { dolly_ratio = target_distance * (1 - dolly_amount)/2; }
	
	zoom_amount = dolly_amount;
    scale3D(forward, dolly_ratio, movement);
    sub3D(target_position, movement, position);

    changed.position = true;
}

onMouseMovedOrb ::proc(using engine: ^Engine) {
    using controllers.orb;
    using camera.transform;
    
    x: f32 = f32(mouse.coords.relative.x);
    y: f32 = f32(mouse.coords.relative.y);

    if mouse.buttons.right.is_down { // Orbit
        speed: f32 = f32(orbit_speed);

        // Compute target position:
        scale3D(forward, dolly_ratio, movement);
        add3D(position, movement, target_position);

        // Compute new orientation at target position:
        yaw3D(  speed * -x, yaw);
        pitch3D(speed * -y, pitch);
        matMul3D(pitch, yaw, rotation);

        // Back-track from target position to new current position:
        scale3D(forward, dolly_ratio, movement);
        sub3D(target_position, movement, position);

        changed.orientation = true;
        changed.position = true;
    } else if mouse.buttons.middle.is_down { // Pan
        // Computed scaled up & right vectors:        
        scale3D(right, pan_speed * -x, scaled_right);
        scale3D(up,    pan_speed * +y, scaled_up);
        
        // Move current position by the combined movement:
        add3D(scaled_right, scaled_up, movement);
        iadd3D(position, movement);

        changed.position = true;
    }
}

onUpdateOrb :: proc(using engine: ^Engine) {} //NoOp 

createOrbController :: proc(camera: ^Camera) -> ^OrbController {
    orb_controller := Alloc(OrbController);
    orb_controller.camera = camera;

    using orb_controller;
    target_position = Alloc(vec3);
    scaled_right = Alloc(vec3);
    scaled_up = Alloc(vec3);
    movement = Alloc(vec3);

    on.update = onUpdateOrb;
    on.mouseMoved = onMouseMovedOrb;
    on.mouseScrolled = onMouseScrolledOrb;

    pan_speed = 1.0 / 100;
    dolly_speed = 4;
    orbit_speed = 1.0 / 1000;
    zoom_amount = 0;
    dolly_amount = 0;
    dolly_ratio = 4;
    target_distance = 4;

    return orb_controller;
}
