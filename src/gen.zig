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
                .tex_pos = render.TexPos.init(2, 227),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(36, 228),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(70, 229),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(104, 230),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.red_face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(2, 227),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.dog_bark, &.{
            .{
                .tex_pos = render.TexPos.init(138, 231),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(204, 233),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(270, 235),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(336, 236),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(402, 238),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(468, 240),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(534, 242),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(600, 244),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(666, 246),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(732, 247),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(798, 249),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(864, 251),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(930, 253),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_idle_paw, &.{
            .{
                .tex_pos = render.TexPos.init(996, 255),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1062, 257),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1128, 258),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1194, 260),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1260, 262),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1326, 264),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1392, 266),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1458, 268),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1524, 269),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1590, 271),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1656, 273),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1722, 275),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1788, 277),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1854, 279),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1920, 280),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1986, 282),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2052, 284),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2118, 286),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2184, 288),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2250, 290),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2316, 291),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2382, 293),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2448, 295),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2514, 297),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2580, 299),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2646, 301),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2712, 302),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2778, 304),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2844, 306),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2910, 308),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2976, 310),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3042, 312),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3108, 313),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3174, 315),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3240, 317),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3306, 319),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3372, 321),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3438, 323),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3504, 324),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3570, 326),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3636, 328),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3702, 330),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3768, 332),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3834, 334),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3900, 335),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3966, 337),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(4032, 339),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2, 341),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(68, 343),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(134, 345),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(200, 346),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(266, 348),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(332, 350),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(398, 352),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(464, 354),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(530, 356),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(596, 357),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(662, 359),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(728, 361),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(794, 363),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(860, 365),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(926, 367),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(992, 368),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1058, 370),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1124, 372),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1190, 374),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1256, 376),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1322, 378),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1388, 379),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1454, 381),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1520, 383),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1586, 385),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1652, 387),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_idle_wag, &.{
            .{
                .tex_pos = render.TexPos.init(1718, 389),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1784, 390),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1850, 392),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1916, 394),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(1982, 396),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2048, 398),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2114, 400),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2180, 401),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2246, 403),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2312, 405),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2378, 407),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2444, 409),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2510, 411),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2576, 412),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2642, 414),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2708, 416),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2774, 418),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2840, 420),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2906, 422),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(2972, 423),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3038, 425),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3104, 427),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3170, 429),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3236, 431),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3302, 433),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3368, 434),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3434, 436),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.dog_run, &.{
            .{
                .tex_pos = render.TexPos.init(3500, 438),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3566, 440),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3632, 442),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3698, 444),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3764, 445),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3830, 447),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3896, 449),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(3962, 451),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(4028, 453),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(4094, 455),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(64, 456),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(130, 458),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(196, 460),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(262, 462),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(328, 464),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(394, 466),
                .w = 64,
                .h = 64,
                .duration = 100,
            },
        });
        map.set(.face_blink, &.{
            .{
                .tex_pos = render.TexPos.init(460, 467),
                .w = 32,
                .h = 32,
                .duration = 1200,
            },
            .{
                .tex_pos = render.TexPos.init(494, 468),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(528, 469),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
            .{
                .tex_pos = render.TexPos.init(562, 470),
                .w = 32,
                .h = 32,
                .duration = 100,
            },
        });
        map.set(.face_idle, &.{
            .{
                .tex_pos = render.TexPos.init(460, 467),
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

