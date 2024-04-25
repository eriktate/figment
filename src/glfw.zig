const std = @import("std");
const c = @import("c.zig");
const events = @import("input/events.zig");
const controller = @import("input/controller.zig");

fn generateBtnToGamepadMap() std.EnumArray(events.Button, c_int) {
    comptime {
        var map = std.EnumArray(events.Button, c_int).initUndefined();
        map.set(.a, c.GLFW_GAMEPAD_BUTTON_A);
        map.set(.b, c.GLFW_GAMEPAD_BUTTON_B);
        map.set(.x, c.GLFW_GAMEPAD_BUTTON_X);
        map.set(.y, c.GLFW_GAMEPAD_BUTTON_Y);
        map.set(.select, c.GLFW_GAMEPAD_BUTTON_BACK);
        map.set(.start, c.GLFW_GAMEPAD_BUTTON_START);
        map.set(.up, c.GLFW_GAMEPAD_BUTTON_DPAD_UP);
        map.set(.down, c.GLFW_GAMEPAD_BUTTON_DPAD_DOWN);
        map.set(.left, c.GLFW_GAMEPAD_BUTTON_DPAD_LEFT);
        map.set(.right, c.GLFW_GAMEPAD_BUTTON_DPAD_RIGHT);
        map.set(.r1, c.GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER);
        map.set(.r3, c.GLFW_GAMEPAD_BUTTON_RIGHT_THUMB);
        map.set(.l1, c.GLFW_GAMEPAD_BUTTON_LEFT_BUMPER);
        map.set(.l3, c.GLFW_GAMEPAD_BUTTON_LEFT_THUMB);

        return map;
    }
}

const gamepad_to_btn = [_]events.Button{
    .a,
    .b,
    .x,
    .y,
    .select,
    .start,
    .menu,
    .up,
    .down,
    .left,
    .right,
    .r1,
    .r3,
    .l1,
    .l3,
};

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

    if (c.glfwGetGamepadState(gamepad_id, &gamepad_state) != 1) {
        std.log.err("failed to get gamepad state", .{});
    }

    // simulate button events based on current gamepad state
    for (gamepad_to_btn, 0..) |btn, gamepad_btn| {
        const evt = events.Event{
            .button = .{
                .id = gamepad_id,
                .button = btn,
                .pressed = gamepad_state.buttons[gamepad_btn] == 1,
            },
        };

        ctrl.handleEvent(evt);
    }
}

pub fn getTime() f64 {
    return c.glfwGetTime();
}
