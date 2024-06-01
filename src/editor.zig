const std = @import("std");
const config = @import("config");
const c = @import("c.zig");
const sdl = @import("sdl.zig");
const window = @import("window.zig");
const dim = @import("dim.zig");
const render = @import("render/render.zig");
const Shader = @import("gl/shader.zig");
const input_mgr = @import("input/manager.zig");
const QuadRenderer = @import("render/quad_renderer.zig");
const font = @import("font.zig");
const Texture = @import("render/texture.zig");
const sprite = @import("sprite.zig");
const log = @import("log.zig");
const Ase = @import("ase.zig").Ase;
const gen = @import("gen.zig");
const audio = @import("audio.zig");

const WINDOW_WIDTH = 960;
const WINDOW_HEIGHT = 540;
const VIEW_WIDTH = 960;
const VIEW_HEIGHT = 540;

pub fn run() !void {
    log.info("starting editor...", .{});
    const alloc = std.heap.page_allocator;

    try audio.init(alloc);
    _ = try font.initAscii(alloc, "./assets/fonts/charybdis.ttf", 16);

    try input_mgr.init(alloc);
    var win = try window.init(WINDOW_WIDTH, WINDOW_HEIGHT, "Figment - *float*", .{ .style = .windowed, .vsync = false });
    defer win.deinit();

    log.info("window initialized", .{});

    var renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    _ = try Texture.fromFile(alloc, "./assets/sprites/atlas.png");

    var background = sprite.Sprite{
        .pos = render.Pos.init(0, 0, 0),
        .width = 960,
        .height = 540,
        .source = .{ .frame = gen.getFrame(.bg_dungeon_flat) },
    };

    var face_spr = sprite.Sprite{
        .pos = render.Pos.init(120, 120, 0),
        .width = 64,
        .height = 64,
        .source = sprite.makeAnimation(gen.getAnim(.face_blink)),
    };
    var face_copy = face_spr;
    face_copy.source = sprite.makeAnimation(gen.getAnim(.red_face_blink));
    face_copy.width = 128;
    face_copy.height = 128;
    face_copy.pos = render.Pos.init(240, 240, 0);

    var dog_run = sprite.Sprite{
        .pos = render.Pos.init(256, 120, 0),
        .width = 128,
        .height = 64,
        .source = sprite.makeAnimation(gen.getAnim(.dog_run)),
    };

    dog_run.setFrameRate(2);

    var necro_idle = sprite.Sprite{
        .pos = render.Pos.init(256 + 128, 120, 0),
        .width = 128,
        .height = 128,
        .source = sprite.makeAnimation(gen.getAnim(.necromancer_idle)),
    };
    necro_idle.setFrameRate(1);

    var quads = [_]render.Quad{
        background.toQuad(),
        face_spr.toQuad(),
        face_copy.toQuad(),
        dog_run.toQuad(),
        necro_idle.toQuad(),
    };

    try renderer.setWorldDimensions(WINDOW_WIDTH, WINDOW_HEIGHT);

    log.info("game initialized", .{});
    var last_time = win.getTime();
    var current_time = win.getTime();
    var dt: f32 = 0;
    while (!input_mgr.quit) {
        defer input_mgr.flush();
        defer last_time = current_time;
        current_time = win.getTime();
        dt = @floatCast(current_time - last_time);

        if (try win.poll()) |event| {
            try input_mgr.handleEvent(event);
        }

        face_spr.tick(dt);
        face_copy.tick(dt);
        dog_run.tick(dt);
        necro_idle.tick(dt);
        const ctrl = input_mgr.controllers.items[0];
        if (ctrl.getInput(.left).isActive()) {
            _ = face_spr.pos.addMut(render.Pos.init(-64, 0, 0).scale(dt));
        }

        if (ctrl.getInput(.right).isActive()) {
            _ = face_spr.pos.addMut(render.Pos.init(64, 0, 0).scale(dt));
        }

        if (ctrl.getInput(.jump).pressed) {
            _ = audio.play(.speech);
        }

        if (ctrl.getInput(.attack).pressed) {
            _ = audio.play(.bark);
        }

        quads[0] = background.toQuad();
        quads[1] = face_spr.toQuad();
        quads[2] = face_copy.toQuad();
        quads[3] = dog_run.toQuad();
        quads[4] = necro_idle.toQuad();
        win.clear();
        try renderer.render(quads[0..]);
        win.swap();
    }
}
