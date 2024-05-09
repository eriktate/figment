const std = @import("std");
const strings = @import("../strings.zig");
const ase = @import("../ase.zig");

const OUTPUT_PATH = "./src/gen.zig";
const HEADER = "// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten\n\n";

pub fn initFile(path: []const u8) !std.fs.File {
    var file = try std.fs.cwd().openFile(path, .{ .mode = .write_only });
    errdefer file.close();

    _ = try file.write(HEADER);

    return file;
}

pub fn getAseFileNames(alloc: std.mem.Allocator, dir_path: []const u8) ![][]u8 {
    var dir = try std.fs.cwd().openDir(dir_path, .{});
    var walker = try dir.walk(alloc);
    while (try walker.next()) |file| {
        if (strings.hasSuffix(".ase", file.basename)) {}
    }
}
