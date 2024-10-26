const std = @import("std");
const AutoHashMap = @import("std").hash_map.AutoHashMap;
const events = @import("events.zig");
const Event = events.Event;

// TODO: this should be configurable instead of constant
const DEAD_ZONE = 0.5;

// Actions represent possible user inputs in-game
const Action = enum {
    none,
    left,
    right,
    jump,
    sprint,
    dash,
    attack,
    duck,

    // should these be in a separate list of actions?
    debug,
    camera,
    flood_fill,
    select,
    pause,
};

// An AxisBind can bind positive and negative axis strengths to different Actions in the input map. The strength is
// recorded, but these can be used more-or-less exactly the same way a button or key mapping might be used. A direct
// binding maps the analog positive and negative strength values of an Axis to the same action, which can be useful in cases
// where an axis (or pair of axes) are used to generate some kind of vector (e.g. hspeed and vspeed combined into a movement
// vector)
const AxisBind = struct {
    positive: Action = .none,
    negative: Action = .none,
    direct: Action = .none,
};

// Inputs represents the current state (i.e. in the current tick) of a particular Action for the owning Controller.
const Input = struct {
    action: Action = .none,
    strength: f32 = 0,
    pressed: bool = false,
    released: bool = false,

    pub fn isActive(self: Input) bool {
        return self.strength > 0;
    }
};

const InputMap = std.EnumArray(Action, Input);
const KeyMap = std.EnumArray(events.Key, Action);
const ButtonMap = std.EnumArray(events.Button, Action);
const AxisMap = std.EnumArray(events.Axis, AxisBind);
const MouseMap = std.EnumArray(events.MouseButton, Action);

/// Allows for querying input state by Actions possible in game. The id is primarily used to query input state from the underlying
/// library (currently SDL3) and doubles as a way of differentiating between controllers. Technically, each Controller is bound to
/// a single gamepad, but can simultaneously hold keyboard binds. This means that keyboard binds can have effects across all Controllers.
/// If this isn't desired in the future, we can prevent key_maps from being processed when the Controller has a valid ID
pub const Controller = struct {
    id: usize,
    inputs: InputMap,
    key_map: KeyMap,
    button_map: ButtonMap,
    axis_map: AxisMap,
    mouse_map: MouseMap,

    pub fn getInput(c: Controller, action: Action) Input {
        return c.inputs.get(action); // this is just for convenience, the inputs map will always be available
    }

    pub fn handleInputPress(c: *Controller, action: Action) void {
        if (action == .none) {
            return;
        }

        var input = c.inputs.getPtr(action);
        input.pressed = input.strength == 0;
        input.strength = 1;
    }

    pub fn handleInputRelease(c: *Controller, action: Action) void {
        if (action == .none) {
            return;
        }

        var input = c.inputs.getPtr(action);
        input.released = input.strength != 0;
        input.strength = 0;
    }

    pub fn handleAxis(c: *Controller, bind: AxisBind, strength: f32) void {
        var positive: *Input = c.inputs.getPtr(bind.positive);
        var negative: *Input = c.inputs.getPtr(bind.negative);
        var direct: *Input = c.inputs.getPtr(bind.direct);

        direct.strength = strength;

        if (strength > DEAD_ZONE) {
            if (@abs(direct.strength) < DEAD_ZONE) {
                direct.pressed = true;
            }

            if (positive.strength < DEAD_ZONE) {
                positive.pressed = true;
            }

            if (negative.strength > DEAD_ZONE) {
                negative.released = true;
            }

            negative.strength = 0;
            positive.strength = strength;
            return;
        }

        if (strength < -DEAD_ZONE) {
            if (@abs(direct.strength) < DEAD_ZONE) {
                direct.pressed = true;
            }

            if (negative.strength < DEAD_ZONE) {
                negative.pressed = true;
            }

            if (positive.strength > DEAD_ZONE) {
                positive.released = true;
            }

            positive.strength = 0;
            negative.strength = -strength;
            return;
        }

        if (@abs(direct.strength) > DEAD_ZONE) {
            direct.released = true;
        }

        if (positive.strength > DEAD_ZONE) {
            positive.released = true;
        }

        if (negative.strength > DEAD_ZONE) {
            positive.released = true;
        }

        // neutral position resets all strength
        positive.strength = 0;
        negative.strength = 0;
        direct.strength = 0;
    }

    pub fn handleEvent(c: *Controller, event: Event) void {
        switch (event) {
            Event.key => |key| {
                const action = c.key_map.get(key.key);
                if (key.pressed) c.handleInputPress(action) else c.handleInputRelease(action);
            },
            Event.button => |button| {
                const action = c.button_map.get(button.button);
                if (button.id != c.id) return;
                if (button.pressed) c.handleInputPress(action) else c.handleInputRelease(action);
            },
            Event.axis => |axis| if (axis.id == c.id) {
                if (axis.id != c.id) return;
                c.handleAxis(
                    c.axis_map.get(axis.axis),
                    axis.strength,
                );
            },
            Event.mouse => |mb| {
                const action = c.mouse_map.get(mb.button);
                if (mb.pressed) c.handleInputPress(action) else c.handleInputRelease(action);
            },
            else => return, // ignore non-controller events
        }
    }

    pub fn init(id: usize) Controller {
        return Controller{
            .id = id,
            .inputs = initInputMap(),
            .key_map = defaultKeyMap(),
            .button_map = defaultButtonMap(),
            .axis_map = defaultAxisMap(),
            .mouse_map = defaultMouseMap(),
        };
    }

    pub fn flush(self: *Controller) void {
        var it = self.inputs.iterator();
        while (it.next()) |*entry| {
            entry.value.pressed = false;
            entry.value.released = false;
        }
    }

    pub fn printState(self: *Controller) void {
        var iter = self.inputs.iterator();
        while (iter.next()) |entry| {
            if (entry.value.strength != 0 or entry.value.pressed != false or entry.value.released != false) {
                std.log.info(
                    "{any}: strength={d} pressed={any} released={any}",
                    .{ entry.key, entry.value.strength, entry.value.pressed, entry.value.released },
                );
            }
        }
    }
};

