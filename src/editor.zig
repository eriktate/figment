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

    const debug_font = try font.initAscii(alloc, "./assets/fonts/charybdis.ttf", 16);

    var win = try mwl.createWindow("Mythic - *float*", WINDOW_WIDTH, WINDOW_HEIGHT, .{ .mode = .windowed, .vsync = false });
    defer win.deinit();

    // init inputs after window because certain configs may require a valid window/context
    try input_mgr.init(alloc);

    log.info("window initialized", .{});

    var renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    var debug = try DebugRenderer.init(alloc, "./shaders/debug_vs.glsl", "./shaders/debug_fs.glsl");
    _ = try texture.loadFromFile(alloc, .tex, "./assets/sprites/atlas.png");
    _ = try texture.loadFromFile(alloc, .font, "./font_atlas.png");
    // texture.loadFromPixels(.font, debug_font.font_atlas, debug_font.atlas_w, debug_font.atlas_h);

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

    try renderer.setWorldDimensions(WORLD_WIDTH, WORLD_HEIGHT);
    try debug.setWorldDimensions(WORLD_WIDTH, WORLD_HEIGHT);

    // for (0..10) |_| {
    //     _ = try g.spawn(Entity.initAt(
    //         render.Pos.init(@floatFromInt(random.lessThan(900)), @floatFromInt(random.lessThan(490)), 0),
    //     ).withSprite(sprite.Sprite{
    //         .width = 48,
    //         .height = 48,
    //         .source = sprite.makeAnimation(gen.getAnim(.ronin_idle)),
    //     }));
    // }

    var last_time = win.getTime();
    var current_time = win.getTime();
    var stat_reset_timer = Timer.initMS(250);
    stat_reset_timer.reset();
    var dt: f32 = 0;
    var cam = Camera.init(WORLD_WIDTH, WORLD_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT, .{ .x = 16, .y = 16 });
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

        if (try g.getEntity(1)) |r| {
            // log.info("ronin pos=({d}, {d})", .{ r.pos.x, r.pos.y });
            cam.lookAt(r.pos);
        }

        // font shenanigans
        try g.drawTextFmt(debug_font, .{ .x = 32, .y = 8 }, "FPS: {d}", .{log.getLastStat(.loop).getRate()});
        try g.drawTextFmt(debug_font, .{ .x = 32, .y = 24 }, "Frame Time: {d:.4}ms", .{log.getLastStat(.loop).getAverageTimeMS()});
        try g.drawTextFmt(debug_font, .{ .x = 32, .y = 40 }, "Render: {d:.4}ms", .{log.getLastStat(.render).getAverageTimeMS()});

        try renderer.setProjection(cam.projection());
        try debug.setProjection(cam.projection());

        log.start(.render);
        win.clear();
        try renderer.render(try g.genQuads());
        try debug.render();
        log.finish(.render);

        log.start(.swap);
        // NOTE (soggy): for some reason calling glFlush before swapping results in a framerate boost of ~300%..?
        // Swapping ends up calling glFinish which blocks until all submitted GL commands have completed and all of
        // the pixels have been drawn, whereas glFlush does not block. So I wonder if this might eventually result
        // in flickering/tearing? Replacing glFlush with glFinish results in the same framerate we were seeing before
        gl.flush();
        g.reset();
        win.swap();
        log.finish(.swap);
        log.finish(.loop);

        try debug.pushLine(.{ .x = 64, .y = 64 }, .{ .x = 128, .y = 128 });

        if (stat_reset_timer.fired()) {
            stat_reset_timer.reset();
            log.reset();
        }
    }
}
