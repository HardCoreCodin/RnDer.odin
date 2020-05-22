package RnDer

// Transform:
// ==========

Transform2D :: struct {
    rotation: ^mat2,
    position, right, forward: ^vec2
};

Transform3D :: struct {
    rotation, yaw, pitch, roll: ^mat3,
    position, up, right, forward: ^vec3
};

createTransform2D :: proc() -> ^Transform2D {
    transform := Alloc(Transform2D);
    using transform;
    
    rotation = createMat2();
    using rotation;

    right    = X;
    forward  = Y;

    position = Alloc(vec2);

    return transform;
}

createTransform3D :: proc() -> ^Transform3D {
    transform := Alloc(Transform3D);
    using transform;

    rotation = createMat3();
    using rotation;

    yaw   = createMat3();
    pitch = createMat3();
    roll  = createMat3();
    
    right   = X;
    up      = Y;
    forward = Z;

    position = Alloc(vec3);

    return transform;
}


// Camera:
// =======

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


// Scene:
// ======

SPHERE_RADIUS :: 1;
SPHERE_HCOUNT :: 3;
SPHERE_VCOUNT :: 3;
SPHERE_COUNT :: SPHERE_HCOUNT * SPHERE_VCOUNT;

Sphere :: struct { 
    radius: f32,
    world_position, view_position: ^vec3
};

Scene :: struct {
    camera: ^Camera,
    spheres: ^[SPHERE_COUNT]Sphere
};

createScene :: proc() -> ^Scene {
    scene := Alloc(Scene);
    using scene;

    camera = createCamera();
    spheres = Alloc([SPHERE_COUNT]Sphere);

    gap: u8 = SPHERE_RADIUS * 3;
    sphere_x: u8 = 0;
    sphere_z: u8 = 0;
    sphere_index: u8 = 0;

    sphere: ^Sphere;
    using sphere;

    for z: u8 = 0; z < SPHERE_VCOUNT; z += 1 {
        sphere_x = 0;

        for x: u8 = 0; x < SPHERE_HCOUNT; x += 1 {
            sphere = &spheres[sphere_index];
            radius = 1;

            view_position = Alloc(vec3);
            world_position = Alloc(vec3);
            
            using world_position;
            x = f32(sphere_x);
            y = 0.0;
            z = f32(sphere_z);

            sphere_x += gap;
            sphere_index += 1;
        }

        sphere_z += gap;
    }

    return scene;
}