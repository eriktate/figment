// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten

const std = @import("std");
const sprite = @import("sprite.zig");
const render = @import("render/render.zig");

pub const Anim = enum {
    red_face_blink,
    red_face_idle,
    dog_bark,
    dog_idle_paw,
    dog_idle_wag,
    dog_run,
    face_blink,
    face_idle,
};

fn initAnims() std.EnumArray(Anim, []const sprite.Frame) {
    comptime {
        var map = std.EnumArray(Anim, []const sprite.Frame).initUndefined();
        map.set(.red_face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(2, 2),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(36, 2),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(70, 2),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(104, 2),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.red_face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(2, 2),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_bark, &.{
            .{
                .tex_pos = render.TexPos.init(138, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(204, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(270, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(336, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(402, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(468, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(534, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(600, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(666, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(732, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(798, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(864, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(930, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_idle_paw, &.{
            .{
                .tex_pos = render.TexPos.init(996, 2),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(38, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(104, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(170, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(236, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(302, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(368, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(434, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(500, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(566, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(632, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(698, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(764, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(830, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(896, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(962, 3),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(4, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(70, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(136, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(202, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(268, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(334, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(400, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(466, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(532, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(598, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(664, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(730, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(796, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(862, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(928, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(994, 4),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(36, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(102, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(168, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(234, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(300, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(366, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(432, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(498, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(564, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(630, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(696, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(762, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(828, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(894, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(960, 5),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(68, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(134, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(200, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(266, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(332, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(398, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(464, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(530, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(596, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(662, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(728, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(794, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(860, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(926, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(992, 6),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(34, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(100, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(166, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(232, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(298, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(364, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(430, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(496, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(562, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(628, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_idle_wag, &.{
            .{
                .tex_pos = render.TexPos.init(694, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(760, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(826, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(892, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(958, 7),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(0, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(66, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(132, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(198, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(264, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(330, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(396, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(462, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(528, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(594, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(660, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(726, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(792, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(858, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(924, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(990, 8),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(32, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(98, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(164, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(230, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(296, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(362, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_run, &.{
            .{
                .tex_pos = render.TexPos.init(428, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(494, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(560, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(626, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(692, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(758, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(824, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(890, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(956, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1022, 9),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(64, 10),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(130, 10),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(196, 10),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(262, 10),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(328, 10),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(394, 10),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(460, 10),
                .w = 32,
                .h = 32,
                .duration = 1200,
            },
            .{
                .tex_pos = render.TexPos.init(494, 10),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(528, 10),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(562, 10),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(460, 10),
                .w = 32,
                .h = 32,
                .duration = 1200,
            },
        });
        return map;
    }
}

pub const anims = initAnims();

pub inline fn getAnim(anim: Anim) []const sprite.Frame {
    return anims.get(anim);
}

