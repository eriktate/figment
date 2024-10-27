const std = @import("std");
const audio = @import("audio.zig");
const game = @import("game.zig");
const gen = @import("gen.zig");
const random = @import("random.zig");
const log = @import("log.zig");
const dim = @import("dim.zig");

const Entity = @import("entity.zig");
const Controller = @import("input/controller.zig").Controller;
const Timer = @import("timer.zig");

const State = enum {
    idle,
    run,
    jump,
    crest,
    fall,
    attack,
    dash,
    slide,
};

const PlayerErr = error{
    EntityNotFound,
};

const RUN_SPEED: comptime_float = 170;
const DASH_SPEED: comptime_float = RUN_SPEED * 2.5; // also max air speed
const GRAV = 1500;
const MAX_DASHES = 1;
const JUMP_FORCE = 500;
const MAX_FALL_SPEED = 4000;

const Player = @This();
// critical state
id: usize,
ctrl: *Controller,
state: State = .idle,
facing: i32 = 1,
grounded: bool = false,
jumped: bool = false, // added this to get around coyote time activating on jumps
dashes: u8 = MAX_DASHES,
x_dir: f32 = 0,

// configurations
coyote_timer: Timer = Timer.initMS(5 * 1000 / 60), // ~5 frames at 60fps
dash_timer: Timer = Timer.initMS(250),
dash_cd: Timer = Timer.initMS(250),
grav: f32 = GRAV,
friction: f32 = 2500,
slide_friction: f32 = 500,
air_friction: f32 = 100,
accel: dim.Vec2(f32) = .{ .x = 1500 },
air_accel: dim.Vec2(f32) = .{ .x = 500 },
max_speed: dim.Vec2(f32) = .{ .x = DASH_SPEED, .y = MAX_FALL_SPEED },

pub fn init(id: usize, ctrl: *Controller) Player {
    var ent = game.getGame().getEntityMut(id) catch @panic("invalid entity id for player");
    ent.?.solid = true;
    ent.?.max_speed = .{ .x = DASH_SPEED, .y = MAX_FALL_SPEED };
    log.info("initializing player with ent_id={d}", .{id});
    return Player{
        .id = id,
        .ctrl = ctrl,
    };
}

fn handleSprite(self: *Player, ent: *Entity) void {
    ent.spr.setFrameRate(1);

    switch (self.state) {
        .run => ent.spr.setAnimation(gen.getAnim(.ronin_run)),
        .idle => ent.spr.setAnimation(gen.getAnim(.ronin_idle)),
        .jump => ent.spr.setAnimation(gen.getAnim(.ronin_jump)),
        .fall => ent.spr.setAnimation(gen.getAnim(.ronin_fall)),
        .crest => ent.spr.setAnimation(gen.getAnim(.ronin_crest)),
        .attack => ent.spr.setAnimation(gen.getAnim(.ronin_flip)),
        .dash => {
            ent.spr.setFrameRate(2);
            ent.spr.setAnimation(gen.getAnim(.ronin_flip));
        },
        .slide => ent.spr.setAnimation(gen.getAnim(.ronin_slide)),
    }

    if (ent.speed.x < 0) {
        ent.spr.h_flip = true;
    }

    if (ent.speed.x > 0) {
        ent.spr.h_flip = false;
    }
}

fn updateEnt(self: *Player, ent: *Entity) void {
    ent.grav = self.grav;
    ent.max_speed = self.max_speed;
    switch (self.state) {
        .dash => {
            ent.accel = .{};
            ent.friction = 0;
        },
        .slide => {
            ent.accel = .{};
            ent.friction = self.slide_friction;
        },
        .jump, .fall, .crest => {
            ent.friction = self.air_friction;
            ent.accel = self.air_accel.scale(self.x_dir);
            // prevent adding acceleration while airborn just by using movement keys
            if (@abs(ent.speed.x) > RUN_SPEED and std.math.sign(self.x_dir) == std.math.sign(ent.speed.x)) {
                ent.accel = .{};
                ent.friction = 0;
            }
        },
        else => {
            ent.friction = self.friction;
            ent.accel = self.accel.scale(self.x_dir);
            if (@abs(ent.speed.x) > RUN_SPEED) {
                ent.accel = .{};
            }
        },
    }
}

