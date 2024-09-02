const c = @import("c.zig");
const std = @import("std");
const sdl = @import("sdl.zig");
const glfw = @import("glfw.zig");
const input_mgr = @import("input/manager.zig");
const events = @import("input/events.zig");
const config = @import("config");
const gl = @import("gl.zig");
const mwl = @import("mwl/src/mwl.zig");

pub const WindowErr = error{
    // SDL backend
    SDLInit,
    SDLCreateWindow,
    SDLCreateContext,

    // GLFW backend
    GLFWInit,
    GLFWCreateWindow,
    GLFWCreateContext,

    // Generic window errors
    Init,
    CreateWindow,
    GLInit,
    GLVersion,
};

pub const Style = enum {
    windowed,
    borderless,
    fullscreen,
};

pub const Opts = struct {
    style: Style = .borderless,
    vsync: bool = true,
};

pub const Backend = enum {
    sdl,
    glfw,
    mwl,
};

const SDL_Window = struct {
    win: *c.SDL_Window,
    ctx: c.SDL_GLContext,
};

const GLFW_Window = struct {
    win: *c.GLFWwindow,
};

const BackendWindow = union(Backend) {
    sdl: SDL_Window,
    glfw: GLFW_Window,
    mwl: mwl.Window,
};

pub const Window = struct {
    w: u16,
    h: u16,
    title: [512]u8,
    win: BackendWindow,

    opts: Opts,

    pub fn deinit(self: Window) void {
        switch (self.win) {
            .sdl => |backend| {
                c.SDL_DestroyWindow(backend.win);
                c.SDL_Quit();
            },
            .glfw => |backend| {
                c.glfwDestroyWindow(backend.win);
                c.glfwTerminate();
            },
            .mwl => |backend| {
                backend.deinit();
            },
        }
    }

    pub fn setTitle(self: *Window, title: []const u8) !void {
        std.mem.copyForwards(u8, &self.title, title);
        self.title[title.len] = 0;
        switch (self.win) {
            .sdl => |backend| c.SDL_SetWindowTitle(backend.win, &self.title),
            .glfw => |backend| c.glfwSetWindowTitle(backend.win, &self.title),
            .mwl => |*backend| try backend.setTitle(title),
        }
    }

    pub fn swap(self: Window) void {
        switch (self.win) {
            .sdl => |backend| {
                _ = c.SDL_GL_SwapWindow(backend.win);
            },
            .glfw => |backend| {
                c.glfwSwapBuffers(backend.win);
            },
            .mwl => |backend| {
                backend.flush() catch {};
            },
        }
    }

    pub fn clear(_: Window) void {
        c.glClearColor(0.5, 0.7, 1.0, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }

    pub fn poll(self: Window) !?events.Event {
        return try switch (self.win) {
            .sdl => sdl.pollEvent(),
            .glfw => glfw.pollEvent(),
            .mwl => null,
        };
    }

    pub fn getTime(self: Window) f64 {
        return switch (self.win) {
            .glfw => glfw.getTime(),
            .sdl => sdl.getTime(),
            .mwl => @floatFromInt(std.time.nanoTimestamp()),
        };
    }
};

fn initSDL(window: Window) !BackendWindow {
    errdefer std.log.err("SDL error: {s}", .{c.SDL_GetError()});
    if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_GAMECONTROLLER) != 0) {
        return WindowErr.SDLInit;
    }

    _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_PROFILE_MASK, c.SDL_GL_CONTEXT_PROFILE_CORE);
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MINOR_VERSION, 3);

    const style_flags: c_int = switch (window.opts.style) {
        .borderless => c.SDL_WINDOW_BORDERLESS,
        .windowed => 0,
        .fullscreen => c.SDL_WINDOW_FULLSCREEN,
    };

    const flags = c.SDL_WINDOW_OPENGL | style_flags;
    const win = c.SDL_CreateWindow(&window.title, c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, window.w, window.h, @intCast(flags)) orelse return WindowErr.CreateWindow;
    const ctx = c.SDL_GL_CreateContext(win) orelse {
        c.SDL_Log("Unable to create context: %s", c.SDL_GetError());
        return WindowErr.SDLCreateContext;
    };

    _ = c.SDL_GL_MakeCurrent(win, ctx);
    if (!window.opts.vsync) {
        _ = c.SDL_GL_SetSwapInterval(0);
    }

    return .{ .sdl = .{ .win = win, .ctx = ctx } };
}

fn initGLFW(window: Window) !BackendWindow {
    if (c.glfwInit() != 1) {
        return WindowErr.GLFWInit;
    }

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const win = c.glfwCreateWindow(window.w, window.h, &window.title, null, null) orelse {
        return WindowErr.GLFWCreateWindow;
    };

    c.glfwMakeContextCurrent(win);

    if (c.gl3wInit() == 1) {
        return WindowErr.GLInit;
    }

    if (!window.opts.vsync) {
        c.glfwSwapInterval(0);
    }
    glfw.setKeyCallback(win, input_mgr.glfwKeyCallback);
    return .{ .glfw = .{ .win = win } };
}

fn initMWL(window: Window) !BackendWindow {
    std.log.info("initMWL", .{});
    const win = try mwl.createWindow("mythic *float*", 0, 0, window.w, window.h, .{
        .mode = .windowed,
        .vsync = false,
        .gl_major = 3,
        .gl_minor = 3,
    });

    try win.makeContextCurrent();
    if (c.gl3wInit() == 1) {
        return WindowErr.GLInit;
    }

    if (c.gl3wIsSupported(3, 3) == 0) {
        return WindowErr.GLInit;
    }

    return .{ .mwl = win };
}

pub fn init(w: u16, h: u16, title: []const u8, opts: Opts) !Window {
    var window = Window{
        .w = w,
        .h = h,
        .title = undefined,
        .win = undefined,
        .opts = opts,
    };

    std.mem.copyForwards(u8, &window.title, title);
    window.title[title.len] = 0;

    // window.win = if (config.opts.backend == .sdl) try initSDL(window) else try initGLFW(window);
    window.win = try initMWL(window);

    gl.viewport(0, 0, w, h);

    // Blend settings should probably be managed by the renderer
    gl.enable(.blend);
    gl.blendFunc(.src_alpha, .one_minus_src_alpha);

    return window;
}
