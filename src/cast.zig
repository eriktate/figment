const std = @import("std");
const testing = std.testing;

/// Accepts an integer type and a float value and performs the conversion and type
/// casting in a single operation. This replicates the old @floatToInt builtin
pub inline fn floatToInt(T: type, val: anytype) T {
    const val_type = @TypeOf(val);
    const float_val = switch (@typeInfo(val_type)) {
        .float => @as(val_type, val),
        else => @compileError("tried to convert floatToInt but value is not a float"),
    };

    switch (@typeInfo(T)) {
        .int => return @as(T, @intFromFloat(float_val)),
        else => @compileError("tried to convert floatToInt, but destination type is not an int"),
    }
}

/// Accepts a float type and an integer value and performs the conversion and type
/// casting in a single operation. This replicates the old @intToFloat builtin
pub inline fn intToFloat(T: type, val: anytype) T {
    const val_type = @TypeOf(val);
    const int_val = switch (@typeInfo(val_type)) {
        .int => @as(val_type, val),
        else => @compileError("tried to convert intToFloat but value is not an int"),
    };

    switch (@typeInfo(T)) {
        .float => return @as(T, @floatFromInt(int_val)),
        else => @compileError("tried to convert intToFloat, but destination type is not a float"),
    }
}

pub inline fn castNum(T: type, val: anytype) T {
    const val_type = @TypeOf(val);

    switch (@typeInfo(T)) {
        .float => {
            return switch (@typeInfo(val_type)) {
                .float => @as(T, val),
                .int => @as(T, @floatFromInt(val)),
                else => @compileError("value must be integer or float"),
            };
        },
        .int => {
            return switch (@typeInfo(val_type)) {
                .float => @as(T, @intFromFloat(val)),
                .int => @as(T, val),
                else => @compileError("value must be integer or float"),
            };
        },
        else => @compileError("destination type must be integer or float"),
    }
}

/// Multiply two number values together and cast to the given destination type. The numbers
/// are first normalized to the higher precision type (e.g. if at least one is a float, than
/// both are made into floats before multiplication), then multiplied, and then the result is
/// cast to the expected type. This means that `mul(i32, 2, 2.5) == 5` rather than
/// `mul(i32, 2, 2.5) == 4`
pub inline fn mul(T: type, left: anytype, right: anytype) T {
    const left_type = @TypeOf(left);
    const right_type = @TypeOf(right);
    const left_info = @typeInfo(left_type);
    const right_info = @typeInfo(right_type);

    if (left_info == .float) {
        return castNum(T, left * castNum(left_type, right));
    }

    if (right_info == .float) {
        return castNum(T, castNum(right_type, left) * right);
    }

    return castNum(T, left * right);
}

test "floatToInt" {
    const float_val: f32 = 5.0;
    const int_val = floatToInt(i32, float_val);
    const expected: i32 = 5;

    try testing.expectEqual(expected, int_val);
}

test "intToFloat" {
    const int_val: i32 = 5;
    const float_val = intToFloat(f32, int_val);
    const expected: f32 = 5.0;

    try testing.expectEqual(expected, float_val);
}

test "multiply an int and a float into a float" {
    const int_val: i32 = 5;
    const float_val: f32 = 2.5;
    const expected = 5 * 2.5;

    try testing.expectEqual(expected, mul(f32, int_val, float_val));
}

test "multiply an int and a float into an int" {
    const int_val: i32 = 5;
    const float_val: f32 = 2.5;
    const expected: i32 = @intFromFloat(5 * 2.5);

    try testing.expectEqual(expected, mul(i32, int_val, float_val));
}
