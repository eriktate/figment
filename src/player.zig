const Entity = @import("entity.zig");
const Controller = @import("input/controller.zig").Controller;
const audio = @import("audio.zig");

const Player = @This();
ent: *Entity,
ctrl: *Controller,

pub fn init(ent: *Entity, ctrl: *Controller) Player {
    return Player{
        .ent = ent,
        .ctrl = ctrl,
    };
}

pub fn tick(self: *Player, _: f32) void {
    self.ent.speed = .{ .x = 0, .y = 0 };

    if (self.ctrl.getInput(.left).isActive()) {
        self.ent.speed.x = -128;
    }

    if (self.ctrl.getInput(.right).isActive()) {
        self.ent.speed.x = 128;
    }

    if (self.ctrl.getInput(.jump).isActive()) {
        self.ent.speed.y = -128;
    }

    if (self.ctrl.getInput(.duck).isActive()) {
        self.ent.speed.y = 128;
    }

    if (self.ctrl.getInput(.attack).pressed) {
        _ = audio.play(.bark);
    }
}
