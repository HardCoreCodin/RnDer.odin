package RnDer

vec2 :: distinct [2]f32;
vec3 :: distinct [3]f32;
mat2 :: struct { X, Y   : ^vec2 };
mat3 :: struct { X, Y, Z: ^vec3 };

sqrtf :: proc(number: f32) -> f32 {
    i: i32;
    x, y: f32;
    x = number * 0.5;
    y = number;
    i = (cast(^i32)(&y))^;
    i = 0x5f3759df - (i >> 1);
    y = (cast(^f32)(&i))^;
    y = y * (1.5 - (x * y * y));
    y = y * (1.5 - (x * y * y));
    
    return number * y;
}

approach :: proc(current: ^f32, target, delta: f32) {
	switch {
		case current^ + delta < target: current^ += delta;
		case current^ - delta > target: current^ -= delta;
		case                          : current^  = target;
	}
}

approach3D :: proc(#no_alias v: ^vec3, #no_alias target: ^vec3, delta: f32) {
    approach(&v.x, target.x, delta);
    approach(&v.y, target.y, delta);
    approach(&v.z, target.z, delta);
}

getPointOnUnitCircle :: proc(t: f32) -> (point: vec2) {
    t2 := t * t;
    f := 1.0 / (1.0 + t2);

    point.x = f - f * t2;
    point.y = f * 2 * t;

    return;
}

setPointOnUnitSphere :: proc(s, t: f32) -> (point: vec3) {
    s2: f32 = s * s;
    t2: f32 = t * t;
    f : f32 = 1 / ( t2 + s2 + 1);
    
    point.x = 2 * s * f;
    point.z = (t2 + s2 - 1) * t2;
    point.y = 2 * t * f;

    return;
}

// 2D :
// ====
createMat2 :: proc() -> ^mat2 {
	matrix: ^mat2 = Alloc(mat2);
    matrix.X = Alloc(vec2);
    matrix.Y = Alloc(vec2);

    setMat2ToIdentity(matrix);
    
    return matrix;
}

mul2D :: proc(#no_alias lhs: ^vec2, using rhs: ^mat2, out: ^vec2) {
    out.x = lhs.x * X.x + lhs.y * Y.x;
    out.y = lhs.x * X.y + lhs.y * Y.y;
}
imul2D :: proc(#no_alias lhs: ^vec2, using rhs: ^mat2) {
    v := lhs^;
    lhs.x = v.x * X.x + v.y * Y.x;
    lhs.y = v.x * X.y + v.y * Y.y;
};

@(require_results)
dot2D :: inline proc(#no_alias lhs: ^vec2, #no_alias rhs: ^vec2) -> f32 do return ( 
	lhs.x * rhs.x + 
	lhs.y * rhs.y
);

@(require_results)
squaredLength2D :: inline proc(#no_alias v: ^vec2) -> f32 do return (
	v.x * v.x + 
	v.y * v.y
);

setMat2ToIdentity :: proc(using matrix: ^mat2) {
    X.x = 1; Y.x = 0;
    X.y = 0; Y.y = 1;
}
matmul2D :: proc(lhs: ^mat2, rhs: ^mat2, using out: ^mat2) {
    X.x = lhs.X.x * rhs.X.x + lhs.X.y * rhs.Y.x; // Row 1 | Column 1
    X.y = lhs.X.x * rhs.X.y + lhs.X.y * rhs.Y.y; // Row 1 | Column 2
    
    Y.x = lhs.Y.x * rhs.X.x + lhs.Y.y * rhs.Y.x; // Row 2 | Column 1
    Y.y = lhs.Y.x * rhs.X.y + lhs.Y.y * rhs.Y.y; // Row 2 | Column 2
}
imatmul2D :: proc(using matrix: ^mat2, m: ^mat2) {
    iX := X^;
    iY := Y^;

    X.x = iX.x * m.X.x + iX.y * m.Y.x; // Row 1 | Column 1
    X.y = iX.x * m.X.y + iX.y * m.Y.y; // Row 1 | Column 2

    Y.x = iY.x * m.X.x + iY.y * m.Y.x; // Row 2 | Column 1
    Y.y = iY.x * m.X.y + iY.y * m.Y.y; // Row 2 | Column 2
}
rotateMatrix2D :: proc(using matrix: ^mat2, t: f32) {
	point := getPointOnUnitCircle(t);

    iX:= X^;
    iY:= Y^;

    X.x = point.x * iX.x + point.y * iX.y;
    Y.x = point.x * iY.x + point.y * iY.y;

    X.y = point.x * iX.y - point.y * iX.x;
    Y.y = point.x * iY.y - point.y * iY.x;
};
setRotation2D :: proc(using matrix: ^mat2, t: f32) {
	point := getPointOnUnitCircle(t);

    X.x = point.x; X.y = -point.y;    
    Y.x = point.y; Y.y =  point.x;
};
rotate2D :: proc(matrix: ^mat2, t: f32) {
    setRotation2D(&temp_mat2, t);
    imatmul2D(matrix, &temp_mat2);
};
temp_mat2: mat2;

