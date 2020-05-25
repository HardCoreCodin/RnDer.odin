package RnDer

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