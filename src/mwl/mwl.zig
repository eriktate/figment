const std = @import("std");
const config = @import("config");

// embed the platform specific API
// TODO (soggy): this isn't working for some reason. `build_opts` isn't available???
pub usingnamespace switch (config.opts.platform) {
    .x11 => @import("x11.zig"),
    .win32 => @import("win32.zig"),
    else => @compileError("unsupported platform"),
};

pub fn getTime() f64 {
    const nano_f64: f64 = @floatFromInt(std.time.nanoTimestamp());
    return nano_f64 / 1000 / 1000 / 1000;
}

pub const WinOpts = struct {
    vsync: bool = true,
    mode: Mode = .windowed,
    gl_major: i32 = 3,
    gl_minor: i32 = 3,
};

pub const Mode = enum {
    windowed,
    fullscreen,
    borderless,
};
