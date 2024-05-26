const std = @import("std");
const pipeline = @import("pipeline.zig");

pub fn run() void {
    const alloc = std.heap.page_allocator;
    var ctx = try pipeline.Context.init(alloc);
    defer ctx.deinit();

    try pipeline.processFolder(&ctx, "./assets/sprites/");
    try pipeline.writeBitmap(ctx, "./assets/sprites/atlas.png");
    try pipeline.genAnimationCode(ctx);
}
