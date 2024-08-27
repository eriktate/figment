// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten

const std = @import("std");
const sprite = @import("sprite.zig");
const render = @import("render.zig");

pub const Anim = enum {
    portal_closed,
    portal_opening,
    portal_open,
    door_unlocked,
    door_locked,
    necromancer_idle,
    necromancer_walk,
    witch_idle_look_up,
    witch_idle_breath,
    witch_idle_bounce,
    witch_witch_walk,
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
                .tex_pos = render.TexPos.init(1565, 1),
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
                .tex_pos = render.TexPos.init(1565, 99),
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
                .tex_pos = render.TexPos.init(1533, 197),
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
                .tex_pos = render.TexPos.init(1533, 295),
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
        });
        map.set(.portal_open, &.{
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
                .tex_pos = render.TexPos.init(1533, 393),
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
                .tex_pos = render.TexPos.init(1533, 491),
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
        });
        map.set(.door_unlocked, &.{
            .{
                .tex_pos = render.TexPos.init(1305, 589),
                .w = 80,
                .h = 80,
                .duration = 100,
            },
        });
        map.set(.door_locked, &.{
            .{
                .tex_pos = render.TexPos.init(1387, 589),
                .w = 80,
                .h = 80,
                .duration = 100,
            },
        });
        map.set(.necromancer_idle, &.{
            .{
                .tex_pos = render.TexPos.init(1469, 589),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1535, 589),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1601, 589),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 637),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.necromancer_walk, &.{
            .{
                .tex_pos = render.TexPos.init(1469, 655),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1535, 655),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1601, 655),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1305, 671),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1371, 671),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 687),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.witch_idle_look_up, &.{
            .{
                .tex_pos = render.TexPos.init(1095, 687),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1145, 687),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1195, 687),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1245, 687),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 703),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1437, 721),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1487, 721),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1537, 721),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1587, 721),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1637, 721),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1095, 737),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1145, 737),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1195, 737),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1245, 737),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1295, 737),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1345, 737),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 753),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1013, 753),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1395, 771),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1445, 771),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1495, 771),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1545, 771),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1595, 771),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1645, 771),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1063, 787),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1113, 787),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.witch_idle_breath, &.{
            .{
                .tex_pos = render.TexPos.init(1163, 787),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1213, 787),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1263, 787),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1313, 787),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 803),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1013, 803),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1363, 821),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1413, 821),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1463, 821),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1513, 821),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1563, 821),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1613, 821),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1063, 837),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1113, 837),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1163, 837),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1213, 837),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1263, 837),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1313, 837),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 853),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1013, 853),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1363, 871),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1413, 871),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1463, 871),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1513, 871),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1563, 871),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1613, 871),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1063, 887),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1113, 887),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1163, 887),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1213, 887),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1263, 887),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1313, 887),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 903),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1013, 903),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1363, 921),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1413, 921),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1463, 921),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1513, 921),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.witch_idle_bounce, &.{
            .{
                .tex_pos = render.TexPos.init(1563, 921),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1613, 921),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1063, 937),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1113, 937),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1163, 937),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1213, 937),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1263, 937),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1313, 937),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 953),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1013, 953),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1363, 971),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1413, 971),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1463, 971),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1513, 971),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1563, 971),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1613, 971),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1063, 987),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1113, 987),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1163, 987),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1213, 987),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.witch_witch_walk, &.{
            .{
                .tex_pos = render.TexPos.init(1263, 987),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1313, 987),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 1003),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1013, 1003),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1363, 1021),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1413, 1021),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1463, 1021),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1513, 1021),
                .w = 48,
                .h = 48,
                .duration = 100,
            },
        });
        map.set(.dog_bark, &.{
            .{
                .tex_pos = render.TexPos.init(1563, 1021),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1629, 1021),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1063, 1037),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1129, 1037),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1200, 1037),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1270, 1037),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(963, 1053),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1563, 1055),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1029, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1099, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1165, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1231, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1297, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_idle_paw, &.{
            .{
                .tex_pos = render.TexPos.init(1363, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1429, 1071),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1495, 1071),
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
                .tex_pos = render.TexPos.init(925, 1087),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1629, 1088),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1561, 1089),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(991, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1057, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1123, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1189, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1255, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1321, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1387, 1105),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1453, 1105),
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
                .tex_pos = render.TexPos.init(925, 1121),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1627, 1122),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1519, 1123),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(991, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1057, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1123, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1189, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1255, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1321, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1387, 1139),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1453, 1139),
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
            .{
                .tex_pos = render.TexPos.init(265, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(331, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(397, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(463, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(529, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(595, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(661, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(727, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(793, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(859, 1153),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(925, 1155),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1585, 1156),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1519, 1157),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(991, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1057, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1123, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_idle_wag, &.{
            .{
                .tex_pos = render.TexPos.init(1189, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1255, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1321, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1387, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1453, 1173),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(67, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(133, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(199, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(265, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(331, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(397, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(463, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(529, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(595, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(661, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(727, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(793, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(859, 1187),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(925, 1189),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1585, 1190),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1519, 1191),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(991, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1057, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1123, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1189, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1255, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_run, &.{
            .{
                .tex_pos = render.TexPos.init(1321, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1387, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1453, 1207),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(67, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(133, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(199, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(265, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(331, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(397, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(463, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(529, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(595, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(661, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(727, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(793, 1221),
                .w = 64,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.red_face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(1647, 197),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1647, 231),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1647, 265),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1647, 299),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.red_face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(1647, 197),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(1647, 333),
                .w = 32,
                .h = 32,
                .duration = 1200,
            },
            .{
                .tex_pos = render.TexPos.init(1647, 367),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1647, 401),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1647, 435),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(1647, 333),
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

