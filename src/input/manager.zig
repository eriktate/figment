const std = @import("std");
const events = @import("events.zig");
const Controller = @import("controller.zig").Controller;
const glfw = @import("../glfw.zig");
const c = @import("../c.zig");

pub var ready: bool = false;
pub var quit: bool = false;
pub var controllers: std.ArrayList(Controller) = undefined;

pub fn init(alloc: std.mem.Allocator) !void {
    controllers = try std.ArrayList(Controller).initCapacity(alloc, 4);
    // init gamepads through backend here
    // if no controllers are given, we'll just attach a controller for keyboard use
    if (controllers.items.len == 0) {
        try controllers.append(Controller.init(0));
    }

    ready = true;
}

pub fn deinit() void {
    controllers.deinit();
}

fn handleDeviceEvent(ev: events.DeviceEvent) !void {
    switch (ev.change) {
        .added => try controllers.append(ev.controller.?),
        .removed => {
            for (controllers.items, 0..) |ctrl, idx| {
                if (ctrl.id == ev.id) {
                    _ = controllers.orderedRemove(idx);
                    return;
                }
            }
        },
    }
}

pub fn handleEvent(ev: events.Event) !void {
    switch (ev) {
        .device => |dev| try handleDeviceEvent(dev),
        .quit => quit = true,
        else => for (controllers.items) |*ctrl| {
            ctrl.handleEvent(ev);
        },
    }

    for (controllers.items) |ctrl| {
        if (ctrl.getInput(.pause).isActive()) {
            quit = true;
        }
    }
}

pub fn flush() void {
    for (controllers.items) |*ctrl| {
        ctrl.flush();
    }
}

pub export fn glfwKeyCallback(_: ?*c.GLFWwindow, key: i32, _: i32, action: i32, _: i32) void {
    const key_event = events.KeyEvent{
        .key = glfw.resolveKey(key) orelse return,
        .pressed = action == c.GLFW_PRESS or action == c.GLFW_REPEAT,
    };

    std.log.info("{any} {} {}", .{ key_event.key, key_event.pressed, action });
    handleEvent(events.Event{
        .key = key_event,
    }) catch |err| std.log.err("failed to process key event: {any}", .{err});
}
