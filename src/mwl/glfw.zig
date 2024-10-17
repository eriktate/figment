const std = @import("std");
const c = @import("c");

const WinOpts = @import("mwl.zig").WinOpts;
const WinErr = @import("mwl.zig").WinErr;
const Mode = @import("mwl.zig").Mode;
const glfw = @import("../glfw.zig");
const input_mgr = @import("../input/manager.zig");
const RingBuffer = @import("../ringbuffer.zig").RingBuffer;
const events = @import("../input/events.zig");

const MAX_INPUT_BUFFER = 64;

// TODO (soggy): should this actually be a lookup per window?
var raw_events: [MAX_INPUT_BUFFER]events.Event = undefined;
var event_buffer = RingBuffer(events.Event).init(&raw_events);

pub const Window = struct {
    win: ?*c.GLFWwindow,
    events: RingBuffer(events.Event),

    pub fn setTitle(self: *Window, title: [*c]const u8) !void {
        c.glfwSetWindowTitle(self.win, title);
    }

    pub fn setVsync(_: *Window, vsync: bool) void {
        c.glfwSwapInterval(@intFromBool(vsync));
    }

    pub fn setMode(_: *Window, _: Mode) void {
        unreachable;
    }

    pub fn getTime(_: Window) f64 {
        return c.glfwGetTime();
    }

    pub fn poll(_: Window) !?events.Event {
        c.glfwPollEvents();
        return event_buffer.next();
    }

    pub fn swap(self: Window) void {
        c.glfwSwapBuffers(self.win);
    }

    pub fn deinit(self: Window) void {
        c.glfwDestroyWindow(self.win);
    }
};

export fn glfwKeyCallback(_: ?*c.GLFWwindow, key: i32, _: i32, action: i32, _: i32) void {
    const event = events.KeyEvent{
        .key = glfw.resolveKey(key) orelse return,
        .pressed = action == c.GLFW_PRESS or action == c.GLFW_REPEAT,
        // .pressed = action == c.GLFW_PRESS,
    };
    event_buffer.push(events.Event{ .key = event });
}

/// creates a new GLFW window
pub fn createWindow(title: [*c]const u8, w: u16, h: u16, opts: WinOpts) !Window {
    if (c.glfwInit() != 1) {
        return WinErr.GLFWInit;
    }

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, opts.gl_major);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, opts.gl_minor);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const win = c.glfwCreateWindow(@intCast(w), @intCast(h), title, null, null) orelse {
        return WinErr.GLFWCreateWindow;
    };

    c.glfwMakeContextCurrent(win);

    if (!opts.vsync) {
        c.glfwSwapInterval(0);
    }

    glfw.setKeyCallback(win, glfwKeyCallback);

    return Window{
        .win = win,
        .events = undefined,
    };
}
