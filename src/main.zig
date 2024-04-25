const std = @import("std");
const c = @import("c.zig");
const sdl = @import("sdl.zig");
const window = @import("window.zig");
const dim = @import("dim.zig");
const render = @import("render/render.zig");
const Shader = @import("gl/shader.zig");
const input_mgr = @import("input/manager.zig");
const QuadRenderer = @import("render/quad_renderer.zig");
const Texture = @import("render/texture.zig");
const sprite = @import("sprite.zig");

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;
const VIEW_WIDTH = 320;
const VIEW_HEIGHT = 240;

fn logSince(time: i64, msg: []const u8) i64 {
    const now = std.time.microTimestamp();
    const elapsed: f32 = @floatFromInt(now - time);
    std.log.info("{s} ({d}ms)", .{ msg, elapsed / 1000 });

    return now;
}

pub fn main() !void {
    var lastTime = std.time.microTimestamp();
    std.log.info("starting ronin...", .{});
    const alloc = std.heap.page_allocator;

    // input_mgr should generally be the first thing initialized
    try input_mgr.init(alloc);
    var win = try window.init(WINDOW_WIDTH, WINDOW_HEIGHT, "Figment - *float*", .{ .style = .windowed, .vsync = false });
    defer win.deinit();

    lastTime = logSince(lastTime, "window initialized");

    var renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    _ = try Texture.fromFile(alloc, "./sprites/face.png");

    var face_spr = sprite.Sprite{
        .pos = render.Pos.init(120, 120, 0),
        .width = 64,
        .height = 64,
        .source = .{
            .frame = .{
                .tex_pos = render.TexPos.zero(),
                .w = 32,
                .h = 32,
            },
        },
    };
    var face_copy = face_spr;
    face_copy.width = 128;
    face_copy.height = 128;
    face_copy.pos = render.Pos.init(240, 240, 0);

    var quads = [_]render.Quad{
        face_spr.toQuad(),
        face_copy.toQuad(),
    };

    try renderer.setWorldDimensions(WINDOW_WIDTH, WINDOW_HEIGHT);

    lastTime = logSince(lastTime, "game initialized");
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

            // for (input_mgr.controllers.items) |*ctrl| {
            //     ctrl.printState();
            // }
        }
        const ctrl = input_mgr.controllers.items[0];
        if (ctrl.getInput(.left).isActive()) {
            _ = face_spr.pos.addMut(render.Pos.init(-64, 0, 0).scale(dt));
        }

        if (ctrl.getInput(.right).isActive()) {
            _ = face_spr.pos.addMut(render.Pos.init(64, 0, 0).scale(dt));
        }

        quads[0] = face_spr.toQuad();
        win.clear();
        try renderer.render(quads[0..]);
        win.swap();
    }
}
