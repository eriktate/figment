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
};

const PlayerErr = error{
    EntityNotFound,
};

const walk_speed = 340;

const Player = @This();
id: usize,
ctrl: *Controller,
state: State = .idle,
coyote_timer: Timer = Timer.initMS(5 * 1000 / 60), // ~5 frames at 60fps
grounded: bool = false,
jumped: bool = false,

pub fn init(id: usize, ctrl: *Controller) Player {
    var ent = game.getGame().getEntityMut(id) catch @panic("invalid entity id for player");
    ent.?.grav = 1500;
    ent.?.solid = true;
    return Player{
        .id = id,
        .ctrl = ctrl,
    };
}

fn handleState(self: *Player, ent: *Entity) void {
    switch (self.state) {
        .run => ent.spr.setAnimation(gen.getAnim(.ronin_run)),
        .idle => ent.spr.setAnimation(gen.getAnim(.ronin_idle)),
        .jump => ent.spr.setAnimation(gen.getAnim(.ronin_jump)),
        .fall => ent.spr.setAnimation(gen.getAnim(.ronin_fall)),
        .crest => ent.spr.setAnimation(gen.getAnim(.ronin_crest)),
        .attack => ent.spr.setAnimation(gen.getAnim(.ronin_flip)),
    }
}

pub fn tick(self: *Player, _: f32) !void {
    var g = game.getGame();
    var ent = (try g.getEntityMut(self.id)) orelse return PlayerErr.EntityNotFound;
    var x_input: f32 = 0;
    const grounded = ent.collisionAt(ent.pos.add(.{ .y = 1 }), g.entities.items()) != null;
    if (self.grounded and !grounded) {
        if (!self.jumped) {
            log.info("coyote start", .{});
            self.coyote_timer.reset();
        }
    }

    if (self.jumped and ent.speed.y >= 0) {
        self.jumped = false;
    }

    self.grounded = grounded;
    const can_jump = self.state != .jump and (grounded or !self.coyote_timer.isDone());

    if (self.ctrl.getInput(.left).isActive()) {
        x_input = -1;
    }

    if (self.ctrl.getInput(.right).isActive()) {
        x_input = 1;
    }

    if (self.ctrl.getInput(.jump).pressed and can_jump) {
        self.jumped = true;
        self.coyote_timer.finish(); // prevent accidental double jumps
        ent.speed.y = -700;
    }

    if (self.ctrl.getInput(.attack).pressed) {
        const attack_sounds = [_]audio.Sound{
            .katana_swing_1,
            .katana_swing_2,
            .katana_swing_3,
        };

        _ = audio.play(attack_sounds[random.lessThan(3)]);
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

    defer self.handleState(ent);
    ent.speed.x = x_input * walk_speed;

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
