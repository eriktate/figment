const std = @import("std");
const mwl = @import("mwl.zig");

const WinErr = error{
    CreateWindow,
};

pub const Window = struct {};

pub fn createWindow(title: []const u8, x: u16, y: u16, w: u16, h: u16, _: mwl.WinOpts) !Window {
    std.log.info("creating window for windows title={s} x={d} y={d} w={d} h={d}", .{ title, x, y, w, h });
    return WinErr.CreateWindow;
}
