const std = @import("std");
const c = @import("c");
const log = @import("log.zig");

const events = @import("input/events.zig");
const controller = @import("input/controller.zig");

// the order is the mapping, so make sure the ordering doesn't change
const gamepad_to_btn = [_]events.Button{
    .a,
    .b,
    .x,
    .y,
    .l1,
    .r1,
    .select,
    .start,
    .menu,
    .l3,
    .r3,
    .up,
    .right,
    .down,
    .left,
};

/// reverses the gamepad_to_btn map into an EnumArray
fn makeBtnToGamepadMap() std.EnumArray(events.Button, c_int) {
    comptime {
        var map = std.EnumArray(events.Button, c_int).initUndefined();
        for (gamepad_to_btn, 0..) |btn, idx| {
            map.set(btn, idx);
        }

        return map;
    }
}

const btn_to_gamepad_btn = makeBtnToGamepadMap();

pub fn resolveKey(key: c_int) ?events.Key {
    return switch (key) {
        c.GLFW_KEY_A => .a,
        c.GLFW_KEY_B => .b,
        c.GLFW_KEY_C => .c,
        c.GLFW_KEY_D => .d,
        c.GLFW_KEY_E => .e,
        c.GLFW_KEY_F => .f,
        c.GLFW_KEY_G => .g,
        c.GLFW_KEY_H => .h,
        c.GLFW_KEY_I => .i,
        c.GLFW_KEY_J => .j,
        c.GLFW_KEY_K => .k,
        c.GLFW_KEY_L => .l,
        c.GLFW_KEY_M => .m,
        c.GLFW_KEY_N => .n,
        c.GLFW_KEY_O => .o,
        c.GLFW_KEY_P => .p,
        c.GLFW_KEY_Q => .q,
        c.GLFW_KEY_R => .r,
        c.GLFW_KEY_S => .s,
        c.GLFW_KEY_T => .t,
        c.GLFW_KEY_U => .u,
        c.GLFW_KEY_V => .v,
        c.GLFW_KEY_W => .w,
        c.GLFW_KEY_X => .x,
        c.GLFW_KEY_Y => .y,
        c.GLFW_KEY_Z => .z,
        c.GLFW_KEY_1 => .one,
        c.GLFW_KEY_2 => .two,
        c.GLFW_KEY_3 => .three,
        c.GLFW_KEY_4 => .four,
        c.GLFW_KEY_5 => .five,
        c.GLFW_KEY_6 => .six,
        c.GLFW_KEY_7 => .seven,
        c.GLFW_KEY_8 => .eight,
        c.GLFW_KEY_9 => .nine,
        c.GLFW_KEY_0 => .zero,
        c.GLFW_KEY_SPACE => .space,
        c.GLFW_KEY_TAB => .tab,
        c.GLFW_KEY_LEFT_SHIFT => .l_shift,
        c.GLFW_KEY_RIGHT_SHIFT => .r_shift,
        c.GLFW_KEY_LEFT_CONTROL => .l_ctrl,
        c.GLFW_KEY_RIGHT_CONTROL => .r_ctrl,
        c.GLFW_KEY_LEFT_ALT => .l_alt,
        c.GLFW_KEY_RIGHT_ALT => .r_alt,
        c.GLFW_KEY_ENTER => .enter,
        c.GLFW_KEY_LEFT => .l_arrow,
        c.GLFW_KEY_RIGHT => .r_arrow,
        c.GLFW_KEY_UP => .u_arrow,
        c.GLFW_KEY_DOWN => .d_arrow,
        c.GLFW_KEY_BACKSPACE => .backspace,
        c.GLFW_KEY_SEMICOLON => .semicolon,
        c.GLFW_KEY_ESCAPE => .escape,
        else => null,
    };
}

const gamepad_to_axis = [_]events.Axis{
    .l_stick_x,
    .l_stick_y,
    .r_stick_x,
    .r_stick_y,
    .l_trigger,
    .r_trigger,
};

fn makeAxisToGamepadMap() std.EnumArray(events.Axis, c_int) {
    comptime {
        var map = std.EnumArray(events.Axis, c_int).initUndefined();
        for (gamepad_to_axis, 0..) |axis, idx| {
            map.set(axis, idx);
        }

        return map;
    }
}

const axis_to_gamepad = makeAxisToGamepadMap();

fn getGamepadButton(btn: events.Button) c_int {
    return btn_to_gamepad_btn.get(btn);
}

export fn keyCallback(_: ?*c.GLFWwindow, key: i32, _: i32, action: i32, _: i32) void {
    const key_event = events.KeyEvent{
        .key = resolveKey(key) orelse return,
        .pressed = action == c.GLFW_PRESS,
    };

    std.log.info("{any}", .{key_event});
}

pub fn pollEvent() !?events.Event {
    c.glfwPollEvents();
    return null;
}

pub fn setKeyCallback(win: ?*c.GLFWwindow, keyfn: c.GLFWkeyfun) void {
    _ = c.glfwSetKeyCallback(win, keyfn);
}

pub fn captureGamepadState(ctrl: *controller.Controller) void {
    const gamepad_id: c_int = @intCast(ctrl.id);
    var gamepad_state: c.GLFWgamepadstate = undefined;

    if (c.glfwGetGamepadState(gamepad_id, &gamepad_state) == c.GLFW_FALSE) {
        // std.log.err("failed to get gamepad state for {d}", .{gamepad_id});
    }

    // simulate button events based on current gamepad state
    for (gamepad_to_btn, 0..) |btn, gamepad_btn| {
        const evt = events.Event{
            .button = .{
                .id = @intCast(gamepad_id),
                .button = btn,
                .pressed = gamepad_state.buttons[gamepad_btn] == 1,
            },
        };

        ctrl.handleEvent(evt);
    }

    for (gamepad_to_axis, 0..) |axis, gamepad_axis| {
        const evt = events.Event{
            .axis = .{
                .id = @intCast(gamepad_id),
                .axis = axis,
                .strength = gamepad_state.axes[gamepad_axis],
            },
        };

        ctrl.handleEvent(evt);
    }
}

pub fn findFirstGamepad() usize {
    for (c.GLFW_JOYSTICK_1..c.GLFW_JOYSTICK_LAST + 1) |id| {
        log.info("checking joystick: {d}", .{id});
        if (c.glfwJoystickPresent(@intCast(id)) == c.GLFW_TRUE) {
            var axes_count: c_int = undefined;
            if (c.glfwGetJoystickAxes(@intCast(id), &axes_count) == c.GLFW_FALSE) {
                continue;
            }

            const name = c.glfwGetJoystickName(@intCast(id));
            const guid = c.glfwGetJoystickGUID(@intCast(id));
            if (axes_count > 4) {
                log.info("found joystick {d}:'{s}' GUID={s}'", .{ id, name, guid });
                return @intCast(id);
            }
        }
    }

    return 0;
}

pub fn getTime() f64 {
    return c.glfwGetTime();
}

pub fn setTitle(win: ?*c.GLFWwindow, title: []const u8) void {
    var buf: [256]u8 = undefined;
    @memcpy(buf[0..], title);
    buf[title.len] = 0;
    c.glfwSetWindowTitle(win, buf[0..]);
}
