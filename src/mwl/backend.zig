const std = @import("std");
const config = @import("config");

// embed the platform specific API
// TODO (soggy): this isn't working for some reason. `build_opts` isn't available???
pub usingnamespace switch (config.opts.platform) {
    .x11 => @import("x11.zig"),
    .win32 => @import("win32.zig"),
    else => @compileError("unsupported platform"),
};
