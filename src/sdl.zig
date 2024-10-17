const std = @import("std");
const c = @import("c");
const events = @import("input/events.zig");
const Controller = @import("input/controller.zig").Controller;

const SDLErr = error{
    FailedOpeningGamepad,
};

const Event = c.SDL_Event;

fn resolveKey(sym: c.SDL_Keysym) ?events.Key {
    return switch (sym.sym) {
        c.SDLK_a => .a,
        c.SDLK_b => .b,
        c.SDLK_c => .c,
        c.SDLK_d => .d,
        c.SDLK_e => .e,
        c.SDLK_f => .f,
        c.SDLK_g => .g,
        c.SDLK_h => .h,
        c.SDLK_i => .i,
        c.SDLK_j => .j,
        c.SDLK_k => .k,
        c.SDLK_l => .l,
        c.SDLK_m => .m,
        c.SDLK_n => .n,
        c.SDLK_o => .o,
        c.SDLK_p => .p,
        c.SDLK_q => .q,
        c.SDLK_r => .r,
        c.SDLK_s => .s,
        c.SDLK_t => .t,
        c.SDLK_u => .u,
        c.SDLK_v => .v,
        c.SDLK_w => .w,
        c.SDLK_x => .x,
        c.SDLK_y => .y,
        c.SDLK_z => .z,
        c.SDLK_1 => .one,
        c.SDLK_2 => .two,
        c.SDLK_3 => .three,
        c.SDLK_4 => .four,
        c.SDLK_5 => .five,
        c.SDLK_6 => .six,
        c.SDLK_7 => .seven,
        c.SDLK_8 => .eight,
        c.SDLK_9 => .nine,
        c.SDLK_0 => .zero,
        c.SDLK_SPACE => .space,
        c.SDLK_TAB => .tab,
        c.SDLK_LSHIFT => .l_shift,
        c.SDLK_RSHIFT => .r_shift,
        c.SDLK_LCTRL => .l_ctrl,
        c.SDLK_RCTRL => .r_ctrl,
        c.SDLK_LALT => .l_alt,
        c.SDLK_RALT => .r_alt,
        c.SDLK_RETURN => .enter,
        c.SDLK_LEFT => .l_arrow,
        c.SDLK_RIGHT => .r_arrow,
        c.SDLK_UP => .u_arrow,
        c.SDLK_DOWN => .d_arrow,
        c.SDLK_BACKSPACE => .backspace,
        c.SDLK_SEMICOLON => .semicolon,
        c.SDLK_ESCAPE => .escape,
        else => null,
    };
}

fn resolveButton(button: c.SDL_GameControllerButton) ?events.Button {
    return switch (button) {
        c.SDL_CONTROLLER_BUTTON_A => .a,
        c.SDL_CONTROLLER_BUTTON_B => .b,
        c.SDL_CONTROLLER_BUTTON_X => .x,
        c.SDL_CONTROLLER_BUTTON_Y => .y,
        c.SDL_CONTROLLER_BUTTON_DPAD_UP => .up,
        c.SDL_CONTROLLER_BUTTON_DPAD_DOWN => .down,
        c.SDL_CONTROLLER_BUTTON_DPAD_LEFT => .left,
        c.SDL_CONTROLLER_BUTTON_DPAD_RIGHT => .right,
        c.SDL_CONTROLLER_BUTTON_LEFTSHOULDER => .l1,
        c.SDL_CONTROLLER_BUTTON_LEFTSTICK => .l3,
        c.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER => .r1,
        c.SDL_CONTROLLER_BUTTON_RIGHTSTICK => .r3,
        c.SDL_CONTROLLER_BUTTON_BACK => .select,
        c.SDL_CONTROLLER_BUTTON_START => .start,
        else => null,
    };
}

fn resolveMouseButton(button: u8) ?events.MouseButton {
    return switch (button) {
        c.SDL_BUTTON_LEFT => .m1,
        c.SDL_BUTTON_RIGHT => .m2,
        c.SDL_BUTTON_MIDDLE => .m3,
        c.SDL_BUTTON_X1 => .m4,
        c.SDL_BUTTON_X2 => .m5,
        else => null,
    };
}

fn resolveAxis(axis: c.SDL_GameControllerAxis) ?events.Axis {
    return switch (axis) {
        c.SDL_CONTROLLER_AXIS_LEFTX => .l_stick_x,
        c.SDL_CONTROLLER_AXIS_LEFTY => .l_stick_y,
        c.SDL_CONTROLLER_AXIS_RIGHTX => .r_stick_x,
        c.SDL_CONTROLLER_AXIS_RIGHTY => .r_stick_y,
        c.SDL_CONTROLLER_AXIS_TRIGGERLEFT => .l_trigger,
        c.SDL_CONTROLLER_AXIS_TRIGGERRIGHT => .r_trigger,
        else => null,
    };
}

