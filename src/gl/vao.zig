const std = @import("std");
const c = @import("../c.zig");
const log = @import("../log.zig");

const DrawMode = enum(c_uint) {
    lines = c.GL_LINES,
    triangles = c.GL_TRIANGLES,
};

const BufferKind = enum {
    vertex,
    element,
};

const Buffer = struct {
    kind: BufferKind,
    id: u32,

    inline fn bind(self: Buffer) void {
        switch (self.kind) {
            .vertex => c.glBindBuffer(c.GL_ARRAY_BUFFER, self.id),
            .element => c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.id),
        }
    }

    inline fn unbind(self: Buffer) void {
        switch (self.kind) {
            .vertex => c.glBindBuffer(c.GL_ARRAY_BUFFER, 0),
            .element => c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, 0),
        }
    }
};

fn intToGL(comptime int: std.builtin.Type.Int) c.GLenum {
    return switch (int.signedness) {
        .signed => switch (int.bits) {
            8 => c.GL_BYTE,
            16 => c.GL_SHORT,
            32 => c.GL_INT,
            else => @compileError("invalid int size"),
        },
        .unsigned => switch (int.bits) {
            8 => c.GL_UNSIGNED_BYTE,
            16 => c.GL_UNSIGNED_SHORT,
            32 => c.GL_UNSIGNED_INT,
            else => @compileError("invalid int size"),
        },
    };
}

fn floatToGL(comptime float: std.builtin.Type.Float) c.GLenum {
    return switch (float.bits) {
        32 => c.GL_FLOAT,
        else => @compileError("invalid float size"),
    };
}

pub const VAO = @This();
id: u32,
vbo: Buffer,
ebo: Buffer,
attr_count: usize = 0,

pub fn init() VAO {
    var vao = VAO{
        .id = 0,
        .vbo = Buffer{ .kind = .vertex, .id = 0 },
        .ebo = Buffer{ .kind = .element, .id = 0 },
    };

    c.glGenVertexArrays(1, &vao.id);
    c.glGenBuffers(1, &vao.vbo.id);
    c.glGenBuffers(1, &vao.ebo.id);

    return vao;
}

// NOTE: You could automatically generate all vertex attribs given a single struct type, but because the resulting
// shaders depend on exact layouts I think it makes sense to force explicit definition of those layouts rather
// than implicitly defining them through struct field ordering.
pub fn addAttr(self: *VAO, typ: type, count: usize, stride: usize, offset: usize) void {
    self.bind();
    self.vbo.bind();
    c.glEnableVertexAttribArray(@intCast(self.attr_count));
    const info = @typeInfo(typ);
    switch (info) {
        .Int => |int| c.glVertexAttribIPointer(@intCast(self.attr_count), @intCast(count), intToGL(int), @intCast(stride), @ptrFromInt(offset)),
        .Float => |float| c.glVertexAttribPointer(@intCast(self.attr_count), @intCast(count), floatToGL(float), c.GL_FALSE, @intCast(stride), @ptrFromInt(offset)),
        else => @compileError("Invalid vertex attribute type: " ++ @typeName(typ)),
    }

    self.attr_count += 1;
}

pub inline fn bind(self: VAO) void {
    c.glBindVertexArray(self.id);
}

pub inline fn unbind(vao: VAO) void {
    c.glBindVertexArray(0);
    vao.vbo.unbind();
    vao.ebo.unbind();
}

pub fn genBuffer(kind: BufferKind) Buffer {
    var id: u32 = 0;
    c.glGenBuffers(1, &id);

    return Buffer{
        .kind = kind,
        .id = id,
    };
}

pub fn setIndices(self: VAO, indices: []u32) void {
    self.bind();
    self.ebo.bind();

    c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @intCast(indices.len * @sizeOf(u32)), indices.ptr, c.GL_STREAM_DRAW);
}

pub fn setVertices(self: VAO, T: type, data: []T) void {
    self.bind();
    self.vbo.bind();
    setVertexData(T, data);
}

pub fn draw(self: VAO, T: type, mode: DrawMode, data: []T) void {
    self.setVertices(T, data);
    _draw(mode);
    self.unbind();
}

pub fn drawIndices(self: VAO, T: type, mode: DrawMode, data: []T, indices_per_item: usize) void {
    self.setVertices(T, data);
    self.ebo.bind();
    _drawIndices(mode, @intCast(data.len * indices_per_item));
    self.unbind();
}

fn setVertexData(T: type, data: []T) void {
    c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(data.len * @sizeOf(T)), data.ptr, c.GL_STREAM_DRAW);
}

inline fn _draw(mode: DrawMode) void {
    // TODO (soggy): this probably shouldn't be 0
    c.glDrawArrays(@intFromEnum(mode), c.GL_UNSIGNED_INT, 0);
}

inline fn _drawIndices(mode: DrawMode, indices: usize) void {
    c.glDrawElements(@intFromEnum(mode), @intCast(indices), c.GL_UNSIGNED_INT, null);
}
