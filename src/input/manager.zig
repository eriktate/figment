const std = @import("std");
const events = @import("events.zig");
const glfw = @import("../glfw.zig");
const log = @import("../log.zig");

const Controller = @import("controller.zig").Controller;

pub var ready: bool = false;
pub var quit: bool = false;
pub var controllers: std.ArrayList(Controller) = undefined;

pub fn init(alloc: std.mem.Allocator) !void {
    controllers = try std.ArrayList(Controller).initCapacity(alloc, 4);
    // init gamepads through backend here
    // if no controllers are given, we'll just attach a controller for keyboard use
    if (controllers.items.len == 0) {
        // TODO (soggy): this assumes glfw backend and will break if any others are used
        try controllers.append(Controller.init(glfw.findFirstGamepad()));
    }

    ready = true;
}

pub fn deinit() void {
    controllers.deinit();
}

fn handleDeviceEvent(ev: events.DeviceEvent) !void {
    switch (ev.change) {
        .added => {
            log.info("adding controller", .{});
            return try controllers.append(ev.controller.?);
        },
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
