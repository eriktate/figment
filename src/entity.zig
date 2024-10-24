const std = @import("std");
const render = @import("render.zig");
const Pos = render.Pos;
const Box = @import("box.zig");
const dim = @import("dim.zig");
const sprite = @import("sprite.zig");
const log = @import("log.zig");

pub const Entity = @This();
id: usize = 0,
solid: bool = false,
pos: Pos = Pos.zero(),
box: Box = Box.init(0, 0),
spr: sprite.Sprite = sprite.Sprite{},
speed: dim.Vec2(f32) = dim.Vec2(f32).zero(),
accel: f32 = 0,
grav: f32 = 0,
friction: f32 = 0,
/// defaults to 4k pixels because we don't want to limit speed by default
max_speed: dim.Vec2(f32) = dim.Vec2(f32).init(1024 * 4, 1024 * 4),
active: bool = true,

pub fn init() Entity {
    return Entity{};
}

pub fn initAt(pos: Pos) Entity {
    return Entity{
        .pos = pos,
    };
}

pub fn withSprite(self: Entity, spr: sprite.Sprite) Entity {
    var ent = self;
    ent.spr = spr;
    return ent;
}

pub fn withBox(self: Entity, box: Box) Entity {
    var ent = self;
    ent.box = box;
    return ent;
}

pub fn tick(self: *Entity, dt: f32, entities: []Entity) void {
    if (!self.active) {
        return;
    }

    self.spr.tick(dt);
    self.speed.y += self.grav * dt;

    // clamp speed
    self.speed.x = std.math.clamp(self.speed.x, -self.max_speed.x, self.max_speed.x);
    self.speed.y = std.math.clamp(self.speed.y, -self.max_speed.y, self.max_speed.y);

    const speed = Pos.init(self.speed.x, self.speed.y, 0).scale(dt);
    var new_pos = self.pos.add(speed);
    if (self.collisionAt(new_pos, entities) != null) {
        new_pos = self.pos;
        if (self.collisionAt(self.pos.add(.{ .x = speed.x }), entities) == null) {
            new_pos = self.pos.add(.{ .x = speed.x });
            self.speed.y = 0;
        }

        if (self.collisionAt(self.pos.add(.{ .y = speed.y }), entities) == null) {
            new_pos = self.pos.add(.{ .y = speed.y });
            self.speed.x = 0;
        }
    }

    self.pos = new_pos;
}

pub fn toQuad(self: Entity) ?render.Quad {
    if (!self.active) {
        return null;
    }

    return self.spr.toQuad(self.pos);
}

pub fn getBox(self: Entity) Box {
    return self.box.at(self.pos);
}

pub fn collisionAt(self: Entity, pos: Pos, entities: []const Entity) ?Entity {
    var self_box = self.box.at(pos);

    for (entities) |entity| {
        if (entity.id == self.id or entity.solid == false) {
            continue;
        }

        const other_box = entity.getBox();
        if (other_box.w == 0 and other_box.h == 0) {
            continue;
        }

        if (self_box.overlaps(other_box)) {
            return entity;
        }
    }

    return null;
}

pub fn setScale(self: *Entity, scale: dim.Vec2(f32)) void {
    self.spr.setScale(scale);
    self.box.setScale(scale);
}

pub fn drawDebug(self: Entity, debug: *render.DebugRenderer) !void {
    if (self.box.w != 0 and self.box.h != 0) {
        try self.getBox().drawDebug(debug);
    }
}