inline fn canDash(self: *Player) bool {
    return self.dashes > 0 and
        self.dash_timer.isDone() and
        self.dash_cd.isDone();
}

inline fn dash(self: *Player, ent: *Entity) void {
    self.dashes -= 1;
    self.dash_timer.reset();
    self.state = .dash;
    ent.speed.y = 0;
    ent.speed.x = DASH_SPEED * @as(f32, @floatFromInt(self.facing));
}

inline fn handleJump(self: *Player, ent: *Entity) void {
    const can_jump = self.state != .jump and (self.grounded or !self.coyote_timer.isDone());

    const jump_input = self.ctrl.getInput(.jump);
    if (jump_input.pressed and can_jump) {
        if (self.state == .dash) {
            self.dash_timer.reset();
            self.dash_cd.reset();
        }
        self.jumped = true;
        self.coyote_timer.finish(); // prevent accidental double jumps
        ent.speed.y = -JUMP_FORCE;
        self.state = .jump;
    }

    // variable jump height
    if (ent.speed.y < 0 and jump_input.released) {
        ent.speed.y /= 2;
    }
}

pub fn tick(self: *Player, _: f32) !void {
    var g = game.getGame();
    var ent = (try g.getEntityMut(self.id)) orelse return PlayerErr.EntityNotFound;
    defer self.handleSprite(ent);
    defer self.updateEnt(ent);

    const grounded = ent.collisionAt(ent.pos.add(.{ .y = 1 }), g.entities.items()) != null;
    if (self.grounded and !grounded) {
        if (!self.jumped) {
            self.coyote_timer.reset();
        }
    }

    self.grounded = grounded;
    if (self.grounded) {
        self.dashes = MAX_DASHES;
    }

    if (self.state == .dash) {
        if (!self.dash_timer.isDone()) {
            return;
        }

        self.dash_cd.reset();
    }
    self.handleJump(ent); // handleJump after potential bail out for dash to prevent jumping while dashing

    if (self.jumped and ent.speed.y >= 0) {
        self.jumped = false;
    }

    if (self.grounded and self.ctrl.getInput(.duck).isActive() and self.state != .jump) {
        if (@abs(ent.speed.x) > DASH_SPEED - (DASH_SPEED - RUN_SPEED) / 2.0) {
            self.state = .slide;
            return;
        }
    }

    if (self.grounded and self.state == .slide) {
        if (@abs(ent.speed.x) < 2 or !self.ctrl.getInput(.duck).isActive()) {
            self.state = .idle;
        } else {
            return;
        }
    }

    self.x_dir = 0;
    if (self.ctrl.getInput(.left).isActive()) {
        self.x_dir = -1;
        self.facing = -1;
    }

    if (self.ctrl.getInput(.right).isActive()) {
        self.x_dir = 1;
        self.facing = 1;
    }

    if (self.ctrl.getInput(.attack).pressed) {
        const attack_sounds = [_]audio.Sound{
            .katana_swing_1,
            .katana_swing_2,
            .katana_swing_3,
        };

        _ = audio.play(attack_sounds[random.lessThan(3)]);
    }

    if (self.ctrl.getInput(.dash).pressed and self.canDash()) {
        self.dash(ent);
        return;
    }

    if (self.state == .crest and grounded) {
        self.state = .idle;
    }

    if (self.state == .crest) {
        const anim = ent.spr.source.animation;
        if (!anim.finished) {
            return;
        }
    }

    if (grounded) {
        if (@abs(ent.speed.x) > 0) {
            self.state = .run;
        } else {
            self.state = .idle;
        }
    } else {
        if (ent.speed.y < 0 and self.state != .crest) {
            self.state = .jump;
        }

        if (ent.speed.y > -50 and ent.speed.y < 0) {
            self.state = .crest;
        }

        if (ent.speed.y > 0) {
            self.state = .fall;
        }
    }
}
