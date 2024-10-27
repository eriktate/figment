const std = @import("std");
const log = @import("log.zig");
const render = @import("render.zig");
const Entity = @import("entity.zig");
const sparse = @import("sparse.zig");

var game: Game = undefined;
var game_initialized: bool = false;

pub fn getGame() *Game {
    std.debug.assert(game_initialized);

    return &game;
}

pub const Layer = enum {
    walls,
    enemies,
    pickups,
};

/// Contains and manages global game state.
pub const Game = struct {
    quads: std.ArrayList(render.Quad),
    entities: sparse.Set(Entity),
    layers: std.EnumArray(Layer, std.ArrayList(usize)),

    pub fn spawn(self: *Game, entity: Entity) !*Entity {
        return try self.entities.add(entity);
    }

    pub fn getEntity(self: *Game, id: usize) !?Entity {
        return self.entities.get(id);
    }

    pub fn getEntityMut(self: *Game, id: usize) !?*Entity {
        return self.entities.getMut(id);
    }

    pub fn reset(self: *Game) void {
        // log.info("entities={d} quads={d}", .{ self.entities.items.len, self.quads.items.len });
        self.quads.items.len = 0;
    }

    pub fn genQuads(self: *Game) ![]render.Quad {
        for (self.entities.items()) |ent| {
            if (ent.toQuad()) |quad| {
                try self.quads.append(quad);
            }
        }

        return self.quads.items[0..];
    }

    pub fn zSort(self: *Game) !void {
        const entities = self.entities.items();

        for (0..entities.len) |i| {
            if (i == 0) {
                continue;
            }

            for (0..i) |j| {
                const ent = entities[i - j];
                const prev_ent = entities[i - j - 1];
                if (prev_ent.pos.z <= ent.pos.z) {
                    break;
                }
                try self.entities.swap(i - j, i - j - 1);
            }
        }
    }

    pub fn ySort(self: *Game) !void {
        const entities = self.entities.items();

        for (0..entities.len) |i| {
            if (i == 0) {
                continue;
            }

            for (0..i) |j| {
                const ent = entities[i - j];
                const prev_ent = entities[i - j - 1];
                if (prev_ent.pos.y <= ent.pos.y) {
                    break;
                }
                try self.entities.swap(i - j, i - j - 1);
            }
        }
    }
};

pub fn init(alloc: std.mem.Allocator) !*Game {
    game = Game{
        .quads = try std.ArrayList(render.Quad).initCapacity(alloc, 100_000),
        .entities = try sparse.Set(Entity).initCapacity(alloc, 100_000),
        .layers = std.EnumArray(Layer, std.ArrayList(usize)).initUndefined(),
    };

    for (0..game.layers.values.len) |idx| {
        game.layers.set(@enumFromInt(idx), try std.ArrayList(usize).initCapacity(alloc, 100));
    }

    game_initialized = true;
    return &game;
}
