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
const apl = @import("pipeline/run.zig");
const gen = @import("gen.zig");
const audio = @import("audio.zig");

const WINDOW_WIDTH = 1280;
const WINDOW_HEIGHT = 720;
const VIEW_WIDTH = 640;
const VIEW_HEIGHT = 360;

pub fn run() !void {
    log.info("starting editor...", .{});
    const alloc = std.heap.page_allocator;

    try audio.init(alloc);
    _ = audio.play(.speech);
    _ = try font.initAscii(alloc, "./assets/fonts/charybdis.ttf", 16);
    const ase = try Ase.fromFile(alloc, "./assets/sprites/face.ase");
    defer ase.deinit();

    for (ase.frames) |frame| {
        for (frame.chunks) |chunk| {
            switch (chunk.chunk) {
                .tags => |tags| {
                    for (tags.tags) |tag| {
                        log.info("{s} {d}-{d}", .{ tag.name, tag.from_frame, tag.to_frame });
                    }
                },
                else => {},
            }
        }
    }

    const canvas_width: c_int = @intCast(ase.header.width * ase.frames.len);
    const pixels = try ase.renderSheet(alloc);
    _ = c.stbi_write_png("./face.png", canvas_width, @intCast(ase.header.height), 4, @ptrCast(pixels.ptr), canvas_width * 4);

    // const face_idle = gen.getAnim(.face_idle);
    // log.info("{any}", .{face_idle[0]});
    // input_mgr should generally be the first thing initialized
    try input_mgr.init(alloc);
    var win = try window.init(WINDOW_WIDTH, WINDOW_HEIGHT, "Figment - *float*", .{ .style = .windowed, .vsync = false });
    defer win.deinit();

    log.info("window initialized", .{});

    var renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    _ = try Texture.fromFile(alloc, "./assets/sprites/atlas.png");

    // const face_blink = sprite.Animation.init(gen.getAnim(.face_idle));

    // const red_face_blink = sprite.Animation.init(gen.getAnim(.red_face_blink));

    var face_spr = sprite.Sprite{
        .pos = render.Pos.init(120, 120, 0),
        .width = 64,
        .height = 64,
        .source = sprite.makeAnimation(gen.getAnim(.face_blink)),
        // .source = .{
        //     .frame = .{
        //         .tex_pos = render.TexPos.init(0, 2),
        //         .w = 32,
        //         .h = 32,
        //     },
        // },
    };
    var face_copy = face_spr;
    face_copy.source = sprite.makeAnimation(gen.getAnim(.red_face_blink));
    face_copy.width = 128;
    face_copy.height = 128;
    face_copy.pos = render.Pos.init(240, 240, 0);

    var quads = [_]render.Quad{
        face_spr.toQuad(),
        face_copy.toQuad(),
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

            // for (input_mgr.controllers.items) |*ctrl| {
            //     ctrl.printState();
            // }
        }
        face_spr.tick(dt);
        face_copy.tick(dt);
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

        quads[0] = face_spr.toQuad();
        quads[1] = face_copy.toQuad();
        win.clear();
        try renderer.render(quads[0..]);
        win.swap();
    }
}
