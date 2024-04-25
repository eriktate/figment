const std = @import("std");

pub fn Vec(comptime T: type, comptime cardinality: u8, comptime Self: type) type {
    return struct {
        const Arr = [cardinality]T;
        const SIMD = @Vector(cardinality, T);

        pub inline fn asArray(self: Self) Arr {
            return @bitCast(self);
        }

        pub inline fn fromArray(arr: Arr) Self {
            return @bitCast(arr);
        }

        pub inline fn asSimd(self: Self) SIMD {
            return @as(SIMD, self.asArray());
        }

        pub inline fn fromSimd(simd: SIMD) Self {
            return @bitCast(@as(Arr, simd));
        }

        pub fn add(self: Self, other: Self) Self {
            return fromSimd(self.asSimd() + other.asSimd());
        }

        pub fn addMut(self: *Self, other: Self) *Self {
            self.* = fromSimd(self.asSimd() + other.asSimd());
            return self;
        }

        pub fn sub(self: Self, other: Self) Self {
            return fromSimd(self.asSimd() - other.asSimd());
        }

        pub fn subMut(self: *Self, other: Self) *Self {
            self.* = fromSimd(self.asSimd() - other.asSimd());
            return self;
        }

        pub fn scale(self: Self, scalar: T) Self {
            const scale_simd: SIMD = @splat(scalar);
            return fromSimd(self.asSimd() * scale_simd);
        }

        pub fn scaleMut(self: *Self, scalar: T) *Self {
            const scale_simd: SIMD = @splat(scalar);
            self.* = fromSimd(self.asSimd() * scale_simd);
            return self;
        }

        pub fn mag(self: Self) Self {
            return @sqrt(@reduce(.Add, self.asSimd() * self.asSimd()));
        }

        pub fn unit(self: Self) Self {
            return self.scale(1 / self.mag());
        }

        pub fn eq(self: Self, other: Self) bool {
            return @reduce(.And, self.asSimd() == other.asSimd());
        }

        pub fn zero() Self {
            return fromArray([1]T{0} ** cardinality);
        }

        pub fn dot(self: Self, other: Self) T {
            return @sqrt(@reduce(.Add, self.asSimd() * other.asSimd()));
        }
    };
}

pub fn Vec2(comptime T: type) type {
    return extern struct {
        x: T = std.mem.zeroes(T),
        y: T = std.mem.zeroes(T),

        const Self = @This();
        pub fn init(x: T, y: T) Self {
            return .{
                .x = x,
                .y = y,
            };
        }

        pub fn fromVec(vec: anytype) Self {
            return switch (@TypeOf(vec)) {
                Vec3(T) => |vec3| return Self.init(vec3.x, vec3.y),
                Vec4(T) => |vec4| return Self.init(vec4.x, vec4.y),
                else => @compileError("a Vec can only be derrived from a Vec of differing cardinality"),
            };
        }

        pub usingnamespace Vec(T, 2, Self);
    };
}

pub fn Vec3(comptime T: type) type {
    return extern struct {
        x: T = std.mem.zeroes(T),
        y: T = std.mem.zeroes(T),
        z: T = std.mem.zeroes(T),

        const Self = @This();
        pub fn init(x: T, y: T, z: T) Self {
            return .{
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn fromVec(vec: anytype) Self {
            return switch (@TypeOf(vec)) {
                Vec2(T) => |vec2| return Self.init(vec2.x, vec2.y, 1),
                Vec4(T) => |vec4| return Self.init(vec4.x, vec4.y, vec4.z),
                else => @compileError("a Vec can only be derrived from a Vec of differing cardinality"),
            };
        }

        pub usingnamespace Vec(T, 3, Self);
    };
}

pub fn Vec4(comptime T: type) type {
    return extern struct {
        x: T = std.mem.zeroes(T),
        y: T = std.mem.zeroes(T),
        z: T = std.mem.zeroes(T),
        w: T = std.mem.zeroes(T),

        const Self = @This();
        pub fn init(x: T, y: T, z: T, w: T) Self {
            return .{
                .x = x,
                .y = y,
                .z = z,
                .w = w,
            };
        }

        pub fn fromVec(vec: anytype) Self {
            return switch (@TypeOf(vec)) {
                Vec2(T) => |vec2| return Self.init(vec2.x, vec2.y, 1, 1),
                Vec3(T) => |vec3| return Self.init(vec3.x, vec3.y, vec3.z, 1),
                else => @compileError("a Vec can only be derrived from a Vec of differing cardinality"),
            };
        }

        pub usingnamespace Vec(T, 4, Self);
    };
}

pub fn Mat4(comptime T: type) type {
    return struct {
        data: [16]T,

        const Self = @This();

        pub fn ident() Self {
            return .{
                .data = .{
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 0, 0, 1,
                },
            };
        }

        pub fn orthographic(t: T, l: T, b: T, r: T) Self {
            return .{
                .data = .{
                    2 / (r - l),          0,                    0, 0,
                    0,                    2 / (t - b),          0, 0,
                    0,                    0,                    1, 0,
                    -((r + l) / (r - l)), -((t + b) / (t - b)), 0, 4,
                },
            };
        }

        pub fn translate(self: *Self, vec: Vec3(T)) void {
            self.data[12] = vec.x;
            self.data[13] = vec.y;
            self.data[14] = vec.z;
        }
    };
}
