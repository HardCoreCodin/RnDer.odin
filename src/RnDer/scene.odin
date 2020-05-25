package RnDer

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
    spheres_buffer: [SPHERE_COUNT]Sphere,
    spheres: []Sphere
};

createScene :: proc() -> ^Scene {
    scene := Alloc(Scene);
    using scene;

    camera = createCamera();
    spheres = spheres_buffer[:];

    gap: u8 = SPHERE_RADIUS * 3;
    sphere_x: u8 = 0;
    sphere_z: u8 = 0;
    sphere_index: u8 = 0;

    sphere: ^Sphere;
    using sphere;

    for z: u8 = 0; z < SPHERE_VCOUNT; z += 1 {
        sphere_x = 0;

        for x: u8 = 0; x < SPHERE_HCOUNT; x += 1 {
            sphere = &spheres_buffer[sphere_index];
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