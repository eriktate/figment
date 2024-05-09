// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten

const std = @import("std");
const sprite = @import("sprite.zig");
const render = @import("render/render.zig");

pub const Anim = enum {
    face_idle,
    face_blink,
};

fn initAnims() std.EnumArray(Anim, []const sprite.Frame) {
    comptime {
        var map = std.EnumArray(Anim, []const sprite.Frame).initUndefined();
        map.set(.face_idle, &.{.{
            .tex_pos = render.TexPos.init(0, 0),
            .w = 16,
            .h = 16,
            .duration = 1,
        }});
        map.set(.face_blink, &.{.{
            .tex_pos = render.TexPos.init(0, 0),
            .w = 16,
            .h = 16,
            .duration = 1,
        }});
        return map;
    }
}

pub const anims = initAnims();

pub inline fn getAnim(anim: Anim) []const sprite.Frame {
    return anims.get(anim);
}
