const Controller = @import("controller.zig").Controller;

pub const Key = enum {
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    zero,
    space,
    tab,
    l_shift,
    r_shift,
    l_ctrl,
    r_ctrl,
    l_alt,
    r_alt,
    enter,
    l_arrow,
    r_arrow,
    u_arrow,
    d_arrow,
    backspace,
    semicolon,
    escape,
    unknown,
};

pub const Button = enum {
    a,
    b,
    x,
    y,
    select,
    start,
    menu,
    up,
    down,
    left,
    right,
    r1,
    r3,
    l1,
    l3,
};

pub const MouseButton = enum {
    m1,
    m2,
    m3,
    m4,
    m5,
};

pub const Axis = enum {
    l_stick_x,
    l_stick_y,
    r_stick_x,
    r_stick_y,
    l_trigger,
    r_trigger,
};

pub const KeyEvent = struct {
    key: Key,
    pressed: bool,
};

pub const ButtonEvent = struct {
    id: u32,
    button: Button,
    pressed: bool,
};

pub const AxisEvent = struct {
    id: u32,
    axis: Axis,
    strength: f32,
};

pub const MouseEvent = struct {
    button: MouseButton,
    pressed: bool,
    x: u32,
    y: u32,
};

pub const DeviceChange = enum {
    added,
    removed,
};

pub const DeviceEvent = struct {
    id: u32,
    change: DeviceChange,
    controller: ?Controller,
};

pub const EventType = enum {
    key,
    button,
    axis,
    mouse,
    device,
    quit,
};

pub const Event = union(EventType) {
    key: KeyEvent,
    button: ButtonEvent,
    axis: AxisEvent,
    mouse: MouseEvent,
    device: DeviceEvent,
    quit: void,
};
