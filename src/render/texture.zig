const std = @import("std");
const c = @import("c");
const log = @import("../log.zig");
const ase = @import("../ase.zig");
const Color = @import("primitives.zig").Color;

const Shader = @import("../gl/shader.zig");

pub const TextureID = enum(c_uint) {
    tex = 0,
    font = 1,
    none = 33, // shouldn't exist

    fn toGL(self: TextureID) c_uint {
        return switch (self) {
            .tex => c.GL_TEXTURE0,
            .font => c.GL_TEXTURE1,
            .none => c.GL_TEXTURE31 + 1, // doesn't exist
        };
    }
};

const TextureErr = error{
    LoadFailed,
};

pub fn loadFromPixels(id: TextureID, pixels: []Color, w: usize, h: usize) void {
    var tex_handle: u32 = undefined;
    c.glGenTextures(1, &tex_handle);
    c.glActiveTexture(id.toGL());
    c.glBindTexture(c.GL_TEXTURE_2D, tex_handle);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, @intCast(w), @intCast(h), 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, @ptrCast(pixels));
}

pub fn loadFromFile(alloc: std.mem.Allocator, id: TextureID, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const file_size: usize = @intCast((try file.stat()).size);
    const buf = try alloc.alloc(u8, file_size);
    defer alloc.free(buf);
    const read_bytes = try file.read(buf);
    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels: i32 = undefined;

    const data = c.stbi_load_from_memory(@ptrCast(buf), @intCast(read_bytes), &width, &height, &channels, 4);
    if (data == null) {
        return TextureErr.LoadFailed;
    }
    defer c.stbi_image_free(data);

    log.info("loading texture {any} ({d}x{d}@{d})from {s}", .{ id, width, height, channels, path });
    var tex_handle: u32 = undefined;
    c.glActiveTexture(id.toGL());
    c.glGenTextures(1, &tex_handle);
    c.glBindTexture(c.GL_TEXTURE_2D, tex_handle);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, @ptrCast(data));
}

// pub fn fromFile(alloc: std.mem.Allocator, path: []const u8, id: TextureID) !Texture {
//     const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
//     defer file.close();

//     const file_size: usize = @intCast((try file.stat()).size);
//     const buf = try alloc.alloc(u8, file_size);
//     const read_bytes = try file.read(buf);
//     var width: i32 = undefined;
//     var height: i32 = undefined;
//     var channels: i32 = undefined;

//     const data = c.stbi_load_from_memory(@ptrCast(buf), @intCast(read_bytes), &width, &height, &channels, 4);
//     if (data == null) {
//         return TextureErr.LoadFailed;
//     }
//     defer c.stbi_image_free(data);

//     std.log.info("loading texture w={d} h={d}", .{ width, height });
//     // var tex_id: u32 = undefined;
//     // c.glGenTextures(1, &tex_id);
//     c.glActiveTexture(c.GL_TEXTURE0);
//     c.glBindTexture(c.GL_TEXTURE_2D, @intFromEnum(id));
//     c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
//     c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
//     c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, @ptrCast(data));

//     return .{
//         .id = id,
//     };
// }

// pub fn fromAseFile(alloc: std.mem.Allocator, path: []const u8) !Texture {
//     const file = try ase.Ase.fromFile(alloc, path);
//     defer file.deinit();

//     const width = file.header.width;
//     const height = file.header.height;
//     const bitmap = try alloc.alloc(ase.RGBA, width * height);
//     defer alloc.free(bitmap);

//     try file.renderFrame(0, bitmap, width);

//     var tex_id: u32 = undefined;
//     c.glGenTextures(1, &tex_id);
//     c.glActiveTexture(c.GL_TEXTURE0);
//     c.glBindTexture(c.GL_TEXTURE_2D, tex_id);
//     c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
//     c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
//     c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, @ptrCast(bitmap));

//     return .{
//         .id = tex_id,
//     };
// }
