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
};

pub const Frame = enum {
    bg_dungeon,
};

fn initAnims() std.EnumArray(Anim, []const sprite.Frame) {
    comptime {
        var map = std.EnumArray(Anim, []const sprite.Frame).initUndefined();
        map.set(.ronin_run, &.{
            .{
                .tex_pos = render.TexPos.init(1, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(51, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(101, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(151, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(201, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(251, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(301, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
            .{
                .tex_pos = render.TexPos.init(351, 541),
                .w = 48,
                .h = 48,
                .duration = 85,
            },
        });
        map.set(.ronin_idle, &.{
            .{
                .tex_pos = render.TexPos.init(401, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(451, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(501, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(551, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(601, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(651, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(701, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(751, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(801, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
            .{
                .tex_pos = render.TexPos.init(851, 541),
                .w = 48,
                .h = 48,
                .duration = 95,
            },
        });
        map.set(.ronin_jump, &.{
            .{
                .tex_pos = render.TexPos.init(901, 541),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_crest, &.{
            .{
                .tex_pos = render.TexPos.init(1, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(51, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(101, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(151, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_fall, &.{
            .{
                .tex_pos = render.TexPos.init(201, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_wall_slide, &.{
            .{
                .tex_pos = render.TexPos.init(251, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(301, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(351, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_flip, &.{
            .{
                .tex_pos = render.TexPos.init(401, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(451, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(501, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(551, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(601, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(651, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_roll, &.{
            .{
                .tex_pos = render.TexPos.init(701, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(751, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(801, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(851, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(901, 591),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 641),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(51, 641),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.ronin_slide, &.{
            .{
                .tex_pos = render.TexPos.init(101, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(151, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(201, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(251, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(301, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(351, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(401, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
            },
            .{
                .tex_pos = render.TexPos.init(451, 641),
                .w = 48,
                .h = 48,
                .duration = 75,
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
            .tex_pos = render.TexPos.init(0, 0),
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

