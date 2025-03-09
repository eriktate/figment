const std = @import("std");
const log = @import("../log.zig");
const c = @import("c");
const mwl = @import("mwl.zig");
const input = @import("input.zig");
const key = @import("x11/key.zig");
const joystick = @import("x11/joystick.zig");
const events = @import("../input/events.zig");
const RingBuffer = @import("../ringbuffer.zig").RingBuffer;
const Controller = @import("../input/controller.zig").Controller;

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
    InputMask,
    AutoRepeat,

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
        log.info("init EGL", .{});
        const display = c.eglGetDisplay(win._target.display);
        if (display == c.EGL_NO_DISPLAY) {
            return XErr.GetDisplayEGL;
        }

        if (c.eglInitialize(display, null, null) == 0) {
            return XErr.InitEGL;
        }

        const attrs = [_]c.EGLint{
            c.EGL_SURFACE_TYPE,      c.EGL_WINDOW_BIT,
            c.EGL_RED_SIZE,          8,
            c.EGL_GREEN_SIZE,        8,
            c.EGL_BLUE_SIZE,         8,
            c.EGL_RENDERABLE_TYPE,   c.EGL_OPENGL_BIT,
            c.EGL_MIN_SWAP_INTERVAL, 0,
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
    _event_buffer: RingBuffer(events.Event),
    _joystick_mgr: ?joystick.JoystickManager = null,

    opts: mwl.WinOpts,

    pub fn swap(self: *Window) !void {
        _ = c.eglSwapBuffers(self._egl.display, self._egl.surface);
        try self.pollEvents();
    }

    pub fn deinit(self: *Window) void {
        self._egl.deinit();

        // closing the display will automatically clean up created windows and other resources
        self._target.deinit();
        self._event_buffer.deinit();
    }

    pub fn setTitle(self: *Window, title: []const u8) !void {
        var name: c.XTextProperty = undefined;
        if (c.XStringListToTextProperty(@ptrCast(@constCast(&title)), 1, &name) == 0) {
            return XErr.SetTitle;
        }

        c.XSetWMName(self._target.display, self._handle, &name);
        // if (c.XStoreName(self._target.display, self._handle, @ptrCast(&title)) == 0) {
        //     return XErr.SetTitle;
        // }
    }

    pub fn poll(self: *Window, _: []Controller) !?events.Event {
        return self._event_buffer.next();
    }

    pub fn makeContextCurrent(self: Window) !void {
        try self._egl.makeCurrent();
    }

    fn pollEvents(self: *Window) !void {
        var ev: c.XEvent = undefined;
        var peek: c.XEvent = undefined;

        while (c.XPending(self._target.display) > 0) {
            _ = c.XNextEvent(self._target.display, &ev);
            switch (ev.type) {
                c.KeyPress => self._event_buffer.push(.{ .key = .{
                    .key = key.getKey(ev.xkey.keycode),
                    .pressed = true,
                } }),
                c.KeyRelease => {
                    // X11 automatically sends key release events when keyrepeat is turned on, but turning it off
                    // permanently affects the entire system. Checking if there's an immediate press for the same
                    // keycode after a received release is dumb hack to avoid keyrepeat behavior without impacting
                    // the entire Xserver
                    if (c.XPending(self._target.display) > 0) {
                        _ = c.XPeekEvent(self._target.display, &peek);
                        if (peek.type == c.KeyPress and peek.xkey.keycode == ev.xkey.keycode) {
                            continue;
                        }
                    }

                    self._event_buffer.push(.{ .key = .{
                        .key = key.getKey(ev.xkey.keycode),
                        .pressed = false,
                    } });
                },
                else => {},
            }
        }

        if (self._joystick_mgr) |*mgr| {
            try mgr.poll(&self._event_buffer);
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
    log.info("open display", .{});
    const display = c.XOpenDisplay(null) orelse return XErr.OpenDisplay;
    log.info("opened display", .{});

    if (c.XNoOp(display) == 0) {
        return XErr.NoopCmd;
    }

    return display;
}

/// Create a new x11 window
pub fn createWindow(alloc: std.mem.Allocator, title: []const u8, w: u16, h: u16, opts: mwl.WinOpts) !Window {
    log.info("create window", .{});
    const target = try Target.init();

    const white = c.XWhitePixel(target.display, target.screen);
    const black = c.XBlackPixel(target.display, target.screen);

    const handle = c.XCreateSimpleWindow(
        target.display,
        target.root_win,
        @intCast(0), // x
        @intCast(0), // y
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
        ._event_buffer = try RingBuffer(events.Event).initAlloc(alloc, 128),
        .opts = opts,
    };

    try win.setTitle(title);
    win._egl = try EGL.init(win);

    if (c.XSelectInput(target.display, handle, c.KeyPressMask | c.KeyReleaseMask | c.PointerMotionMask | c.ButtonPressMask | c.ButtonReleaseMask | c.ButtonMotionMask) == 0) {
        return XErr.InputMask;
    }

    key.initializeKeycodeMap(target.display);
    if (c.XMapRaised(target.display, win._handle) == 0) {
        return XErr.MapWin;
    }

    try win.makeContextCurrent();

    if (!win.opts.vsync) {
        // egl doesn't want to disable vsync for some reason, might need to investigate using glx instead
        switch (c.eglSwapInterval(win._target.display, @intCast(0))) {
            c.EGL_FALSE => log.err("something went wrong disabling vsync", .{}),
            c.EGL_BAD_CONTEXT => log.err("bad context for disabling vsync", .{}),
            c.EGL_BAD_SURFACE => log.err("bad surface for disabling vsync", .{}),
            else => {},
        }
    }

    if (opts.enable_joysticks) {
        win._joystick_mgr = try joystick.JoystickManager.init(alloc);
        const joystick_count = try win._joystick_mgr.?.detectJoysticks();
        log.info("detected {d} joysticks", .{joystick_count});
    }

    return win;
}

pub usingnamespace @import("x11/joystick.zig");
