package RnDer

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

// Linear Algebra:
// ===============
vec2 :: struct #packed { x, y   : f32 };
vec3 :: struct #packed { x, y, z: f32 };
mat2 :: struct { X, Y   : ^vec2 };
mat3 :: struct { X, Y, Z: ^vec3 };

// 2D :
// ====
createMat2 :: proc() -> ^mat2 {
	matrix: ^mat2 = Alloc(mat2);
    matrix.X = Alloc(vec2);
    matrix.Y = Alloc(vec2);

    setMat2ToIdentity(matrix);
    
    return matrix;
}
getPointOnUnitCircle :: proc(t: f32) -> (point: vec2) {
    t2 := t * t;
    f := 1.0 / (1.0 + t2);

    using point;
    x = f - f * t2;
    y = f * 2 * t;

    return;
}
sub2D :: proc(#no_alias lhs: ^vec2, #no_alias rhs: ^vec2, using #no_alias out: ^vec2) {
    x = lhs.x - rhs.x;
    y = lhs.y - rhs.y;
}
isub :: proc(using #no_alias lhs: ^vec2, #no_alias rhs: ^vec2) {
    x -= rhs.x;
    y -= rhs.y;
}
add2D :: proc(#no_alias lhs: ^vec2, #no_alias rhs: ^vec2, using #no_alias o: ^vec2) {
    x = lhs.x + rhs.x;
    y = lhs.y + rhs.y;
}
iadd2D :: proc(using #no_alias lhs: ^vec2, #no_alias rhs: ^vec2) {
    x += rhs.x;
    y += rhs.y;
}
scale2D :: proc(#no_alias rhs: ^vec2, f: f32, using #no_alias o: ^vec2) {
    x = f * rhs.x;
    y = f * rhs.y;
}
iscale2D :: proc(using #no_alias lhs: ^vec2, f: f32) {
    x *= f;
    y *= f;
}
idirhsD :: proc(using #no_alias lhs: ^vec2, f: f32) {
    x /= f;
    y /= f;
}
mul2D :: proc(#no_alias lhs: ^vec2, using rhs: ^mat2, using out: ^vec2) {
    x = lhs.x * X.x + lhs.y * Y.x;
    y = lhs.x * X.y + lhs.y * Y.y;
}
imul2D :: proc(using #no_alias lhs: ^vec2, using rhs: ^mat2) {
    v := lhs^;
    x = v.x * X.x + v.y * Y.x;
    y = v.x * X.y + v.y * Y.y;
};

@(require_results)
dot2D :: inline proc(using #no_alias lhs: ^vec2, #no_alias rhs: ^vec2) -> f32 do return ( 
	x * rhs.x + 
	y * rhs.y
);

