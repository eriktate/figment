const std = @import("std");
const window = @import("window.zig");
const Texture = @import("render/texture.zig");
const sprite = @import("sprite.zig");
const gen = @import("gen.zig");
const render = @import("render.zig");

pub fn run() !void {
    const alloc = std.heap.page_allocator;
    var win = try window.init(1920, 1080, "test *float*", .{
        .vsync = false,
        .style = .windowed,
    });

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

    std.time.sleep(3 * 1000 * 1000 * 1000);
    win.deinit();
}
