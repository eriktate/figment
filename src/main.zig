const std = @import("std");
const config = @import("config");
const editor = @import("editor.zig");
const pipeline = @import("pipeline/pipeline.zig");
const window_test = @import("window_test.zig");

pub fn main() !void {
    std.debug.print("\n", .{}); // because reasons?
    switch (config.opts.mode) {
        .editor => try editor.run(),
        .pipeline => try pipeline.run(),
        .game => try window_test.run(),
    }
}
