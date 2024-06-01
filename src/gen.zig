// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten

const std = @import("std");
const sprite = @import("sprite.zig");
const render = @import("render/render.zig");

pub const Anim = enum {
    portal_closed,
    portal_opening,
    portal_open,
    door_unlocked,
    door_locked,
    necromancer_idle,
    necromancer_walk,
    dog_bark,
    dog_idle_paw,
    dog_idle_wag,
    dog_run,
    red_face_blink,
    red_face_idle,
    face_blink,
    face_idle,
};

pub const Frame = enum {
    bg_dungeon_flat,
    bg_dungeon,
    dungeon_ts,
};

fn initAnims() std.EnumArray(Anim, []const sprite.Frame) {
    comptime {
        var map = std.EnumArray(Anim, []const sprite.Frame).initUndefined();
        map.set(.portal_closed, &.{
            .{
                .tex_pos = render.TexPos.init(1109, 1),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
        });
        map.set(.portal_opening, &.{
            .{
                .tex_pos = render.TexPos.init(1223, 1),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1337, 1),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1451, 1),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1109, 99),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1223, 99),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1337, 99),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1451, 99),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 147),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1077, 197),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1191, 197),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 197),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1419, 197),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 245),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1077, 295),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1191, 295),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 295),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1419, 295),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 343),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1077, 393),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1191, 393),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 393),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1419, 393),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 441),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1077, 491),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
        });
        map.set(.portal_open, &.{
            .{
                .tex_pos = render.TexPos.init(1191, 491),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 491),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1419, 491),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 539),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1077, 589),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1191, 589),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 589),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1419, 589),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 637),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1077, 687),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1191, 687),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 687),
                .w = 112,
                .h = 96,
                .duration = 100,
            },
        });
        map.set(.door_unlocked, &.{
            .{
                .tex_pos = render.TexPos.init(1419, 687),
                .w = 80,
                .h = 80,
                .duration = 100,
            },
        });
        map.set(.door_locked, &.{
            .{
                .tex_pos = render.TexPos.init(1501, 687),
                .w = 80,
                .h = 80,
                .duration = 100,
            },
        });
        map.set(.necromancer_idle, &.{
            .{
                .tex_pos = render.TexPos.init(1533, 197),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1533, 263),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1533, 329),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1533, 395),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.necromancer_walk, &.{
            .{
                .tex_pos = render.TexPos.init(1533, 461),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1533, 527),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1533, 593),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 735),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1419, 769),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1485, 769),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_bark, &.{
            .{
                .tex_pos = render.TexPos.init(1029, 785),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 785),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 785),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 785),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1298, 785),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 801),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 819),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 819),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1166, 819),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1236, 819),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1302, 819),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 835),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1368, 835),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_idle_paw, &.{
            .{
                .tex_pos = render.TexPos.init(1434, 835),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1500, 835),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 853),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 853),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 853),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 853),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 853),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 869),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 869),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 869),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 869),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 887),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 887),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 887),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 887),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 887),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 903),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 903),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 903),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 903),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 921),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 921),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 921),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 921),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 921),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 937),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 937),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 937),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 937),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 955),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 955),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 955),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 955),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 955),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 971),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 971),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 971),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 971),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 989),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 989),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 989),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 989),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 989),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 1005),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 1005),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 1005),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 1005),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 1023),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 1023),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 1023),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 1023),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 1023),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 1039),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 1039),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 1039),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 1039),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 1057),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 1057),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 1057),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 1057),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 1057),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 1073),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 1073),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 1073),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 1073),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(67, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(133, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(199, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(265, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(331, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(397, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(463, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_idle_wag, &.{
            .{
                .tex_pos = render.TexPos.init(529, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(595, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(661, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(727, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(793, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(859, 1085),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 1091),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 1091),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1161, 1091),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1227, 1091),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1293, 1091),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(925, 1107),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1359, 1107),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1425, 1107),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1491, 1107),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(67, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(133, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(199, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(265, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(331, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(397, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(463, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(529, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(595, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(661, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(727, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_run, &.{
            .{
                .tex_pos = render.TexPos.init(793, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(859, 1119),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(991, 1125),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1057, 1125),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1123, 1125),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1189, 1125),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1255, 1125),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(925, 1141),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1321, 1141),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1387, 1141),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1453, 1141),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1519, 1141),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(67, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(133, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(199, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.red_face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(1565, 1),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1565, 35),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1565, 69),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1565, 103),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.red_face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(1565, 1),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(1565, 137),
                .w = 32,
                .h = 32,
                .duration = 1200,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 735),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1551, 769),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1368, 785),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(1565, 137),
                .w = 32,
                .h = 32,
                .duration = 1200,
            },
        });
        return map;
    }
}

pub const anims = initAnims();

fn initFrames() std.EnumArray(Frame, sprite.Frame) {
    comptime {
        var map = std.EnumArray(Frame, sprite.Frame).initUndefined();
        map.set(.bg_dungeon_flat, .{
            .tex_pos = render.TexPos.init(1, 1),
            .w = 960,
            .h = 540,
            .duration = 100,
        });
        map.set(.bg_dungeon, .{
            .tex_pos = render.TexPos.init(1, 543),
            .w = 960,
            .h = 540,
            .duration = 100,
        });
        map.set(.dungeon_ts, .{
            .tex_pos = render.TexPos.init(963, 1),
            .w = 144,
            .h = 144,
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