fn resolveAxisSDL(axis: events.Axis) c_int {
    return switch (axis) {
        .l_stick_x => c.SDL_CONTROLLER_AXIS_LEFTX,
        .l_stick_y => c.SDL_CONTROLLER_AXIS_LEFTY,
        .r_stick_x => c.SDL_CONTROLLER_AXIS_RIGHTX,
        .r_stick_y => c.SDL_CONTROLLER_AXIS_RIGHTY,
        .r_trigger => c.SDL_CONTROLLER_AXIS_TRIGGERRIGHT,
        .l_trigger => c.SDL_CONTROLLER_AXIS_TRIGGERLEFT,
        else => 0,
    };
}

fn resolveKeyEvent(ev: c.SDL_KeyboardEvent) ?events.Event {
    return .{ .key = .{
        .key = resolveKey(ev.keysym) orelse return null,
        .pressed = ev.state == c.SDL_PRESSED,
    } };
}

fn resolveButtonEvent(ev: c.SDL_ControllerButtonEvent) ?events.Event {
    return .{ .button = .{
        .button = resolveButton(ev.button) orelse return null,
        .pressed = ev.state == c.SDL_PRESSED,
        .id = @intCast(ev.which),
    } };
}

fn resolveAxisEvent(ev: c.SDL_ControllerAxisEvent) ?events.Event {
    return .{ .axis = .{
        .axis = resolveAxis(ev.axis) orelse return null,
        .strength = @as(f32, @floatFromInt(ev.value)) / @as(f32, @floatFromInt(std.math.maxInt(i16))),
        .id = @intCast(ev.which),
    } };
}

fn resolveMouseEvent(ev: c.SDL_MouseButtonEvent) ?events.Event {
    return .{
        .mouse = .{
            .button = resolveMouseButton(ev.button) orelse return null,
            .pressed = ev.state == c.SDL_PRESSED,
            .x = if (ev.x < 0) 0 else @intCast(ev.x),
            .y = if (ev.y < 0) 0 else @intCast(ev.y),
        },
    };
}

fn resolveDeviceEvent(ev: c.SDL_ControllerDeviceEvent) ?events.Event {
    const change: events.DeviceChange = switch (ev.type) {
        c.SDL_CONTROLLERDEVICEADDED => .added,
        c.SDL_CONTROLLERDEVICEREMOVED => .removed,
        else => return null,
    };

    const ctrl = switch (change) {
        .added => Controller.init(@intCast(ev.which)),
        .removed => null,
    };

    return .{ .device = .{
        .id = @intCast(ev.which),
        .change = change,
        .controller = ctrl,
    } };
}

pub fn resolveEvent(ev: c.SDL_Event) !?events.Event {
    return switch (ev.type) {
        c.SDL_KEYUP, c.SDL_KEYDOWN => resolveKeyEvent(ev.key),
        c.SDL_CONTROLLERBUTTONUP, c.SDL_CONTROLLERBUTTONDOWN => resolveButtonEvent(ev.cbutton),
        c.SDL_CONTROLLERAXISMOTION => resolveAxisEvent(ev.caxis),
        c.SDL_MOUSEBUTTONDOWN, c.SDL_MOUSEBUTTONUP => resolveMouseEvent(ev.button),
        c.SDL_CONTROLLERDEVICEADDED, c.SDL_CONTROLLERDEVICEREMOVED => resolveDeviceEvent(ev.cdevice),
        c.SDL_QUIT => .{ .quit = undefined },
        else => null,
    };
}

pub fn updateControllerAxes(ctrl: *Controller) void {
    if (c.SDL_GameControllerFromInstanceID(ctrl.id)) |gamepad| {
        for (ctrl.axis_map.iterator()) |entry| {
            const axis = entry.key_ptr.*;
            const bind = entry.value_ptr.*;

            const val = c.SDL_GameControllerGetAxis(gamepad, resolveAxisSDL(axis));
            ctrl.handleAxis(bind, @as(f32, val) / @as(f32, std.math.maxInt(i16)));
        }
    }
}

fn openGamepad(id: c.SDL_JoystickID) ?*c.SDL_GameController {
    return c.SDL_GameControllerOpen(id);
}

pub fn getControllers(alloc: std.mem.Allocator) !std.ArrayList(Controller) {
    var controllers = try std.ArrayList(Controller).initCapacity(alloc, 4);
    for (0..@intCast(c.SDL_NumJoysticks())) |id| {
        if (c.SDL_IsGameController(@intCast(id)) == 1) {
            const gamepad = openGamepad(@intCast(id));
            if (gamepad == null) {
                return SDLErr.FailedOpeningGamepad;
            }

            try controllers.append(Controller.init(id));
        }
    }

    return controllers;
}

pub fn pollEvent() !?events.Event {
    var event: c.SDL_Event = undefined;
    if (c.SDL_PollEvent(&event) == 1) {
        return try resolveEvent(event);
    }

    return null;
}

pub fn getTime() f64 {
    // using zig time because SDL precision is too low
    const ts: f64 = @floatFromInt(std.time.nanoTimestamp());
    return 1 / ts;
}
