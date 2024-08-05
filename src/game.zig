const std = @import("std");
const log = @import("log.zig");
const render = @import("render.zig");
const Entity = @import("entity.zig");

const GameErr = error{
    Uninitialized,
};

var game: ?Game = null;

pub fn getGame() !*Game {
    if (game) |g| {
        return g;
    }

    return GameErr.Uninitialized;
}

pub const Game = struct {
    quads: std.ArrayList(render.Quad),
    entities: std.ArrayList(?Entity),

    pub fn spawn(self: *Game, entity: Entity) !*Entity {
        for (self.entities.items, 0..) |ent, idx| {
            if (ent == null) {
                self.entities.items[idx] = entity;

                return &self.entities.items[idx].?;
            }
        }

        try self.entities.append(entity);
        return &self.entities.items[self.entities.items.len - 1].?;
    }

    pub fn reset(self: *Game) void {
        // log.info("entities={d} quads={d}", .{ self.entities.items.len, self.quads.items.len });
        self.quads.items.len = 0;
    }

    pub fn genQuads(self: *Game) ![]render.Quad {
        for (self.entities.items) |opt_ent| {
            if (opt_ent) |ent| {
                if (ent.toQuad()) |quad| {
                    try self.quads.append(quad);
                }
            }
        }

        return self.quads.items[0..];
    }
};

pub fn init(alloc: std.mem.Allocator) !*Game {
    game = Game{
        .quads = try std.ArrayList(render.Quad).initCapacity(alloc, 2_000),
        .entities = try std.ArrayList(?Entity).initCapacity(alloc, 2_000),
    };

    return &game.?;
}
