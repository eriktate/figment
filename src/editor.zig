const std = @import("std");
const builtin = std.builtin.AtomicOrder;
const config = @import("config");
const sdl = @import("sdl.zig");
const mwl = @import("mwl/mwl.zig");
const dim = @import("dim.zig");
const render = @import("render.zig");
const QuadRenderer = render.QuadRenderer;
const DebugRenderer = render.DebugRenderer;
const Texture = render.Texture;
const Shader = @import("gl/shader.zig");
const input_mgr = @import("input/manager.zig");
const font = @import("font.zig");
const sprite = @import("sprite.zig");
const log = @import("log.zig");
const Ase = @import("ase.zig").Ase;
const gen = @import("gen.zig");
const audio = @import("audio.zig");
const game = @import("game.zig");
const Entity = @import("entity.zig");
const Player = @import("player.zig");
const Box = @import("box.zig");
const gl = @import("gl.zig");
const random = @import("random.zig");

const WINDOW_WIDTH = 960;
const WINDOW_HEIGHT = 540;
const VIEW_WIDTH = 960;
const VIEW_HEIGHT = 540;

pub fn run() !void {
    log.info("starting editor", .{});
    const alloc = std.heap.page_allocator;

    var g = try game.init(alloc);

    log.info("init audio subsystem", .{});
    try audio.init(alloc, audio.Format{
        .channels = 2,
        .sample_fmt = .s16,
        .sample_rate = 22050,
    });
    defer audio.deinit();

    _ = try font.initAscii(alloc, "./assets/fonts/charybdis.ttf", 16);

    var win = try mwl.createWindow("Mythic - *float*", WINDOW_WIDTH, WINDOW_HEIGHT, .{ .mode = .windowed, .vsync = false });
    defer win.deinit();

    // init inputs after window because certain configs may require a valid window/context
    try input_mgr.init(alloc);

    log.info("window initialized", .{});

    var renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    var debug = try DebugRenderer.init(alloc, "./shaders/debug_vs.glsl", "./shaders/debug_fs.glsl");
    _ = try Texture.fromFile(alloc, "./assets/sprites/atlas.png");

    // add background
    _ = try g.spawn(Entity.init().withSprite(sprite.Sprite{
        .width = 960,
        .height = 540,
        .source = .{ .frame = gen.getFrame(.bg_dungeon) },
    }));

    const ronin = try g.spawn(
        Entity.initAt(render.Pos.init(512, 128, 0))
            .withSprite(sprite.Sprite{
            .pos = .{ .y = -48 },
            .width = 48,
            .height = 48,
            .source = sprite.makeAnimation(gen.getAnim(.ronin_idle)),
        }).withBox(Box.initAt(.{ .x = 17, .y = -28 }, 14, 28)),
    );

    var ground = try g.spawn(Entity.initAt(render.Pos.init(0, WINDOW_HEIGHT - 32, 0))
        .withBox(Box.init(WINDOW_WIDTH, 32)));
    ground.solid = true;

    var obstacle = try g.spawn(Entity.initAt(render.Pos.init(WINDOW_WIDTH / 2 - 64, WINDOW_HEIGHT - 32 - 64, 0))
        .withBox(Box.init(128, 64)));
    obstacle.solid = true;

    var ceiling = try g.spawn(Entity.initAt(render.Pos.init(WINDOW_WIDTH / 2 - 64, WINDOW_HEIGHT - 32 - 64 - 212, 0))
        .withBox(Box.init(128, 64)));
    ceiling.solid = true;

    var left_wall = try g.spawn(Entity.initAt(render.Pos.init(0, 0, 0))
        .withBox(Box.init(32, WINDOW_HEIGHT)));
    left_wall.solid = true;

    var right_wall = try g.spawn(Entity.initAt(render.Pos.init(WINDOW_WIDTH - 32, 0, 0))
        .withBox(Box.init(32, WINDOW_HEIGHT)));
    right_wall.solid = true;

    var player = Player.init(ronin.id, &input_mgr.controllers.items[0]);

    try renderer.setWorldDimensions(WINDOW_WIDTH, WINDOW_HEIGHT);
    try debug.setWorldDimensions(WINDOW_WIDTH, WINDOW_HEIGHT);

    log.info("initializing entities", .{});
    for (0..10) |_| {
        _ = try g.spawn(Entity.initAt(
            render.Pos.init(@floatFromInt(random.lessThan(900)), @floatFromInt(random.lessThan(490)), 0),
        ).withSprite(sprite.Sprite{
            .width = 48,
            .height = 48,
            .source = sprite.makeAnimation(gen.getAnim(.ronin_idle)),
        }));
    }

    log.info("game initialized", .{});
    var last_time = win.getTime();
    var current_time = win.getTime();
    var dt: f32 = 0;
    var total_elapsed_time: f32 = 0;
    var frames: usize = 0;
    log.info("begin game loop", .{});
    while (!input_mgr.quit) {
        log.start(.loop);
        defer input_mgr.flush();
        defer last_time = current_time;
        current_time = win.getTime();
        dt = @floatCast(current_time - last_time);

        if (try win.poll(input_mgr.controllers.items)) |event| {
            try input_mgr.handleEvent(event);
        }

        log.start(.update);
        // update player
        try player.tick(dt);

        // update entities
        for (g.entities.itemsMut()) |*ent| {
            ent.tick(dt, g.entities.itemsMut());
            try ent.drawDebug(&debug);
        }
        log.finish(.update);

        // sorting is REALLY slow when starting with a large number of entities
        log.start(.sort);
        try g.ySort();
        log.finish(.sort);

        log.start(.quads);
        _ = try g.genQuads();
        log.finish(.quads);

        win.clear();
        log.start(.render);
        try renderer.render(try g.genQuads());
        log.finish(.render);
        try debug.render();
        // NOTE (soggy): for some reason calling glFlush before swapping results in a framerate boost of ~300%..?
        // Swapping ends up calling glFinish which blocks until all submitted GL commands have completed and all of
        // the pixels have been drawn, whereas glFlush does not block. So I wonder if this might eventually result
        // in flickering/tearing? Replacing glFlush with glFinish results in the same framerate we were seeing before
        log.start(.swap);
        gl.flush();
        g.reset();
        win.swap();
        log.finish(.swap);
        log.finish(.loop);

        frames += 1;
        total_elapsed_time += dt;
        try debug.pushLine(.{ .x = 64, .y = 64 }, .{ .x = 128, .y = 128 });
        if (total_elapsed_time >= 1) {
            var buf: [256]u8 = undefined;
            const title = try std.fmt.bufPrint(buf[0..], "Mythic@{d}fps - *float*", .{frames});
            try win.setTitle(title);
            frames = 0;
            total_elapsed_time = 0;
            // log.stats();
            log.reset();
        }
    }
}
