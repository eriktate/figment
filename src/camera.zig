const std = @import("std");
const render = @import("render.zig");
const dim = @import("dim.zig");

const Pos = render.Pos;

pub const Camera = @This();
pos: Pos,
w: f32,
h: f32,
margin: Pos,

// TODO (soggy): consider making these globals instead of storing on the Camera
world_w: f32,
world_h: f32,

pub fn init(world_w: u32, world_h: u32, w: u32, h: u32, margin: dim.Vec2(f32)) Camera {
    return Camera{
        .pos = .{},
        .margin = .{ .x = margin.x, .y = margin.y },
        .w = @floatFromInt(w),

        .h = @floatFromInt(h),
        .world_w = @floatFromInt(world_w),
        .world_h = @floatFromInt(world_h),
    };
}

pub fn lookAt(self: *Camera, target: Pos) void {
    // const center: Pos = .{ .x = self.w / 2, .y = self.h / 2 };
    // const diff = target.sub(self.pos.add(center));
    // if (diff.x > self.margin.x) {
    //     self.pos = target.x - self.margin.x;
    // } else if (diff.x < -self.margin.x) {
    //     self.pos = target.x + self.margin.x;
    // }

    // if (diff.y > self.margin.y) {
    //     self.pos = target.y - self.margin.y;
    // } else if (diff.y < -self.margin.y) {
    //     self.pos = target.y + self.margin.y;
    // }
    const center: Pos = .{ .x = self.w / 2, .y = self.h / 2 };

    const lower = target.sub(center).sub(self.margin);
    const upper = target.sub(center).add(self.margin);

    // first clamp to a spot within the margins
    self.pos.x = std.math.clamp(self.pos.x, lower.x, upper.x);
    self.pos.y = std.math.clamp(self.pos.y, lower.y, upper.y);

    // then clamp to the world dimensions to keep from overshowing
    self.pos.x = std.math.clamp(self.pos.x, 0, self.world_w - self.w);
    self.pos.y = std.math.clamp(self.pos.y, 0, self.world_h - self.h);
}

pub fn projection(self: Camera) dim.Mat4(f32) {
    // const half_width = self.width / 2;
    // const half_height = self.height / 2;

    const top = -((self.pos.y / self.world_h) * 2 - 1);
    const left = (self.pos.x / self.world_w) * 2 - 1;
    const bottom = -(((self.pos.y + self.h) / self.world_h) * 2 - 1);
    const right = ((self.pos.x + self.w) / self.world_w) * 2 - 1;

    // const top = 0.25;
    // const left = -0.25;
    // const bottom = -0.25;
    // const right = 0.25;

    // const top = self.pos.y;
    // const left = self.pos.x;
    // const bottom = self.pos.y + self.height;
    // const right = self.pos.x + self.width;

    return dim.Mat4(f32).orthographic(top, left, bottom, right);
}
