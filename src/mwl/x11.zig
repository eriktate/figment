const std = @import("std");
const c = @import("../c.zig");
const mwl = @import("mwl.zig");
const input = @import("input.zig");
const getKey = @import("x11/key.zig").getKey;
const events = @import("../input/events.zig");
const RingBuffer = @import("../ringbuffer.zig").RingBuffer;

const XErr = error{
    // Target errors
    OpenDisplay,
    NoopCmd,
    Flush,

    // Window errors
    ClearWin,
    MapWin,
    UnmapWin,
    DestroyWin,
    SetTitle,

    // GL errors
    GetDisplayEGL,
    InitEGL,
    ConfigEGL,
    BindApiEGL,
    CreateSurfaceEGL,
    CreateContextEGL,
    MakeCurrentEGL,
};

const EGL = struct {
    display: c.EGLDisplay,
    surface: c.EGLSurface,
    ctx: c.EGLContext,

    pub fn init(win: Window) !EGL {
        const display = c.eglGetDisplay(win._target.display);
        if (display == c.EGL_NO_DISPLAY) {
            return XErr.GetDisplayEGL;
        }

        if (c.eglInitialize(display, null, null) == 0) {
            return XErr.InitEGL;
        }

        const attrs = [_]c.EGLint{
            c.EGL_SURFACE_TYPE,    c.EGL_WINDOW_BIT,
            c.EGL_RED_SIZE,        8,
            c.EGL_GREEN_SIZE,      8,
            c.EGL_BLUE_SIZE,       8,
            c.EGL_RENDERABLE_TYPE, c.EGL_OPENGL_BIT,
            c.EGL_NONE,
        };

        var config: c.EGLConfig = undefined;
        var config_count: i32 = 0;
        if (c.eglChooseConfig(display, &attrs, &config, 1, &config_count) == 0) {
            return XErr.ConfigEGL;
        }

        if (c.eglBindAPI(c.EGL_OPENGL_API) == 0) {
            return XErr.BindApiEGL;
        }

        const surface = c.eglCreateWindowSurface(display, config, win._handle, null);
        if (surface == c.EGL_NO_SURFACE) {
            return XErr.CreateSurfaceEGL;
        }

        const ctx_attrs = [_]c.EGLint{
            c.EGL_CONTEXT_MAJOR_VERSION, win.opts.gl_major,
            c.EGL_CONTEXT_MINOR_VERSION, win.opts.gl_minor,
            c.EGL_NONE,
        };

        const ctx = c.eglCreateContext(display, config, c.EGL_NO_CONTEXT, &ctx_attrs);
        if (ctx == c.EGL_NO_CONTEXT) {
            return XErr.CreateContextEGL;
        }

        return EGL{
            .display = display,
            .surface = surface,
            .ctx = ctx,
        };
    }

    pub fn makeCurrent(self: EGL) !void {
        if (c.eglMakeCurrent(self.display, self.surface, self.surface, self.ctx) == 0) {
            return XErr.MakeCurrentEGL;
        }
    }

    pub fn deinit(self: EGL) void {
        if (c.eglMakeCurrent(self.display, c.EGL_NO_SURFACE, c.EGL_NO_SURFACE, c.EGL_NO_CONTEXT) == 0) {
            std.log.debug("failed to unmount context", .{});
        }

        if (c.eglDestroySurface(self.display, self.surface) == 0) {
            std.log.debug("failed to destroy EGL surface", .{});
        }

        if (c.eglDestroyContext(self.display, self.ctx) == 0) {
            std.log.debug("failed to destroy EGL surface", .{});
        }

        if (c.eglTerminate(self.display) == 0) {
            std.log.debug("failed to destroy EGL surface", .{});
        }

        if (c.eglReleaseThread() == 0) {
            std.log.debug("failed to destroy EGL surface", .{});
        }
    }
};

