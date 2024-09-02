const std = @import("std");

pub const Platform = enum {
    win32,
    appkit,
    x11,
    wayland,
};

pub fn getPlatformFromNative(comptime target: std.Target.Os.Tag) Platform {
    return switch (target) {
        .linux => .x11,
        .windows => .win32,
        .macos => .appkit,
        else => @compileError("target os not supported"),
    };
}
