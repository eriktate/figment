const std = @import("std");
const builtin = std.builtin.AtomicOrder;
const config = @import("config");
const sdl = @import("sdl.zig");
const mwl = @import("mwl/mwl.zig");
const dim = @import("dim.zig");
const render = @import("render.zig");
const QuadRenderer = render.QuadRenderer;
const DebugRenderer = render.DebugRenderer;
const texture = render.texture;
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
const Camera = @import("camera.zig");
const Timer = @import("timer.zig");

const WINDOW_WIDTH = 1920;
const WINDOW_HEIGHT = 1080;
const WORLD_WIDTH = 960;
const WORLD_HEIGHT = 540;
const VIEW_WIDTH = WINDOW_WIDTH / 2;
const VIEW_HEIGHT = WINDOW_HEIGHT / 2;

pub fn simulate(g: *game.Game) !void {
    log.info("starting simulation thread", .{});

    const debug_font = try font.initAscii(g.alloc, "./assets/fonts/charybdis.ttf", 16);

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

    var ground = try g.spawn(Entity.initAt(render.Pos.init(0, WORLD_HEIGHT - 32, 0))
        .withBox(Box.init(WORLD_WIDTH, 32)));
    ground.solid = true;

    var obstacle = try g.spawn(Entity.initAt(render.Pos.init(WORLD_WIDTH / 2 - 64, WORLD_HEIGHT - 32 - 64, 0))
        .withBox(Box.init(128, 64)));
    obstacle.solid = true;

    var obstacle2 = try g.spawn(Entity.initAt(render.Pos.init(WORLD_WIDTH / 2 + 256, WORLD_HEIGHT - 32 - 64 - 64, 0))
        .withBox(Box.init(128, 64)));
    obstacle2.solid = true;

    var ceiling = try g.spawn(Entity.initAt(render.Pos.init(WORLD_WIDTH / 2 - 64, WORLD_HEIGHT - 32 - 64 - 212, 0))
        .withBox(Box.init(128, 64)));
    ceiling.solid = true;

    var left_wall = try g.spawn(Entity.initAt(render.Pos.init(0, 0, 0))
        .withBox(Box.init(32, WORLD_HEIGHT)));
    left_wall.solid = true;

    var right_wall = try g.spawn(Entity.initAt(render.Pos.init(WORLD_WIDTH - 32, 0, 0))
        .withBox(Box.init(32, WORLD_HEIGHT)));
    right_wall.solid = true;

    var player = Player.init(ronin.id, &input_mgr.controllers.items[0]);

    // for (0..10) |_| {
    //     _ = try g.spawn(Entity.initAt(
    //         render.Pos.init(@floatFromInt(random.lessThan(900)), @floatFromInt(random.lessThan(490)), 0),
    //     ).withSprite(sprite.Sprite{
    //         .width = 48,
    //         .height = 48,
    //         .source = sprite.makeAnimation(gen.getAnim(.ronin_idle)),
    //     }));
    // }

    var stat_reset_timer = Timer.initMS(250);
    stat_reset_timer.reset();
    var last_time = g.win.getTime();
    var current_time = g.win.getTime();
    var elapsed: u64 = 0;
    var dt: f32 = 0;
    var cam = Camera.init(WORLD_WIDTH, WORLD_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT, .{ .x = 16, .y = 16 });
    while (!g.quit) {
        log.start(.sim);

        if (input_mgr.quit) {
            g.quit = true;
            return;
        }

        // NOTE (soggy): we're capping simulation rate at 100 microseconds to help reduce
        // float precision issues with incredibly small deltas. This might need to be even
        // lower resolution, but a lot of the weirdness I've seen seems to go away at this
        // cap.
        current_time = g.win.getTime();
        elapsed = (current_time - last_time) / 1000; // microsecond granularity
        if (elapsed < 100) { // 0.1 millisecond
            continue;
        }
        dt = @floatFromInt(elapsed);
        // dt *= 0.000_000_001; // nanosecond granularity
        dt *= 0.000_001; // microsecond granularity
        defer input_mgr.flush();
        defer last_time = current_time;

        while (try g.win.poll(input_mgr.controllers.items)) |event| {
            try input_mgr.handleEvent(event);
        }

        log.start(.update);
        // update player
        try player.tick(dt);

        // update entities
        for (g.entities.itemsMut()) |*ent| {
            ent.tick(dt, g.entities.itemsMut());
        }
        log.finish(.update);

        // sorting is REALLY slow when starting with a large number of entities
        log.start(.sort);
        try g.ySort();
        log.finish(.sort);

        if (try g.getEntity(1)) |r| {
            // log.info("ronin pos=({d}, {d})", .{ r.pos.x, r.pos.y });
            cam.lookAt(r.pos);
        }

        // only do prep work for rendering if the render thread is ready for it
        if (g.getActiveThread() == .sim) {
            g.reset();
            for (g.entities.items()) |*ent| {
                try ent.drawDebug(&g.debug);
            }
            const fps = log.getLastStat(.render).getRate();
            const tps = log.getLastStat(.sim).getRate();
            const tpf = if (fps > 0) @divFloor(tps, fps) else 0;

            // font shenanigans
            try g.drawTextFmt(debug_font, .{ .x = 32, .y = 8 }, "FPS: {d}", .{fps});
            try g.drawTextFmt(debug_font, .{ .x = 32, .y = 24 }, "Frame Time: {d:.4}ms", .{log.getLastStat(.render).getAverageTimeMS()});
            try g.drawTextFmt(debug_font, .{ .x = 32, .y = 40 }, "Render: {d:.4}ms", .{log.getLastStat(.render).getAverageTimeMS()});
            try g.drawTextFmt(debug_font, .{ .x = 32, .y = 56 }, "TPS: {d}", .{tps});
            try g.drawTextFmt(debug_font, .{ .x = 32, .y = 72 }, "Tick Time: {d:.7}ms", .{log.getLastStat(.sim).getAverageTimeMS()});
            try g.drawTextFmt(debug_font, .{ .x = 32, .y = 88 }, "TPF: {d}", .{tpf});

            log.start(.quads);
            _ = try g.genQuads();
            log.finish(.quads);

            g.projection = cam.projection();
            g.setActiveThread(.render);
        }

        log.finish(.sim);
        if (stat_reset_timer.fired()) {
            stat_reset_timer.reset();
            log.reset();
        }
    }
}

