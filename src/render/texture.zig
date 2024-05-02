const std = @import("std");
const ase = @import("../ase.zig");
const c = @import("../c.zig");

const TextureErr = error{
    LoadFailed,
};

const Texture = @This();
id: u32,

pub fn fromFile(alloc: std.mem.Allocator, path: []const u8) !Texture {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const file_size: usize = @intCast((try file.stat()).size);
    const buf = try alloc.alloc(u8, file_size);
    const read_bytes = try file.read(buf);
    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels: i32 = undefined;

    const data = c.stbi_load_from_memory(@ptrCast(buf), @intCast(read_bytes), &width, &height, &channels, 4);
    if (data == null) {
        return TextureErr.LoadFailed;
    }
    defer c.stbi_image_free(data);

    var tex_id: u32 = undefined;
    c.glGenTextures(1, &tex_id);
    c.glActiveTexture(c.GL_TEXTURE0);
    c.glBindTexture(c.GL_TEXTURE_2D, tex_id);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, @ptrCast(data));
    c.glGenerateMipmap(c.GL_TEXTURE_2D);

    return .{
        .id = tex_id,
    };
}

pub fn fromAseFile(alloc: std.mem.Allocator, path: []const u8) !Texture {
    const file = try ase.Ase.fromFile(alloc, path);
    defer file.deinit();

    const width = file.header.width;
    const height = file.header.height;
    const bitmap = try alloc.alloc(ase.RGBA, width * height);
    defer alloc.free(bitmap);

    try file.renderFrame(0, bitmap, width);

    var tex_id: u32 = undefined;
    c.glGenTextures(1, &tex_id);
    c.glActiveTexture(c.GL_TEXTURE0);
    c.glBindTexture(c.GL_TEXTURE_2D, tex_id);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, @ptrCast(bitmap));
    c.glGenerateMipmap(c.GL_TEXTURE_2D);

    return .{
        .id = tex_id,
    };
}
