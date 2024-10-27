const std = @import("std");
const c = @import("c");
const gl = @import("../gl.zig");
const events = @import("../input/events.zig");
const config = @import("config");
const assert = std.debug.assert;

const Controller = @import("../input/controller.zig").Controller;

const MAX_TITLE_LEN = 256;

pub const Backend = enum {
    sdl,
    glfw,
    mwl,
};

pub const WinErr = error{
    GLFWInit,
    GLFWCreateWindow,
    GLInit,
};

pub const backend = switch (config.opts.backend) {
    .sdl => @import("./backend.zig"),
    .glfw => @import("./glfw.zig"),
    .mwl => @import("./backend.zig"),
};

pub const WinOpts = struct {
    vsync: bool = true,
    mode: Mode = .windowed,
    gl_major: i32 = 3,
    gl_minor: i32 = 3,
};

pub const Mode = enum {
    windowed,
    fullscreen,
    borderless,
};

pub const Window = struct {
    _backend: backend.Window,

    title: []const u8,
    title_buf: [MAX_TITLE_LEN]u8,
    w: u16,
    h: u16,
    opts: WinOpts,

    pub fn setTitle(self: *Window, title: []const u8) !void {
        assert(title.len < MAX_TITLE_LEN);

        @memcpy(self.title_buf[0..title.len], title);
        self.title_buf[title.len] = 0;
        self.title.len = title.len;
        try self._backend.setTitle(&self.title_buf);
    }

    pub fn setMode(self: *Window, mode: Mode) !void {
        self.opts.mode = mode;
        self._backend.setMode(mode);
    }

    pub fn setVsync(self: *Window, vsync: bool) !void {
        self.opts.vsync = vsync;
        self._backend.setVsync(vsync);
    }

    pub fn deinit(self: Window) void {
        self._backend.deinit();
    }

    pub fn getTime(self: Window) f64 {
        return self._backend.getTime();
    }

    pub fn poll(self: *Window, controllers: []Controller) !?events.Event {
        return self._backend.poll(controllers);
    }

    pub fn clear(_: Window) void {
        c.glClearColor(0.5, 0.7, 1.0, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }

    pub fn swap(self: Window) void {
        self._backend.swap();
    }
};

pub fn createWindow(title: []const u8, w: u16, h: u16, opts: WinOpts) !Window {
    var win = Window{
        ._backend = undefined,
        .w = w,
        .h = h,
        .opts = opts,
        .title = undefined,
        .title_buf = std.mem.zeroes([MAX_TITLE_LEN]u8),
    };

    win.title = &win.title_buf;
    try win.setTitle(title);
    win._backend = try backend.createWindow(&win.title_buf, w, h, opts);

    if (c.gl3wInit() == 1) {
        return WinErr.GLInit;
    }

    gl.viewport(0, 0, w, h);

    // Blend settings should probably be managed by the renderer
    gl.enable(.blend);
    gl.blendFunc(.src_alpha, .one_minus_src_alpha);

    return win;
}
