const Entity = @import("entity.zig");
const Controller = @import("input/controller.zig").Controller;
const audio = @import("audio.zig");
const game = @import("game.zig");
const gen = @import("gen.zig");
const random = @import("random.zig");

const Dir = enum {
    up,
    down,
    left,
    right,
};

const PlayerErr = error{
    EntityNotFound,
};

const walk_speed = 340;

const Player = @This();
id: usize,
ctrl: *Controller,
dir: Dir = .right,

pub fn init(id: usize, ctrl: *Controller) Player {
    return Player{
        .id = id,
        .ctrl = ctrl,
    };
}

pub fn tick(self: *Player, _: f32) !void {
    var g = try game.getGame();
    var ent = (try g.getEntityMut(self.id)) orelse return PlayerErr.EntityNotFound;
    ent.speed = .{ .x = 0, .y = 0 };

    if (self.ctrl.getInput(.left).isActive()) {
        ent.speed.x = -1;
    }

    if (self.ctrl.getInput(.right).isActive()) {
        ent.speed.x = 1;
    }

    if (self.ctrl.getInput(.jump).isActive()) {
        ent.speed.y = -1;
    }

    if (self.ctrl.getInput(.duck).isActive()) {
        ent.speed.y = 1;
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

    if (ent.speed.mag() > 0) {
        ent.spr.setAnimation(gen.getAnim(.ronin_run));
    } else {
        ent.spr.setAnimation(gen.getAnim(.ronin_idle));
    }

    const mag = ent.speed.mag();
    if (mag > 0) {
        ent.speed = ent.speed.unit().scale(walk_speed);
    }
}
