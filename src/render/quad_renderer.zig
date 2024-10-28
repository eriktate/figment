const std = @import("std");
const dim = @import("../dim.zig");
const gl = @import("../gl.zig");

const Shader = gl.Shader;
const Vertex = @import("primitives.zig").Vertex;
const Quad = @import("primitives.zig").Quad;

/// The maximum number of quads expected to ever be rendered, used for pre-generating the element array.
const MAX_QUADS = 100_000;

/// A basic quad renderer that uses a single VAO and draw call.
const QuadRenderer = @This();
shader: Shader,
vao: gl.VAO,

indices: []u32,
alloc: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator, vs_path: []const u8, fs_path: []const u8) !QuadRenderer {
    var renderer: QuadRenderer = undefined;
    var shader = try Shader.init(vs_path, fs_path);
    renderer.shader = shader;
    shader.use();
    try shader.setUniform(i32, "tex_atlas", 0);
    // try shader.setUniform(i32, "font_atlas", 1);

    renderer.vao = gl.VAO.init();

    const pos_offset = @offsetOf(Vertex, "pos");
    const tex_offset = @offsetOf(Vertex, "tex_pos");
    const tex_id_offset = @offsetOf(Vertex, "tex_id");
    const color_offset = @offsetOf(Vertex, "color");

    renderer.vao.addAttr(f32, 3, @sizeOf(Vertex), pos_offset);
    renderer.vao.addAttr(u16, 2, @sizeOf(Vertex), tex_offset);
    renderer.vao.addAttr(u32, 1, @sizeOf(Vertex), tex_id_offset);
    renderer.vao.addAttr(u8, 4, @sizeOf(Vertex), color_offset);

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
        indices[index + 4] = vertex + 3;
        indices[index + 5] = vertex + 2;
    }

    renderer.vao.setIndices(indices);
    renderer.indices = indices;
    renderer.vao.initVertexBuffer(Quad, MAX_QUADS);
    renderer.vao.unbind();
    return renderer;
}

pub fn deinit(self: *QuadRenderer) void {
    self.indices.deinit();
}

pub fn render(self: *QuadRenderer, quads: []Quad) !void {
    self.shader.use();
    self.vao.drawIndices(Quad, .triangles, quads, 6);
}

pub fn setWorldDimensions(self: *QuadRenderer, width: u16, height: u16) !void {
    try self.shader.setUniform(u32, "world_width", @intCast(width));
    try self.shader.setUniform(u32, "world_height", @intCast(height));
}

pub fn setProjection(self: *QuadRenderer, proj: dim.Mat4(f32)) !void {
    try self.shader.setUniform(dim.Mat4(f32), "projection", proj);
}
