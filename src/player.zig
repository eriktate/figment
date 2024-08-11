const Entity = @import("entity.zig");
const Controller = @import("input/controller.zig").Controller;
const audio = @import("audio.zig");
const game = @import("game.zig");

const PlayerErr = error{
    EntityNotFound,
};

const Player = @This();
id: usize,
ctrl: *Controller,

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
        ent.speed.x = -128;
    }

    if (self.ctrl.getInput(.right).isActive()) {
        ent.speed.x = 128;
    }

    if (self.ctrl.getInput(.jump).isActive()) {
        ent.speed.y = -128;
    }

    if (self.ctrl.getInput(.duck).isActive()) {
        ent.speed.y = 128;
    }

    if (self.ctrl.getInput(.attack).pressed) {
        _ = audio.play(.bark);
    }
}