/// The `run` function represents the main thread of execution. This is where global initialization and the render loop happens. The
/// simulation of the game world is kicked off in a separate thread running the `simulate` function. A conditional `Thread` field
/// on the shared `Game` object controls which thread has access to rendering specific data at a time, but it's up to both threads to
/// properly respect that mode
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

    log.info("initializing window", .{});
    g.win = try mwl.createWindow(alloc, "Mythic - *float*", WINDOW_WIDTH, WINDOW_HEIGHT, .{ .mode = .windowed, .vsync = true });
    defer mwl.destroyWindow(g.win);
    try g.win.setTitle("Mythic - *float*");

    log.info("window initialized", .{});

    // init inputs after window because certain configs may require a valid window/context
    try input_mgr.init(g.alloc);

    g.renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    g.debug = try DebugRenderer.init(alloc, "./shaders/debug_vs.glsl", "./shaders/debug_fs.glsl");

    _ = try texture.loadFromFile(alloc, .tex, "./assets/sprites/atlas.png");
    _ = try texture.loadFromFile(alloc, .font, "./font_atlas.png");
    // texture.loadFromPixels(.font, debug_font.font_atlas, debug_font.atlas_w, debug_font.atlas_h);

    try g.renderer.setWorldDimensions(WORLD_WIDTH, WORLD_HEIGHT);
    try g.debug.setWorldDimensions(WORLD_WIDTH, WORLD_HEIGHT);

    const sim_thread = try std.Thread.spawn(.{}, simulate, .{g});
    while (!g.quit) {
        if (g.getActiveThread() != .render) {
            continue;
        }

        log.start(.render);
        try g.renderer.setProjection(g.projection);
        try g.debug.setProjection(g.projection);
        g.win.clear();
        try g.renderer.render(g.quads.items);
        try g.debug.render();
        // TODO (soggy): could we revert the access mode here instead of waiting for the swap?

        g.setActiveThread(.sim);
        log.start(.swap);
        // NOTE (soggy): for some reason calling glFlush before swapping results in a framerate boost of ~300%..?
        // Swapping ends up calling glFinish which blocks until all submitted GL commands have completed and all of
        // the pixels have been drawn, whereas glFlush does not block. So I wonder if this might eventually result
        // in flickering/tearing? Replacing glFlush with glFinish results in the same framerate we were seeing before
        // gl.flush();
        try g.win.swap();
        log.finish(.swap);
        log.finish(.render);
    }

    sim_thread.join();
    log.info("quitting...", .{});
}
