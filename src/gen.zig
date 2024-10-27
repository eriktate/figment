// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten

const std = @import("std");
const sprite = @import("sprite.zig");
const render = @import("render.zig");

pub const Anim = enum {
    ronin_run,
    ronin_idle,
    ronin_jump,
    ronin_crest,
    ronin_fall,
    ronin_wall_slide,
    ronin_flip,
    ronin_roll,
    ronin_slide,
    ronin_dash,
};

pub const Frame = enum {
    bg_dungeon,
};

fn initAnims() std.EnumArray(Anim, []const sprite.Frame) {
    comptime {
        var map = std.EnumArray(Anim, []const sprite.Frame).initUndefined();
        map.set(.ronin_run, &.{
            .{
                .tex_pos = render.TexPos.init(1, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(51, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(101, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(151, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(201, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(251, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(301, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(351, 543),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
        });
        map.set(.ronin_idle, &.{
            .{
                .tex_pos = render.TexPos.init(401, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(451, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(501, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(551, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(601, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(651, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(701, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(751, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(801, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(851, 543),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
        });
        map.set(.ronin_jump, &.{
            .{
                .tex_pos = render.TexPos.init(901, 543),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_crest, &.{
            .{
                .tex_pos = render.TexPos.init(1, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(51, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(101, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(151, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_fall, &.{
            .{
                .tex_pos = render.TexPos.init(201, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_wall_slide, &.{
            .{
                .tex_pos = render.TexPos.init(251, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(301, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(351, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_flip, &.{
            .{
                .tex_pos = render.TexPos.init(401, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(451, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(501, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(551, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(601, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(651, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_roll, &.{
            .{
                .tex_pos = render.TexPos.init(701, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(751, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(801, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(851, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(901, 593),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(51, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_slide, &.{
            .{
                .tex_pos = render.TexPos.init(101, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(151, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(201, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(251, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(301, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(351, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(401, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(451, 643),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
        });
        map.set(.ronin_dash, &.{
            .{
                .tex_pos = render.TexPos.init(501, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(551, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(601, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(651, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(701, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(751, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(801, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(851, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(901, 643),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        return map;
    }
}

pub const anims = initAnims();

fn initFrames() std.EnumArray(Frame, sprite.Frame) {
    comptime {
        var map = std.EnumArray(Frame, sprite.Frame).initUndefined();
        map.set(.bg_dungeon, .{
            .tex_pos = render.TexPos.init(1, 1),
            .w = 960,
            .h = 540,
            .duration = 100,
        });
        return map;
    }
}

pub const frames = initFrames();

pub inline fn getAnim(anim: Anim) []const sprite.Frame {
    return anims.get(anim);
}

pub inline fn getFrame(frame: Frame) sprite.Frame {
    return frames.get(frame);
}