fn defaultKeyMap() KeyMap {
    var key_map = KeyMap.initFill(.none);
    key_map.set(.w, .jump);
    key_map.set(.a, .left);
    key_map.set(.d, .right);
    key_map.set(.s, .duck);
    key_map.set(.j, .attack);
    key_map.set(.k, .dash);

    key_map.set(.semicolon, .debug);
    key_map.set(.c, .camera);
    key_map.set(.g, .flood_fill);
    key_map.set(.escape, .pause);

    return key_map;
}

fn defaultButtonMap() ButtonMap {
    var button_map = ButtonMap.initFill(.none);
    button_map.set(.a, .jump);
    button_map.set(.x, .attack);
    button_map.set(.r1, .dash);
    button_map.set(.r1, .dash);
    button_map.set(.start, .pause);

    return button_map;
}

fn defaultAxisMap() AxisMap {
    var axis_map = AxisMap.initFill(.{});
    axis_map.set(.l_stick_x, .{ .positive = .right, .negative = .left });
    axis_map.set(.l_stick_y, .{ .positive = .duck, .negative = .none });

    return axis_map;
}

fn defaultMouseMap() MouseMap {
    return MouseMap.initFill(.none);
}

fn initInputMap() InputMap {
    var input_map = InputMap.initFill(.{});

    var it = input_map.iterator();
    while (it.next()) |entry| {
        input_map.set(entry.key, .{ .action = entry.key });
    }

    return input_map;
}

test "simple key press and release" {
    const t = std.testing;

    var ctrl = Controller.init(0);
    var input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);

    ctrl.handleEvent(events.Event{ .key = .{ .key = .w, .pressed = true } });
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, true);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 1);

    ctrl.handleEvent(events.Event{ .key = .{ .key = .w, .pressed = false } });
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, true);
    try t.expectEqual(input.released, true);
    try t.expectEqual(input.strength, 0);

    ctrl.flush();
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);
}

test "key press with tick between release" {
    const t = std.testing;

    var ctrl = Controller.init(0);
    ctrl.handleEvent(events.Event{ .key = .{ .key = .w, .pressed = true } });
    var input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, true);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 1);

    ctrl.flush();
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 1);

    ctrl.handleEvent(events.Event{ .key = .{ .key = .w, .pressed = false } });
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, true);
    try t.expectEqual(input.strength, 0);

    ctrl.flush();
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);
}

