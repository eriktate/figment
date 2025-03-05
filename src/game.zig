const std = @import("std");
const log = @import("log.zig");
const render = @import("render.zig");
const sparse = @import("sparse.zig");
const mwl = @import("mwl/mwl.zig");

const QuadRenderer = render.QuadRenderer;
const DebugRenderer = render.DebugRenderer;
const Entity = @import("entity.zig");
const Font = @import("font.zig").Font;

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

pub const AccessMode = enum {
    sim,
    render,
};

/// Contains and manages global game state.
pub const Game = struct {
    access_mode: AccessMode = .sim,
    quit: bool = false,
    quads: std.ArrayList(render.Quad),
    fg_quads: std.ArrayList(render.Quad),
    entities: sparse.Set(Entity),
    layers: std.EnumArray(Layer, std.ArrayList(usize)),

    // these aren't very safe, but I'm lazy right now
    win: *mwl.Window = undefined,
    renderer: QuadRenderer = undefined,
    debug: DebugRenderer = undefined,
    alloc: std.mem.Allocator,

    pub fn spawn(self: *Game, entity: Entity) !*Entity {
        return try self.entities.add(entity);
    }

    pub fn getEntity(self: *Game, id: usize) !?Entity {
        return self.entities.get(id);
    }

    pub fn getEntityMut(self: *Game, id: usize) !?*Entity {
        return self.entities.getMut(id);
    }

    pub fn pushQuadFG(self: *Game, quad: render.Quad) !void {
        return try self.fg_quads.append(quad);
    }

    // NOTE (soggy): because we're just signaling mutually exclusive parts of the code
    // to run or not, I don't think these actually have to be atomic. If they do, they
    // can always be reverted
    pub fn getAccessMode(self: *Game) AccessMode {
        // return @atomicLoad(AccessMode, &self.access_mode, .unordered);
        return self.access_mode;
    }

    pub fn setAccessMode(self: *Game, mode: AccessMode) void {
        // @atomicStore(AccessMode, &self.access_mode, mode, .unordered);
        self.access_mode = mode;
    }

    pub fn reset(self: *Game) void {
        // log.info("entities={d} quads={d}", .{ self.entities.items.len, self.quads.items.len });
        self.quads.items.len = 0;
        self.fg_quads.items.len = 0;
    }

    pub fn genQuads(self: *Game) ![]render.Quad {
        for (self.entities.items()) |ent| {
            if (ent.toQuad()) |quad| {
                try self.quads.append(quad);
            }
        }

        for (self.fg_quads.items) |quad| {
            try self.quads.append(quad);
        }

        return self.quads.items;
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

    pub fn drawText(self: *Game, font: Font, pos: render.Pos, text: []const u8) !void {
        try font.drawText(pos, text, &self.fg_quads);
    }

    pub fn drawTextFmt(self: *Game, font: Font, pos: render.Pos, comptime fmt: []const u8, args: anytype) !void {
        var buf: [512]u8 = undefined;
        const text = try std.fmt.bufPrint(&buf, fmt, args);

        return try self.drawText(font, pos, text);
    }
};

pub fn init(alloc: std.mem.Allocator) !*Game {
    game = Game{
        .quads = try std.ArrayList(render.Quad).initCapacity(alloc, 100_000),
        .fg_quads = try std.ArrayList(render.Quad).initCapacity(alloc, 10_000),
        .entities = try sparse.Set(Entity).initCapacity(alloc, 100_000),
        .layers = std.EnumArray(Layer, std.ArrayList(usize)).initUndefined(),
        .alloc = alloc,
    };

    for (0..game.layers.values.len) |idx| {
        game.layers.set(@enumFromInt(idx), try std.ArrayList(usize).initCapacity(alloc, 100));
    }

    game_initialized = true;
    return &game;
}