// 3D:
// ===

createMat3 :: proc() -> ^mat3 {
	matrix: ^mat3 = Alloc(mat3);
    matrix.X = Alloc(vec3);
    matrix.Y = Alloc(vec3);
    matrix.Z = Alloc(vec3);

    setMat3ToIdentity(matrix);
    
    return matrix;
}

mul3D :: proc(#no_alias lhs: ^vec3, using matrix: ^mat3, #no_alias out: ^vec3) {
    out.x = lhs.x * X.x + lhs.y * Y.x + lhs.z * Z.x;
    out.y = lhs.x * X.y + lhs.y * Y.y + lhs.z * Z.y;
    out.z = lhs.x * X.z + lhs.y * Y.z + lhs.z * Z.z;    
}
imul3D :: proc(#no_alias lhs: ^vec3, using matrix: ^mat3) {
    v := lhs^;
    lhs.x = v.x * X.x + v.y * Y.x + v.z * Z.x;
    lhs.y = v.x * X.y + v.y * Y.y + v.z * Z.y;
    lhs.z = v.x * X.z + v.y * Y.z + v.z * Z.z;    
}
cross3D :: proc(#no_alias lhs: ^vec3, #no_alias rhs: ^vec3, #no_alias out: ^vec3) {
    out.x = lhs.y * rhs.z - lhs.z * rhs.y;
    out.y = lhs.z * rhs.x - lhs.x * rhs.z;
    out.z = lhs.x * rhs.y - lhs.y * rhs.x;
}

