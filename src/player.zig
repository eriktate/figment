const Entity = @import("entity.zig");
const Controller = @import("input/controller.zig").Controller;
const Timer = @import("timer.zig");
const audio = @import("audio.zig");
const game = @import("game.zig");
const gen = @import("gen.zig");
const random = @import("random.zig");
const log = @import("log.zig");

const State = enum {
    idle,
    run,
    jump,
    crest,
    fall,
    attack,
    dash,
};

const PlayerErr = error{
    EntityNotFound,
};

const RUN_SPEED = 340;
const GRAV = 1500;
const MAX_DASHES = 1;

const Player = @This();
id: usize,
ctrl: *Controller,
state: State = .idle,
coyote_timer: Timer = Timer.initMS(5 * 1000 / 60), // ~5 frames at 60fps
dash_timer: Timer = Timer.initMS(250),
dash_cd: Timer = Timer.initMS(250),
grounded: bool = false,
jumped: bool = false, // added this to get around coyote time activating on jumps
dashes: u8 = 1,
grav: f32 = GRAV,
facing: i32 = 1,

pub fn init(id: usize, ctrl: *Controller) Player {
    var ent = game.getGame().getEntityMut(id) catch @panic("invalid entity id for player");
    ent.?.solid = true;
    return Player{
        .id = id,
        .ctrl = ctrl,
    };
}

fn handleSprite(self: *Player, ent: *Entity) void {
    switch (self.state) {
        .run => ent.spr.setAnimation(gen.getAnim(.ronin_run)),
        .idle => ent.spr.setAnimation(gen.getAnim(.ronin_idle)),
        .jump => ent.spr.setAnimation(gen.getAnim(.ronin_jump)),
        .fall => ent.spr.setAnimation(gen.getAnim(.ronin_fall)),
        .crest => ent.spr.setAnimation(gen.getAnim(.ronin_crest)),
        .attack => ent.spr.setAnimation(gen.getAnim(.ronin_flip)),
        .dash => ent.spr.setAnimation(gen.getAnim(.ronin_flip)),
    }
}

fn updateEnt(self: *Player, ent: *Entity) void {
    ent.grav = self.grav;
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
    ent.speed.x = @floatFromInt(RUN_SPEED * 2 * self.facing);
}

inline fn handleJump(self: *Player, ent: *Entity) void {
    const can_jump = self.state != .jump and (self.grounded or !self.coyote_timer.isDone());

    if (self.ctrl.getInput(.jump).pressed and can_jump) {
        self.jumped = true;
        self.coyote_timer.finish(); // prevent accidental double jumps
        ent.speed.y = -700;
        self.state = .jump;
        self.dash_timer.reset();
        self.dash_cd.reset();
    }
}

pub fn tick(self: *Player, _: f32) !void {
    var g = game.getGame();
    var ent = (try g.getEntityMut(self.id)) orelse return PlayerErr.EntityNotFound;
    defer self.handleSprite(ent);
    defer self.updateEnt(ent);

    self.handleJump(ent);
    if (self.state == .dash) {
        if (!self.dash_timer.isDone()) {
            return;
        }

        self.dash_cd.reset();
    }

    var x_input: f32 = 0;
    const grounded = ent.collisionAt(ent.pos.add(.{ .y = 1 }), g.entities.items()) != null;
    if (self.grounded and !grounded) {
        if (!self.jumped) {
            log.info("coyote start", .{});
            self.coyote_timer.reset();
        }
    }

    if (grounded) {
        self.dashes = MAX_DASHES;
    }

    if (self.jumped and ent.speed.y >= 0) {
        self.jumped = false;
    }

    self.grounded = grounded;

    if (self.ctrl.getInput(.left).isActive()) {
        x_input = -1;
        self.facing = -1;
    }

    if (self.ctrl.getInput(.right).isActive()) {
        x_input = 1;
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

    if (ent.speed.x < 0) {
        ent.spr.h_flip = true;
    }

    if (ent.speed.x > 0) {
        ent.spr.h_flip = false;
    }

    if (self.state == .crest and grounded) {
        self.state = .idle;
    }

    ent.speed.x = x_input * RUN_SPEED;

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
