const std = @import("std");
const log = @import("../log.zig");
const c = @import("c");
const gl = @import("../gl.zig");
const events = @import("../input/events.zig");
const config = @import("config");
const assert = std.debug.assert;
const time = std.time;

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
    enable_joysticks: bool = true,
};

pub const Mode = enum {
    windowed,
    fullscreen,
    borderless,
};

pub const Window = struct {
    alloc: std.mem.Allocator,

    _backend: backend.Window,
    timer: time.Timer,

    title: []u8,
    w: u16,
    h: u16,
    opts: WinOpts,

    fn copyTitle(self: *Window, title: []const u8) !void {
        assert(title.len < MAX_TITLE_LEN);
        self.title.len = MAX_TITLE_LEN;

        @memcpy(self.title[0..title.len], title);
        self.title[title.len] = 0;
        self.title.len = title.len;
    }

    pub fn setTitle(self: *Window, title: []const u8) !void {
        try copyTitle(self, title);
        try self._backend.setTitle(title);
    }

    pub fn setMode(self: *Window, mode: Mode) !void {
        self.opts.mode = mode;
        self._backend.setMode(mode);
    }

    pub fn setVsync(self: *Window, vsync: bool) !void {
        self.opts.vsync = vsync;
        self._backend.setVsync(vsync);
    }

    pub fn deinit(self: *Window) void {
        self._backend.deinit();
        self.alloc.free(self.title);
        self.alloc.destroy(self);
    }

    pub fn getTime(self: *Window) u64 {
        // return self._backend.getTime();

        // const nano_f64: f64 = @floatFromInt(std.time.nanoTimestamp());
        // return nano_f64 / 1000 / 1000 / 1000;
        return self.timer.read();
    }

    pub fn poll(self: *Window, controllers: []Controller) !?events.Event {
        return self._backend.poll(controllers);
    }

    pub fn clear(_: Window) void {
        c.glClearColor(0.5, 0.7, 1.0, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }

    pub fn swap(self: *Window) !void {
        try self._backend.swap();
    }
};

pub fn createWindow(alloc: std.mem.Allocator, title: []const u8, w: u16, h: u16, opts: WinOpts) !*Window {
    log.info("createWindow", .{});
    var win = try alloc.create(Window);
    win.* = Window{
        ._backend = undefined,
        .alloc = alloc,
        .w = w,
        .h = h,
        .opts = opts,
        .title = try alloc.alloc(u8, MAX_TITLE_LEN),
        .timer = undefined,
    };

    win.timer = try time.Timer.start();
    try win.copyTitle(title);
    win._backend = try backend.createWindow(alloc, win.title, w, h, opts);

    if (c.gl3wInit() == 1) {
        return WinErr.GLInit;
    }

    gl.viewport(0, 0, w, h);

    // Blend settings should probably be managed by the renderer
    gl.enable(.blend);
    gl.blendFunc(.src_alpha, .one_minus_src_alpha);

    return win;
}

pub fn destroyWindow(win: *Window) void {
    win.deinit();
}
