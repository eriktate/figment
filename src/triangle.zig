const std = @import("std");
const render = @import("render.zig");

const Box = @import("box.zig");
const Pos = @import("render.zig").Pos;

const assert = std.debug.assert;

pub const Triangle = @This();
base: [2]Pos, // base must be axis aligned
point: Pos, // point must share a perpendicular access with one of the base points

inline fn assertRightTri(base: [2]Pos, point: Pos) void {
    // x-axis aligned
    if (base[0].x == base[1].x) {
        assert(point.y == base[0].y or point.y == base[1].y);
        return;
    }

    // y-axis aligned
    if (base[0].y == base[1].y) {
        assert(point.x == base[0].x or point.x == base[1].x);
        return;
    }

    // base not axis aligned
    assert(false);
}

pub fn init(base: [2]Pos, point: Pos) Triangle {
    assertRightTri(base, point);
    return .{
        .base = base,
        .point = point,
    };
}

pub fn at(self: Triangle, pos: Pos) Triangle {
    const base_diff = self.base[1].sub(self.base[0]);
    const point_diff = self.point.sub(self.base[0]);

    return .{
        .base = .{ pos, pos.add(base_diff) },
        .point = pos.add(point_diff),
    };
}

pub fn drawDebug(self: Triangle, debug: *render.DebugRenderer) !void {
    try debug.pushLine(self.base[0], self.base[1]);
    try debug.pushLine(self.base[1], self.point);
    try debug.pushLine(self.point, self.base[0]);
}

fn overlapsBox(self: Triangle, box: Box) bool {}

fn overlapsTri(self: Triangle, other: Tri) bool {}

pub fn overlaps(T: type, self: Triangle, other: T) bool {
    return switch (T) {
        Box => overlapsBox(self, other),
        Triangle => overlapsTri(self, other),
    };
}
