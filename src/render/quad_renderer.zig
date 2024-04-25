const std = @import("std");
const c = @import("../c.zig");
const dim = @import("../dim.zig");

const Shader = @import("../gl/shader.zig");
const Vertex = @import("render.zig").Vertex;
const Quad = @import("render.zig").Quad;

const MAX_QUADS = 50_000;

const QuadRenderer = @This();
shader: Shader,
vao: u32,
vbo: u32,
ebo: u32,

indices: []u32,
alloc: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator, vs_path: []const u8, fs_path: []const u8) !QuadRenderer {
    var renderer: QuadRenderer = undefined;
    var shader = try Shader.init(vs_path, fs_path);
    renderer.shader = shader;
    shader.use();

    c.glGenVertexArrays(1, &renderer.vao);

    c.glGenBuffers(1, &renderer.vbo);

    c.glGenBuffers(1, &renderer.ebo);

    c.glBindVertexArray(renderer.vao);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, renderer.vbo);

    c.glEnableVertexAttribArray(0);
    c.glEnableVertexAttribArray(1);
    c.glEnableVertexAttribArray(2);

    const pos_offset = @offsetOf(Vertex, "pos");
    const tex_offset = @offsetOf(Vertex, "tex_pos");
    const color_offset = @offsetOf(Vertex, "color");

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, @sizeOf(Vertex), @ptrFromInt(pos_offset));
    c.glVertexAttribIPointer(1, 2, c.GL_UNSIGNED_SHORT, @sizeOf(Vertex), @ptrFromInt(tex_offset));
    c.glVertexAttribIPointer(2, 4, c.GL_UNSIGNED_BYTE, @sizeOf(Vertex), @ptrFromInt(color_offset));

    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, renderer.ebo);

    // indices are always the same, so we can precompute their value
    // and buffer them once
    var indices = try alloc.alloc(u32, MAX_QUADS * 6);
    for (0..MAX_QUADS) |idx| {
        const index = idx * 6;
        const vertex: u32 = @intCast(idx * 4);

        indices[index] = vertex;
        indices[index + 1] = vertex + 2;
        indices[index + 2] = vertex + 1;

        indices[index + 3] = vertex + 1;
        indices[index + 4] = vertex + 2;
        indices[index + 5] = vertex + 3;
    }

    renderer.indices = indices;

    c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @intCast(MAX_QUADS * 6 * @sizeOf(u32)), indices.ptr, c.GL_DYNAMIC_DRAW);
    c.glBindVertexArray(0);
    return renderer;
}

pub fn deinit(self: *QuadRenderer) void {
    self.indices.deinit();
}

pub fn render(self: *QuadRenderer, quads: []Quad) !void {
    c.glBindVertexArray(self.vao);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(quads.len * @sizeOf(Quad)), quads.ptr, c.GL_DYNAMIC_DRAW);
    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.ebo);
    self.shader.use();
    c.glDrawElements(c.GL_TRIANGLES, @intCast(quads.len * 6), c.GL_UNSIGNED_INT, null);
    c.glBindVertexArray(0);
}

pub fn setWorldDimensions(self: *QuadRenderer, width: u16, height: u16) !void {
    try self.shader.setUniform(u32, "world_width", @intCast(width));
    try self.shader.setUniform(u32, "world_height", @intCast(height));
}

pub fn setProjection(self: *QuadRenderer, proj: dim.Mat4) !void {
    try self.shader.setUniform(dim.Mat4, "projection", proj);
}
