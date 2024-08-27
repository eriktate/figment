const std = @import("std");
const gl = @import("../gl.zig");
const r = @import("../render.zig");
const dim = @import("../dim.zig");

const Shader = gl.Shader;
const Line = r.Line;
const Vertex = r.Vertex;

const MAX_LINES = 200_000;

const DebugRenderer = @This();
shader: Shader,
vao: gl.VAO,

lines: std.ArrayList(Line),
indices: []u32,
alloc: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator, vs_path: []const u8, fs_path: []const u8) !DebugRenderer {
    var renderer: DebugRenderer = undefined;
    var shader = try Shader.init(vs_path, fs_path);
    renderer.shader = shader;
    renderer.alloc = alloc;
    renderer.lines = std.ArrayList(Line).init(alloc);
    shader.use();

    renderer.vao = gl.VAO.init();
    const pos_offset = @offsetOf(Vertex, "pos");
    const color_offset = @offsetOf(Vertex, "color");

    renderer.vao.addAttr(f32, 3, @sizeOf(Vertex), pos_offset);
    renderer.vao.addAttr(u8, 4, @sizeOf(Vertex), color_offset);

    // indices are always the same, so we can precompute their value
    // and buffer them once
    renderer.indices = try alloc.alloc(u32, MAX_LINES * 2);
    for (0..MAX_LINES) |idx| {
        const index = idx * 2;
        const vertex: u32 = @intCast(idx * 2);

        renderer.indices[index] = vertex;
        renderer.indices[index + 1] = vertex + 1;
    }
    renderer.vao.setIndices(renderer.indices);

    renderer.vao.unbind();
    return renderer;
}

pub fn deinit(self: *DebugRenderer) void {
    self.lines.deinit();
}

pub fn render(self: *DebugRenderer) !void {
    self.shader.use();
    self.vao.drawIndices(Line, .lines, self.lines.items, 2);
    self.lines.items.len = 0;
}

pub fn setWorldDimensions(self: *DebugRenderer, width: u16, height: u16) !void {
    try self.shader.setUniform(u32, "world_width", @intCast(width));
    try self.shader.setUniform(u32, "world_height", @intCast(height));
}

pub fn setProjection(self: *DebugRenderer, proj: dim.Mat4) !void {
    try self.shader.setUniform(dim.Mat4, "projection", proj);
}

pub fn pushLine(self: *DebugRenderer, from: r.Pos, to: r.Pos) !void {
    try self.lines.append(Line{ .from = .{ .pos = from }, .to = .{ .pos = to } });
}