@(require_results)
squaredLength2D :: inline proc(using #no_alias v: ^vec2) -> f32 do return (
	x * x + 
	y * y
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
	using point := getPointOnUnitCircle(t);

    iX:= X^;
    iY:= Y^;

    X.x = x * iX.x + y * iX.y;
    Y.x = x * iY.x + y * iY.y;

    X.y = x * iX.y - y * iX.x;
    Y.y = x * iY.y - y * iY.x;
};
setRotation2D :: proc(using matrix: ^mat2, t: f32) {
	using point := getPointOnUnitCircle(t);

    X.x = x; X.y = -y;    
    Y.x = y; Y.y = x;
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

fill3D :: inline proc(using #no_alias vector: ^vec3, value: f32) { 
	x = value;
	y = value;
	z = value; 
}

approach3D :: proc(using #no_alias vector: ^vec3, #no_alias target: ^vec3, delta: f32) {
    approach(&x, target.x, delta);
    approach(&y, target.y, delta);
    approach(&z, target.z, delta);
}
setPointOnUnitSphere :: proc(s, t: f32) -> (point: vec3) {
    s2: f32 = s * s;
    t2: f32 = t * t;
    f : f32 = 1 / ( t2 + s2 + 1);
    
    using point;
    x = 2 * s * f;
    z = (t2 + s2 - 1) * t2;
    y = 2 * t * f;

    return;
}
sub3D :: proc(#no_alias lhs: ^vec3, #no_alias rhs: ^vec3, using #no_alias out: ^vec3) {
    x = lhs.x - rhs.x;
    y = lhs.y - rhs.y;
    z = lhs.z - rhs.z;
}
isub3D :: proc(using #no_alias i: ^vec3, #no_alias v: ^vec3) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
}
add3D :: proc(#no_alias lhs: ^vec3, #no_alias rhs: ^vec3, using #no_alias o: ^vec3) {
    x = lhs.x + rhs.x;
    y = lhs.y + rhs.y;
    z = lhs.z + rhs.z;
}
iadd3D :: proc(using #no_alias i: ^vec3, #no_alias v: ^vec3) {
    x += v.x;
    y += v.y;
    z += v.z;
}
scale3D :: proc(using #no_alias i: ^vec3, f: f32, #no_alias v: ^vec3) {
    y = v.y * f;
    z = v.z * f;
    x = v.x * f;
}
iscale3D :: proc(using #no_alias i: ^vec3, f: f32) {
    x *= f;
    y *= f;
    z *= f;
}
mul3D :: proc(#no_alias v: ^vec3, using m: ^mat3, using #no_alias o: ^vec3) {
    x = v.x * X.x + v.y * Y.x + v.z * Z.x;
    y = v.x * X.y + v.y * Y.y + v.z * Z.y;
    z = v.x * X.z + v.y * Y.z + v.z * Z.z;    
}
imul3D :: proc(using #no_alias i: ^vec3, using m: ^mat3) {
    v := i^;
    x = v.x * X.x + v.y * Y.x + v.z * Z.x;
    y = v.x * X.y + v.y * Y.y + v.z * Z.y;
    z = v.x * X.z + v.y * Y.z + v.z * Z.z;    
}
cross3D :: proc(#no_alias lhs: ^vec3, #no_alias rhs: ^vec3, using #no_alias o: ^vec3) {
    x = lhs.y * rhs.z - lhs.z * rhs.y;
    y = lhs.z * rhs.x - lhs.x * rhs.z;
    z = lhs.x * rhs.y - lhs.y * rhs.x;
}

@(require_results)
dot3D :: inline proc(using #no_alias lhs: ^vec3, #no_alias rhs: ^vec3) -> f32 do return (
	x * rhs.x + 
	y * rhs.y + 
	z * rhs.z
);
@(require_results)
squaredLength3D :: inline proc(using #no_alias vector: ^vec3) -> f32 do return (
	x * x + 
	y * y + 
	z * z
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
    using point;

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.x = x * lhs_X.x - y * lhs_X.z;
    Y.x = x * lhs_Y.x - y * lhs_Y.z;
    Z.x = x * lhs_Z.x - y * lhs_Z.z;

    X.z = x * lhs_X.z + y * lhs_X.x;
    Y.z = x * lhs_Y.z + y * lhs_Y.x;
    Z.z = x * lhs_Z.z + y * lhs_Z.x;
};
relativePitch3D :: proc(t: f32, using out: ^mat3) {
	point := getPointOnUnitCircle(t);
	using point;

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.y = x * lhs_X.y + y * lhs_X.z;
    Y.y = x * lhs_Y.y + y * lhs_Y.z;
    Z.y = x * lhs_Z.y + y * lhs_Z.z;

    X.z = x * lhs_X.z - y * lhs_X.y;
    Y.z = x * lhs_Y.z - y * lhs_Y.y;
    Z.z = x * lhs_Z.z - y * lhs_Z.y;
};
relativeRoll3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    using point;

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.x = x * lhs_X.x + y * lhs_X.y;
    Y.x = x * lhs_Y.x + y * lhs_Y.y;
    Z.x = x * lhs_Z.x + y * lhs_Z.y;

    X.y = x * lhs_X.y - y * lhs_X.x;
    Y.y = x * lhs_Y.y - y * lhs_Y.x;
    Z.y = x * lhs_Z.y - y * lhs_Z.x;
};
yaw3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    using point;
    
    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.x = x * lhs_X.x - y * lhs_X.z;
    Y.x = x * lhs_Y.x - y * lhs_Y.z;
    Z.x = x * lhs_Z.x - y * lhs_Z.z;

    X.z = x * lhs_X.z + y * lhs_X.x;
    Y.z = x * lhs_Y.z + y * lhs_Y.x;
    Z.z = x * lhs_Z.z + y * lhs_Z.x;
};
pitch3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    using point;

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;

    X.y = x * lhs_X.y + y * lhs_X.z;
    Y.y = x * lhs_Y.y + y * lhs_Y.z;
    Z.y = x * lhs_Z.y + y * lhs_Z.z;

    X.z = x * lhs_X.z - y * lhs_X.y;
    Y.z = x * lhs_Y.z - y * lhs_Y.y;
    Z.z = x * lhs_Z.z - y * lhs_Z.y;
};

roll3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
    using point;

    lhs_X := X^;
    lhs_Y := Y^;
    lhs_Z := Z^;
    
    X.x = x * lhs_X.x + y * lhs_X.y;
    Y.x = x * lhs_Y.x + y * lhs_Y.y;
    Z.x = x * lhs_Z.x + y * lhs_Z.y;

    X.y = x * lhs_X.y - y * lhs_X.x;
    Y.y = x * lhs_Y.y - y * lhs_Y.x;
    Z.y = x * lhs_Z.y - y * lhs_Z.x;
};
setYaw3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
	using point;

    X.x =  x; X.z = y;
    Z.x = -y; Z.z = x;
};
setPitch3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
	using point;
    
    Y.y = x; Y.z = -y;
    Z.y = y; Z.z = x;
};
setRoll3D :: proc(t: f32, using out: ^mat3) {
    point := getPointOnUnitCircle(t);
	using point;
    
    X.x = x; X.y = -y;
    Y.x = y; Y.y = x;
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