@(require_results)
dot3D :: inline proc(#no_alias lhs: ^vec3, #no_alias rhs: ^vec3) -> f32 do return (
	lhs.x * rhs.x + 
	lhs.y * rhs.y + 
	lhs.z * rhs.z
);
@(require_results)
squaredLength3D :: inline proc(#no_alias v: ^vec3) -> f32 do return (
	v.x * v.x + 
	v.y * v.y + 
	v.z * v.z
);
setMat3ToIdentity :: proc(using matrix: ^mat3) {
    X.x = 1; X.y = 0; X.z = 0;
    Y.x = 0; Y.y = 1; Y.z = 0;    
    Z.x = 0; Z.y = 0; Z.z = 1;
}
transposeMatrix3D :: proc(m: ^mat3, using out: ^mat3) {
    X.x = m.X.x;  X.y = m.Y.x;  Y.x = m.X.y;
    Y.y = m.Y.y;  X.z = m.Z.x;  Z.x = m.X.z; 
    Z.z = m.Z.z;  Y.z = m.Z.y;  Z.y = m.Y.z;
}
matMul3D :: proc(lhs: ^mat3, rhs: ^mat3, using out: ^mat3) {
    X.x = lhs.X.x * rhs.X.x + lhs.X.y * rhs.Y.x + lhs.X.z * rhs.Z.x; // Row 1 | Column 1
    X.y = lhs.X.x * rhs.X.y + lhs.X.y * rhs.Y.y + lhs.X.z * rhs.Z.y; // Row 1 | Column 2
    X.z = lhs.X.x * rhs.X.z + lhs.X.y * rhs.Y.z + lhs.X.z * rhs.Z.z; // Row 1 | Column 3

    Y.x = lhs.Y.x * rhs.X.x + lhs.Y.y * rhs.Y.x + lhs.Y.z * rhs.Z.x; // Row 2 | Column 1
    Y.y = lhs.Y.x * rhs.X.y + lhs.Y.y * rhs.Y.y + lhs.Y.z * rhs.Z.y; // Row 2 | Column 2
    Y.z = lhs.Y.x * rhs.X.z + lhs.Y.y * rhs.Y.z + lhs.Y.z * rhs.Z.z; // Row 2 | Column 3

    Z.x = lhs.Z.x * rhs.X.x + lhs.Z.y * rhs.Y.x + lhs.Z.z * rhs.Z.x; // Row 3 | Column 1
    Z.y = lhs.Z.x * rhs.X.y + lhs.Z.y * rhs.Y.y + lhs.Z.z * rhs.Z.y; // Row 3 | Column 2
    Z.z = lhs.Z.x * rhs.X.z + lhs.Z.y * rhs.Y.z + lhs.Z.z * rhs.Z.z; // Row 3 | Column 3
}
imatMul3D :: proc(using lhs: ^mat3, rhs: ^mat3) {
    lhs_X := lhs.X^;
    lhs_Y := lhs.Y^;
    lhs_Z := lhs.Z^;

    X.x = lhs_X.x * rhs.X.x + lhs_X.y * rhs.Y.x + lhs_X.z * rhs.Z.x; // Row 1 | Column 1
    X.y = lhs_X.x * rhs.X.y + lhs_X.y * rhs.Y.y + lhs_X.z * rhs.Z.y; // Row 1 | Column 2
    X.z = lhs_X.x * rhs.X.z + lhs_X.y * rhs.Y.z + lhs_X.z * rhs.Z.z; // Row 1 | Column 3

    Y.x = lhs_Y.x * rhs.X.x + lhs_Y.y * rhs.Y.x + lhs_Y.z * rhs.Z.x; // Row 2 | Column 1
    Y.y = lhs_Y.x * rhs.X.y + lhs_Y.y * rhs.Y.y + lhs_Y.z * rhs.Z.y; // Row 2 | Column 2
    Y.z = lhs_Y.x * rhs.X.z + lhs_Y.y * rhs.Y.z + lhs_Y.z * rhs.Z.z; // Row 2 | Column 3

    Z.x = lhs_Z.x * rhs.X.x + lhs_Z.y * rhs.Y.x + lhs_Z.z * rhs.Z.x; // Row 3 | Column 1
    Z.y = lhs_Z.x * rhs.X.y + lhs_Z.y * rhs.Y.y + lhs_Z.z * rhs.Z.y; // Row 3 | Column 2
    Z.z = lhs_Z.x * rhs.X.z + lhs_Z.y * rhs.Y.z + lhs_Z.z * rhs.Z.z; // Row 3 | Column 3
}

