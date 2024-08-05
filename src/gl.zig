const c = @import("c.zig");
const Color = @import("render/render.zig").Color;

// re-exports
pub const VAO = @import("gl/vao.zig");
pub const Shader = @import("gl/shader.zig");

/// Specify the viewport dimensions.
pub fn viewport(x: u16, y: u16, w: u16, h: u16) void {
    c.glViewport(@intCast(x), @intCast(y), @intCast(w), @intCast(h));
}

// NOTE: this is an incomplete list
const Capability = enum(c.GLenum) {
    blend = c.GL_BLEND,
    depth_test = c.GL_DEPTH_TEST,
};

/// Clear the screen, optionally with a color.
pub fn clear(color: ?Color) void {
    const col = color orelse Color.init(0, 0, 0, 0);

    c.glClearColor(col.x, col.y, col.z, col.w);
    c.glClear(c.GL_COLOR_BUFFER_BIT);
}

pub fn enable(cap: Capability) void {
    c.glEnable(@intFromEnum(cap));
}

// NOTE: this is an incomplete list
const BlendFactor = enum(c.GLenum) {
    src_alpha = c.GL_SRC_ALPHA,
    one_minus_src_alpha = c.GL_ONE_MINUS_SRC_ALPHA,
};

pub fn blendFunc(sfactor: BlendFactor, dfactor: BlendFactor) void {
    c.glBlendFunc(@intFromEnum(sfactor), @intFromEnum(dfactor));
}
