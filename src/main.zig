const std = @import("std");
const config = @import("config");
const editor = @import("editor.zig");
const pipeline = @import("pipeline/pipeline.zig");

pub fn main() !void {
    std.debug.print("\n", .{}); // because reasons?
    switch (config.mode) {
        .editor => try editor.run(),
        .pipeline => try pipeline.run(),
        .game => try editor.run(),
    }
}