relativeYaw3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.x = point.x * lhs_X.x - point.y * lhs_X.z;
    Y.x = point.x * lhs_Y.x - point.y * lhs_Y.z;
    Z.x = point.x * lhs_Z.x - point.y * lhs_Z.z;

    X.z = point.x * lhs_X.z + point.y * lhs_X.x;
    Y.z = point.x * lhs_Y.z + point.y * lhs_Y.x;
    Z.z = point.x * lhs_Z.z + point.y * lhs_Z.x;
};
relativePitch3D :: proc(t: f32, using out: ^mat3) {
	point := getPointOnUnitCircle(t);

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.y = point.x * lhs_X.y + point.y * lhs_X.z;
    Y.y = point.x * lhs_Y.y + point.y * lhs_Y.z;
    Z.y = point.x * lhs_Z.y + point.y * lhs_Z.z;

    X.z = point.x * lhs_X.z - point.y * lhs_X.y;
    Y.z = point.x * lhs_Y.z - point.y * lhs_Y.y;
    Z.z = point.x * lhs_Z.z - point.y * lhs_Z.y;
};
relativeRoll3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.x = point.x * lhs_X.x + point.y * lhs_X.y;
    Y.x = point.x * lhs_Y.x + point.y * lhs_Y.y;
    Z.x = point.x * lhs_Z.x + point.y * lhs_Z.y;

    X.y = point.x * lhs_X.y - point.y * lhs_X.x;
    Y.y = point.x * lhs_Y.y - point.y * lhs_Y.x;
    Z.y = point.x * lhs_Z.y - point.y * lhs_Z.x;
};
yaw3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    
    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.x = point.x * lhs_X.x - point.y * lhs_X.z;
    Y.x = point.x * lhs_Y.x - point.y * lhs_Y.z;
    Z.x = point.x * lhs_Z.x - point.y * lhs_Z.z;

    X.z = point.x * lhs_X.z + point.y * lhs_X.x;
    Y.z = point.x * lhs_Y.z + point.y * lhs_Y.x;
    Z.z = point.x * lhs_Z.z + point.y * lhs_Z.x;
};
pitch3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.y = point.x * lhs_X.y + point.y * lhs_X.z;
    Y.y = point.x * lhs_Y.y + point.y * lhs_Y.z;
    Z.y = point.x * lhs_Z.y + point.y * lhs_Z.z;

    X.z = point.x * lhs_X.z - point.y * lhs_X.y;
    Y.z = point.x * lhs_Y.z - point.y * lhs_Y.y;
    Z.z = point.x * lhs_Z.z - point.y * lhs_Z.y;
};

roll3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;
    
    X.x = point.x * lhs_X.x + point.y * lhs_X.y;
    Y.x = point.x * lhs_Y.x + point.y * lhs_Y.y;
    Z.x = point.x * lhs_Z.x + point.y * lhs_Z.y;

    X.y = point.x * lhs_X.y - point.y * lhs_X.x;
    Y.y = point.x * lhs_Y.y - point.y * lhs_Y.x;
    Z.y = point.x * lhs_Z.y - point.y * lhs_Z.x;
};
setYaw3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);

    X.x =  point.x; X.z = point.y;
    Z.x = -point.y; Z.z = point.x;
};
setPitch3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    
    Y.y = point.x; Y.z = -point.y;
    Z.y = point.y; Z.z = point.x;
};
setRoll3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    
    X.x = point.x; X.y = -point.y;
    Y.x = point.y; Y.y =  point.x;
};
rotateRelative3D :: proc(yaw, pitch, roll: f32, out: ^mat3) {
    if yaw   != 0 do relativeYaw3D(    yaw, out);
    if pitch != 0 do relativePitch3D(pitch, out);
    if roll  != 0 do relativeRoll3D(  roll, out);
}
rotateAbsolute3D :: proc(
    yaw_amount, pitch_amount, roll_amount: f32, 
    yaw_matrix, pitch_matrix, roll_matrix, 

    out: ^mat3
) {
    if roll_amount != 0 do setRoll3D(roll_amount, roll_matrix);
    else do                setMat3ToIdentity(roll_matrix);

    if pitch_amount != 0 do setPitch3D(pitch_amount, pitch_matrix);
    else do                 setMat3ToIdentity(pitch_matrix);

    if yaw_amount != 0 do setYaw3D(yaw_amount, yaw_matrix);
    else do               setMat3ToIdentity(yaw_matrix);

    matMul3D(roll_matrix, pitch_matrix, out);
    imatMul3D(out, yaw_matrix);
}
rotate3D :: proc(yaw_amount, pitch_amount, roll_amount: f32, using transform: ^Transform3D) {
    if yaw_amount   != 0 do yaw3D(yaw_amount, yaw);
    if pitch_amount != 0 do pitch3D(pitch_amount, pitch);
    if roll_amount  != 0 {
        roll3D(roll_amount, roll);
        matMul3D(roll, pitch, rotation);
        imatMul3D(rotation, yaw);
    } else do
        matMul3D(pitch, yaw, rotation);
}