test "button press and release" {
    const t = std.testing;

    var ctrl = Controller.init(0);
    ctrl.handleEvent(events.Event{ .button = .{ .id = 0, .button = .a, .pressed = true } });
    var input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, true);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 1);

    ctrl.handleEvent(events.Event{ .button = .{ .id = 0, .button = .a, .pressed = false } });
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, true);
    try t.expectEqual(input.released, true);
    try t.expectEqual(input.strength, 0);

    ctrl.flush();
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);
}

test "button press and release for wrong controller" {
    const t = std.testing;

    var ctrl = Controller.init(0);
    ctrl.handleEvent(events.Event{ .button = .{ .id = 1, .button = .a, .pressed = true } });
    var input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);

    ctrl.handleEvent(events.Event{ .button = .{ .id = 1, .button = .a, .pressed = false } });
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);

    ctrl.flush();
    input = ctrl.getInput(.jump);
    try t.expectEqual(input.pressed, false);
    try t.expectEqual(input.released, false);
    try t.expectEqual(input.strength, 0);
}

test "axis positive to neutral" {
    const t = std.testing;
    const strength = DEAD_ZONE + 0.1;

    var ctrl = Controller.init(0);
    ctrl.handleEvent(events.Event{ .axis = .{ .id = 0, .axis = .l_stick_x, .strength = strength } });
    var right = ctrl.getInput(.right);
    var left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, true);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, strength);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);

    ctrl.handleEvent(events.Event{ .axis = .{ .id = 0, .axis = .l_stick_x, .strength = DEAD_ZONE - 0.1 } });
    right = ctrl.getInput(.right);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, true);
    try t.expectEqual(right.released, true);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);

    ctrl.flush();
    right = ctrl.getInput(.left);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, false);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);
}

test "axis positive to negative" {
    const t = std.testing;
    const strength = DEAD_ZONE + 0.1;

    var ctrl = Controller.init(0);
    ctrl.handleEvent(events.Event{ .axis = .{ .id = 0, .axis = .l_stick_x, .strength = strength } });
    var right = ctrl.getInput(.right);
    var left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, true);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, strength);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);

    ctrl.handleEvent(events.Event{ .axis = .{ .id = 0, .axis = .l_stick_x, .strength = -strength } });
    right = ctrl.getInput(.right);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, true);
    try t.expectEqual(right.released, true);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, true);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, strength);

    ctrl.flush();
    right = ctrl.getInput(.right);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, false);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, strength);
}

test "axis positive to negative to neutral" {
    const t = std.testing;
    const strength = DEAD_ZONE + 0.1;

    var ctrl = Controller.init(0);
    ctrl.handleEvent(events.Event{ .axis = .{ .id = 0, .axis = .l_stick_x, .strength = strength } });
    var right = ctrl.getInput(.right);
    var left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, true);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, strength);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);

    ctrl.handleEvent(events.Event{ .axis = .{ .id = 0, .axis = .l_stick_x, .strength = -strength } });
    right = ctrl.getInput(.right);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, true);
    try t.expectEqual(right.released, true);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, true);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, strength);

    ctrl.flush();
    right = ctrl.getInput(.right);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, false);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, strength);
}

test "axis positive to neutral wrong gamepad" {
    const t = std.testing;
    const strength = DEAD_ZONE + 0.1;

    var ctrl = Controller.init(0);
    std.log.warn("Size of controller: {d}", .{@sizeOf(Controller)});
    ctrl.handleEvent(events.Event{ .axis = .{ .id = 1, .axis = .l_stick_x, .strength = strength } });
    var right = ctrl.getInput(.right);
    var left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, false);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);

    ctrl.handleEvent(events.Event{ .axis = .{ .id = 1, .axis = .l_stick_x, .strength = DEAD_ZONE - 0.1 } });
    right = ctrl.getInput(.right);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, false);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);

    ctrl.flush();
    right = ctrl.getInput(.left);
    left = ctrl.getInput(.left);
    try t.expectEqual(right.pressed, false);
    try t.expectEqual(right.released, false);
    try t.expectEqual(right.strength, 0);
    try t.expectEqual(left.pressed, false);
    try t.expectEqual(left.released, false);
    try t.expectEqual(left.strength, 0);
}
