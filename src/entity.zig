const render = @import("render/render.zig");
const Pos = render.Pos;
const Box = @import("box.zig");
const dim = @import("dim.zig");
const sprite = @import("sprite.zig");
const log = @import("log.zig");

pub const Entity = @This();
solid: bool = false,
pos: Pos = Pos.zero(),
box: Box = Box.init(0, 0),
sprite: sprite.Sprite = sprite.Sprite{},
speed: dim.Vec2(f32) = dim.Vec2(f32).zero(),
active: bool = true,

pub fn init() Entity {
    return Entity{};
}

pub fn withSprite(self: Entity, spr: sprite.Sprite) Entity {
    var ent = self;
    ent.sprite = spr;
    return ent;
}

pub fn tick(self: *Entity, dt: f32) void {
    if (!self.active) {
        return;
    }

    self.sprite.tick(dt);

    self.pos = self.pos.add(Pos.init(self.speed.x, self.speed.y, 0).scale(dt));
}

pub fn toQuad(self: Entity) ?render.Quad {
    if (!self.active) {
        return null;
    }

    return self.sprite.toQuad(self.pos);
}