pub const Window = struct {
    // platform specific
    _target: Target,
    _handle: c.Window,
    _egl: EGL,
    _raw_buffer: [128]events.Event,
    _event_buffer: RingBuffer(events.Event),

    // common API
    title: [256]u8 = std.mem.zeroes([256]u8),
    x: u16,
    y: u16,
    w: u16,
    h: u16,
    opts: mwl.WinOpts,

    pub fn clear(self: Window) XErr!void {
        if (c.XClearWindow(self._target.display, self._handle) == 0) {
            return XErr.ClearWin;
        }
    }

    pub fn flush(self: Window) XErr!void {
        _ = c.eglSwapBuffers(self._egl.display, self._egl.surface);
        return self._target.flush();
    }

    pub fn deinit(self: Window) void {
        self._egl.deinit();

        // ignore unmap errors for now
        if (c.XUnmapWindow(self._target.display, self._handle) == 0) {
            // TODO (soggy): consider accepting a log function for these
            std.log.warn("failed to unmap window", .{});
        }

        if (c.XDestroyWindow(self._target.display, self._handle) == 0) {
            std.log.warn("failed to destroy window", .{});
        }

        self._target.deinit();
    }

    pub fn setTitle(self: *Window, title: []const u8) !void {
        std.mem.copyForwards(u8, self.title[0..], title);
        self.title[title.len] = '0';

        if (c.XStoreName(self._target.display, self._handle, @ptrCast(&self.title)) == 0) {
            return XErr.SetTitle;
        }
    }

    pub fn makeContextCurrent(self: Window) !void {
        try self._egl.makeCurrent();
    }

    pub fn pollEvents(self: *Window) !void {
        var ev: c.XEvent = undefined;

        while (c.XEventsQueued(self._target.display) > 0) {
            if (c.XNextEvent(self._target.display, &ev) == 0) {
                std.log.warn("failed to get next event", .{});
            }
            switch (ev.type) {
                c.KeyPress => self._event_buffer.push(.{ .key = .{
                    .key = getKey(ev.xkey.keycode),
                    .pressed = true,
                } }),
            }
        }
    }
};

const Target = struct {
    display: ?*c.Display,
    screen: c_int,
    root_win: c.Window,

    fn init() XErr!Target {
        const display = try initDisplay();
        const screen = c.XDefaultScreen(display);

        return Target{
            .display = display,
            .screen = screen,
            .root_win = c.XRootWindow(display, screen),
        };
    }

    fn clearWindow(self: Target) XErr!void {
        if (self.window) |win| {
            if (c.XClearWindow(self.display, win) == 0) {
                return XErr.ClearWin;
            }
        }
    }

    fn deinit(self: Target) void {
        if (c.XCloseDisplay(self.display) == 0) {
            std.log.warn("failed to close connection to Xserver", .{});
        }
    }

    fn flush(self: Target) XErr!void {
        if (c.XFlush(self.display) == 0) {
            return XErr.Flush;
        }
    }
};

inline fn initDisplay() XErr!*c.Display {
    const display = c.XOpenDisplay(null) orelse return XErr.OpenDisplay;

    if (c.XNoOp(display) == 0) {
        return XErr.NoopCmd;
    }

    return display;
}

/// Create a new x11 window
pub fn createWindow(title: []const u8, x: u16, y: u16, w: u16, h: u16, opts: mwl.WinOpts) !Window {
    const target = try Target.init();

    const white = c.XWhitePixel(target.display, target.screen);
    const black = c.XBlackPixel(target.display, target.screen);

    const handle = c.XCreateSimpleWindow(
        target.display,
        target.root_win,
        @intCast(x), // x
        @intCast(y), // y
        @intCast(w), // width
        @intCast(h), // height
        1, // border_width
        white, // border color
        black, // background color
    );

    var win = Window{
        ._handle = handle,
        ._target = target,
        ._egl = undefined,
        .x = x,
        .y = y,
        .w = w,
        .h = h,
        .opts = opts,
    };

    try win.setTitle(title);
    win._egl = try EGL.init(win);

    if (c.XMapRaised(target.display, win._handle) == 0) {
        return XErr.MapWin;
    }

    try target.flush();

    return win;
}

pub usingnamespace @import("x11/joystick.zig");
