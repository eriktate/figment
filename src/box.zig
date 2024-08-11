const std = @import("std");

const Pos = @import("render.zig").Pos;

/// A simple box with overlap checking. When owned by an `Entity` the `pos` field may actually describe an offset
/// from the entity's `pos`.
pub const Box = @This();
pos: Pos,
w: f32,
h: f32,

pub fn init(w: f32, h: f32) Box {
    return Box{
        .pos = Pos.zero(),
        .w = w,
        .h = h,
    };
}

pub fn initAt(pos: Pos, w: f32, h: f32) Box {
    return Box{
        .pos = pos,
        .w = w,
        .h = h,
    };
}

pub fn at(self: Box, pos: Pos) Box {
    return Box{
        .pos = self.pos.add(pos),
        .w = self.w,
        .h = self.h,
    };
}

pub fn overlaps(self: Box, other: Box) bool {
    return !(self.pos.x > other.pos.x + other.w or self.pos.x + self.w < other.pos.x or self.pos.y + self.h < other.pos.y or self.pos.y > other.pos.y + other.h);
}

test "boxes overlap" {
    const t = std.testing;
    const box = Box.init(16, 16);
    const overlap = Box.initAt(Pos{ .x = 8, .y = 8 }, 16, 16);
    const non_overlap = Box.initAt(Pos{ .x = 17 }, 16, 16);
    const touching = Box.initAt(Pos{ .x = 16 }, 16, 16);
    const corner_touching = Box.initAt(Pos{ .x = 16, .y = 16 }, 16, 16);
    const contained = Box.initAt(Pos{ .x = 4, .y = 4 }, 4, 4);
    const contained_by = Box.initAt(Pos{ .x = -4, .y = -4 }, 32, 32);

    try t.expect(box.overlaps(overlap));
    try t.expect(!box.overlaps(non_overlap));
    try t.expect(box.overlaps(box));
    try t.expect(box.overlaps(touching));
    try t.expect(box.overlaps(corner_touching));
    try t.expect(box.overlaps(contained));
    try t.expect(box.overlaps(contained_by));
}
