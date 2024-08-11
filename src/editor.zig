const std = @import("std");
const config = @import("config");
const sdl = @import("sdl.zig");
const window = @import("window.zig");
const dim = @import("dim.zig");
const render = @import("render.zig");
const QuadRenderer = render.QuadRenderer;
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

const WINDOW_WIDTH = 960;
const WINDOW_HEIGHT = 540;
const VIEW_WIDTH = 960;
const VIEW_HEIGHT = 540;

pub fn run() !void {
    log.info("starting editor...", .{});
    const alloc = std.heap.page_allocator;

    var g = try game.init(alloc);
    try audio.init(alloc);
    defer audio.deinit();

    _ = try font.initAscii(alloc, "./assets/fonts/charybdis.ttf", 16);

    _ = audio.loop(.bg_seeing_die_dog);
    try input_mgr.init(alloc);
    var win = try window.init(WINDOW_WIDTH, WINDOW_HEIGHT, "Figment - *float*", .{ .style = .windowed, .vsync = false });
    defer win.deinit();

    log.info("window initialized", .{});

    var renderer = try QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");
    _ = try Texture.fromFile(alloc, "./assets/sprites/atlas.png");

    // add background
    _ = try g.spawn(Entity.init().withSprite(sprite.Sprite{
        .width = 960,
        .height = 540,
        .source = .{ .frame = gen.getFrame(.bg_dungeon_flat) },
    }));

    // add faces
    _ = try g.spawn(Entity.initAt(render.Pos.init(120, 120, 0)).withSprite(sprite.Sprite{
        .width = 64,
        .height = 64,
        .source = sprite.makeAnimation(gen.getAnim(.face_blink)),
    }));

    _ = try g.spawn(Entity.initAt(render.Pos.init(240, 240, 0))
        .withSprite(sprite.Sprite{
        .width = 128,
        .height = 128,
        .source = sprite.makeAnimation(gen.getAnim(.red_face_blink)),
    }));

    // add dog
    var dog = try g.spawn(
        Entity.initAt(render.Pos.init(256, 120, 0))
            .withSprite(
            sprite.Sprite{
                .pos = .{ .y = -64 },
                .width = 128,
                .height = 64,
                .source = sprite.makeAnimation(gen.getAnim(.dog_run)),
            },
        ),
    );

    dog.sprite.setFrameRate(6);
    // dog.max_speed = dim.Vec2(f32).init(64, 64);

    var player = Player.init(dog.id, &input_mgr.controllers.items[0]);
    _ = try g.spawn(Entity.initAt(render.Pos.init(256 + 128, 120, 0))
        .withSprite(
        sprite.Sprite{
            .pos = .{ .y = -128 },
            .width = 128,
            .height = 128,
            .source = sprite.makeAnimation(gen.getAnim(.necromancer_idle)),
        },
    ));

    try renderer.setWorldDimensions(WINDOW_WIDTH, WINDOW_HEIGHT);

    log.info("game initialized", .{});
    var last_time = win.getTime();
    var current_time = win.getTime();
    var dt: f32 = 0;
    var total_elapsed_time: f32 = 0;
    var frames: usize = 0;
    while (!input_mgr.quit) {
        defer input_mgr.flush();
        defer last_time = current_time;
        current_time = win.getTime();
        dt = @floatCast(current_time - last_time);

        if (try win.poll()) |event| {
            try input_mgr.handleEvent(event);
        }

        // update player
        try player.tick(dt);

        // update entities
        for (g.entities.itemsMut()) |*ent| {
            ent.tick(dt);
        }

        try g.ySort();
        win.clear();
        try renderer.render(try g.genQuads());
        g.reset();
        win.swap();

        frames += 1;
        total_elapsed_time += dt;
        if (total_elapsed_time >= 1) {
            var buf: [256]u8 = undefined;
            const title = try std.fmt.bufPrint(buf[0..], "Figment@{d}fps - *float*", .{frames});
            try win.setTitle(title);
            frames = 0;
            total_elapsed_time = 0;
        }
    }
}
