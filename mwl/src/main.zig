const std = @import("std");
const mwl = @import("mwl.zig");
const c = @import("c.zig");

pub fn main() !void {
    const win = try mwl.createWindow("hello, world *float*", 0, 0, 640, 480, .{ .vsync = false });
    defer win.deinit();
    try win.makeContextCurrent();

    if (c.gl3wInit() == 1) {
        std.log.err("failed to init gl3w", .{});
        return;
    }

    if (c.gl3wIsSupported(3, 3) == 0) {
        std.log.err("invalid opengl version", .{});
        return;
    }

    std.time.sleep(3 * 1000 * 1000 * 1000);
}
