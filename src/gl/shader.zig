const std = @import("std");
const c = @import("c");
const dim = @import("../dim.zig");

const ShaderErr = error{
    VertexCompileErr,
    FragmentCompileErr,
    LinkErr,
    InvalidUniformName,
};

const ShaderType = enum {
    vertex,
    fragment,
};

const Shader = @This();
id: u32,
vs_path: []const u8,
fs_path: []const u8,

fn compileShader(shader_type: ShaderType, src: []const u8) !u32 {
    const gl_type = switch (shader_type) {
        .vertex => c.GL_VERTEX_SHADER,
        .fragment => c.GL_FRAGMENT_SHADER,
    };

    const shader = c.glCreateShader(@intCast(gl_type));
    c.glShaderSource(shader, 1, @ptrCast(&src), null);
    c.glCompileShader(shader);

    var success: i32 = undefined;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        var buffer: [512]u8 = undefined;
        c.glGetShaderInfoLog(shader, 512, null, &buffer);
        std.log.err("failed to compile {s} shader: {s}", .{ @tagName(shader_type), buffer });
        return switch (shader_type) {
            .vertex => ShaderErr.VertexCompileErr,
            .fragment => ShaderErr.FragmentCompileErr,
        };
    }

    return shader;
}

pub fn init(vs_path: []const u8, fs_path: []const u8) !Shader {
    var vs_file = try std.fs.cwd().openFile(vs_path, .{ .mode = .read_only });
    var fs_file = try std.fs.cwd().openFile(fs_path, .{ .mode = .read_only });

    // 1MB max per shader file
    var buffer: [1024 * 1024 * 1]u8 = undefined;
    var len = try vs_file.readAll(buffer[0..]);
    buffer[len] = 0;

    const vertex = try compileShader(.vertex, buffer[0..]);
    defer c.glDeleteShader(vertex);

    len = try fs_file.readAll(buffer[0..]);
    buffer[len] = 0;
    const fragment = try compileShader(.fragment, buffer[0..]);
    defer c.glDeleteShader(fragment);

    const program = c.glCreateProgram();
    c.glAttachShader(program, vertex);
    c.glAttachShader(program, fragment);
    c.glLinkProgram(program);

    var success: i32 = undefined;
    c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);

    if (success == 0) {
        c.glGetProgramInfoLog(program, 512, null, &buffer);
        std.log.err("failed to link shader: {s}", .{buffer});
        c.glDeleteProgram(program);
        return ShaderErr.LinkErr;
    }

    return .{
        .id = program,
        .vs_path = vs_path,
        .fs_path = fs_path,
    };
}

pub fn reload(self: *Shader) !void {
    // reload errors should only log and leave the original shader alone
    const reloaded = init(self.vs_path, self.fs_path) catch return std.log.err("failed to reload shaders, see errors ^above^");
    c.glDeleteProgram(self.id);
    self.id = reloaded.id;
    self.use();
}

pub fn deinit(self: *Shader) void {
    c.glDeleteProgram(self.id);
}

pub fn use(self: Shader) void {
    c.glUseProgram(self.id);
}

pub fn setUniform(self: Shader, comptime T: type, name: []const u8, val: T) !void {
    self.use();
    var name_buffer: [128]u8 = undefined;
    const c_name = try std.fmt.bufPrintZ(name_buffer[0..], "{s}", .{name});
    const loc = c.glGetUniformLocation(self.id, c_name);
    if (loc == -1) {
        std.log.err("failed fetching uniform: {s}", .{c_name});
        return ShaderErr.InvalidUniformName;
    }

    switch (T) {
        f32 => c.glUniform1f(loc, val),
        f64 => c.glUniform1d(loc, val),
        u32 => c.glUniform1ui(loc, val),
        i32 => c.glUniform1i(loc, val),
        dim.Mat4(f32) => c.glUniformMatrix4fv(loc, 1, c.GL_FALSE, @ptrCast(&val)),
        else => @compileError("invalid type for shader uniform"),
    }
}
