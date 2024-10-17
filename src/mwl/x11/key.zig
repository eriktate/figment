const std = @import("std");
const c = @import("c");
const Key = @import("../../input/events.zig").Key;

var code_to_key: [255]Key = undefined;

/// Keycode values aren't static across different systems which prevents a compile time mapping. This
/// function initializes a map at runtime using keysyms to figure out which keycodes should map to
/// Key enum values supported by mythic.
pub fn initializeKeycodeMap(display: ?*c.Display) void {
    for (code_to_key, 0..) |_, i| {
        code_to_key[i] = .unknown;
    }

    // letters
    code_to_key[c.XKeysymToKeycode(display, c.XK_a)] = Key.a;
    code_to_key[c.XKeysymToKeycode(display, c.XK_b)] = Key.b;
    code_to_key[c.XKeysymToKeycode(display, c.XK_c)] = Key.c;
    code_to_key[c.XKeysymToKeycode(display, c.XK_d)] = Key.d;
    code_to_key[c.XKeysymToKeycode(display, c.XK_e)] = Key.e;
    code_to_key[c.XKeysymToKeycode(display, c.XK_f)] = Key.f;
    code_to_key[c.XKeysymToKeycode(display, c.XK_g)] = Key.g;
    code_to_key[c.XKeysymToKeycode(display, c.XK_h)] = Key.h;
    code_to_key[c.XKeysymToKeycode(display, c.XK_i)] = Key.i;
    code_to_key[c.XKeysymToKeycode(display, c.XK_j)] = Key.j;
    code_to_key[c.XKeysymToKeycode(display, c.XK_k)] = Key.k;
    code_to_key[c.XKeysymToKeycode(display, c.XK_l)] = Key.l;
    code_to_key[c.XKeysymToKeycode(display, c.XK_m)] = Key.m;
    code_to_key[c.XKeysymToKeycode(display, c.XK_n)] = Key.n;
    code_to_key[c.XKeysymToKeycode(display, c.XK_o)] = Key.o;
    code_to_key[c.XKeysymToKeycode(display, c.XK_p)] = Key.p;
    code_to_key[c.XKeysymToKeycode(display, c.XK_q)] = Key.q;
    code_to_key[c.XKeysymToKeycode(display, c.XK_r)] = Key.r;
    code_to_key[c.XKeysymToKeycode(display, c.XK_s)] = Key.s;
    code_to_key[c.XKeysymToKeycode(display, c.XK_t)] = Key.t;
    code_to_key[c.XKeysymToKeycode(display, c.XK_u)] = Key.u;
    code_to_key[c.XKeysymToKeycode(display, c.XK_v)] = Key.v;
    code_to_key[c.XKeysymToKeycode(display, c.XK_w)] = Key.w;
    code_to_key[c.XKeysymToKeycode(display, c.XK_x)] = Key.x;
    code_to_key[c.XKeysymToKeycode(display, c.XK_y)] = Key.y;
    code_to_key[c.XKeysymToKeycode(display, c.XK_z)] = Key.z;

    // numbers
    code_to_key[c.XKeysymToKeycode(display, c.XK_0)] = Key.zero;
    code_to_key[c.XKeysymToKeycode(display, c.XK_1)] = Key.one;
    code_to_key[c.XKeysymToKeycode(display, c.XK_2)] = Key.two;
    code_to_key[c.XKeysymToKeycode(display, c.XK_3)] = Key.three;
    code_to_key[c.XKeysymToKeycode(display, c.XK_4)] = Key.four;
    code_to_key[c.XKeysymToKeycode(display, c.XK_5)] = Key.five;
    code_to_key[c.XKeysymToKeycode(display, c.XK_6)] = Key.six;
    code_to_key[c.XKeysymToKeycode(display, c.XK_7)] = Key.seven;
    code_to_key[c.XKeysymToKeycode(display, c.XK_8)] = Key.eight;
    code_to_key[c.XKeysymToKeycode(display, c.XK_9)] = Key.nine;

    // special
    code_to_key[c.XKeysymToKeycode(display, c.XK_space)] = Key.space;
    code_to_key[c.XKeysymToKeycode(display, c.XK_Escape)] = Key.esc;
    code_to_key[c.XKeysymToKeycode(display, c.XK_Escape)] = Key.esc;
    code_to_key[c.XKeysymToKeycode(display, c.XK_comma)] = Key.comma;
    code_to_key[c.XKeysymToKeycode(display, c.XK_period)] = Key.dot;
    code_to_key[c.XKeysymToKeycode(display, c.XK_semicolon)] = Key.semicolon;
    code_to_key[c.XKeysymToKeycode(display, c.XK_apostrophe)] = Key.tick;
    code_to_key[c.XKeysymToKeycode(display, c.XK_Shift_L)] = Key.l_shift;
    code_to_key[c.XKeysymToKeycode(display, c.XK_Shift_R)] = Key.r_shift;
    code_to_key[c.XKeysymToKeycode(display, c.XK_Control_L)] = Key.l_ctrl;
    code_to_key[c.XKeysymToKeycode(display, c.XK_Control_R)] = Key.r_ctrl;
}

pub fn getKey(keycode: usize) Key {
    return code_to_key[keycode];
}
