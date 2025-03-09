const std = @import("std");
const log = @import("log.zig");
const render = @import("render.zig");
const sparse = @import("sparse.zig");
const mwl = @import("mwl/mwl.zig");
const dim = @import("dim.zig");

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

pub const Thread = enum {
    sim,
    render,
    sound,
};

/// Contains and manages global game state.
pub const Game = struct {
    alloc: std.mem.Allocator,

    active_thread: Thread = .sim,
    quit: bool = false,
    quads: std.ArrayList(render.Quad),
    fg_quads: std.ArrayList(render.Quad),
    entities: sparse.Set(Entity),
    layers: std.EnumArray(Layer, std.ArrayList(usize)),

    // these aren't very safe, but I'm lazy right now
    win: *mwl.Window = undefined,
    renderer: QuadRenderer = undefined,
    debug: DebugRenderer = undefined,
    projection: dim.Mat4(f32) = undefined,

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
    pub fn getActiveThread(self: *Game) Thread {
        // NOTE (soggy): Because we're just signaling specific threads to have mutually exclusive
        // access to certain members, I'm not convinced this needs to be atomic. If it proves to
        // be a problem, we just need to uncomment this line
        // return @atomicLoad(AccessMode, &self.access_mode, .unordered);
        return self.active_thread;
    }

    pub fn setActiveThread(self: *Game, thread: Thread) void {
        // NOTE (soggy): Because we're just signaling specific threads to have mutually exclusive
        // access to certain members, I'm not convinced this needs to be atomic. If it proves to
        // be a problem, we just need to uncomment this line
        // @atomicStore(AccessMode, &self.access_mode, mode, .unordered);
        self.active_thread = thread;
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
