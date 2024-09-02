const std = @import("std");
const window = @import("window.zig");
const Texture = @import("render/texture.zig");
const sprite = @import("sprite.zig");
const gen = @import("gen.zig");
const render = @import("render.zig");
const joystick = @import("mwl/x11/joystick.zig");

pub fn run() !void {
    const alloc = std.heap.page_allocator;
    var win = try window.init(1920, 1080, "test *float*", .{
        .vsync = false,
        .style = .windowed,
    });
    defer win.deinit();

    var joystick_mgr = try joystick.JoystickManager.init(alloc);
    defer joystick_mgr.deinit();

    const js_count = try joystick_mgr.detectJoysticks();
    if (js_count == 0) {
        std.log.err("no joysticks found", .{});
        return;
    }
    std.log.info("{d} joysticks detected", .{js_count});

    var renderer = try render.QuadRenderer.init(alloc, "./shaders/vertex.glsl", "./shaders/fragment.glsl");

    _ = try Texture.fromFile(alloc, "./assets/sprites/atlas.png");

    const spr = sprite.Sprite{
        .pos = .{ .x = 256, .y = 256 },
        .width = 960,
        .height = 540,
        .source = .{ .frame = gen.getFrame(.bg_dungeon_flat) },
    };

    var quads = [_]render.Quad{spr.toQuad(render.Pos.zero()).?};
    try renderer.setWorldDimensions(1920, 1080);
    try renderer.render(quads[0..]);
    win.swap();

    var last_time = win.getTime();
    var elapsed: f64 = 0;
    while (elapsed < 5) {
        const events = try joystick_mgr.poll();
        while (events.next()) |ev| {
            const curr_time = win.getTime();
            elapsed += curr_time - last_time;
            last_time = curr_time;

            const js = joystick_mgr.getJoystick(ev.id) orelse {
                std.log.err("event for invalid joystick ID: {d}", .{ev.id});
                return;
            };

            std.log.info("id={d} name={s} type={any} number={d} value={d}", .{ ev.id, js.getName(), ev.type, ev.number, ev.value });
        }
    }
}
