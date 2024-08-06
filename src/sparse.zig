const std = @import("std");

pub const SparseSetErr = error{
    IDOutOfBounds,
};

fn ensureItemHasID(typ: type) void {
    comptime {
        switch (@typeInfo(typ)) {
            .Struct => |st| {
                for (st.fields) |field| {
                    if (std.mem.eql(u8, field.name, "id") and field.type == usize) {
                        return;
                    }
                }
            },
            else => {},
        }

        @compileError("SparseSet item type must have an 'id' field of type usize");
    }
}

pub fn SparseSet(T: type) type {
    ensureItemHasID(T);

    return struct {
        data: std.ArrayList(T),
        lookup: std.ArrayList(?usize),

        const Self = @This();

        pub fn init(alloc: std.mem.Allocator) Self {
            return Self{
                .data = std.ArrayList(T).init(alloc),
                .lookup = std.ArrayList(?usize).init(alloc),
            };
        }

        pub fn initCapacity(alloc: std.mem.Allocator, cap: usize) !Self {
            return Self{
                .data = try std.ArrayList(T).initCapacity(alloc, cap),
                .lookup = try std.ArrayList(usize).initCapacity(alloc, cap),
            };
        }

        /// Adds an item to the SparseSet. The current implementation technically leaks memory because the sparse
        /// lookup only grows and makes no attempt at re-using previous indices.
        pub fn add(self: *Self, item: T) !T {
            const id = self.lookup.items.len;
            const idx = self.data.items.len;
            var copy = item;
            @field(copy, "id") = id;

            try self.data.append(copy);
            try self.lookup.append(idx);

            return copy;
        }

        pub fn remove(self: *Self, id: usize) !void {
            if (id >= self.lookup.items.len) {
                return SparseSetErr.IDOutOfBounds;
            }

            const idx = self.lookup.items[id] orelse return; // item is already removed

            if (self.data.items.len == 1 and idx == 0) {
                self.data.items.len = 0;
                self.lookup.items.len = 0; // if the list is empty, we can reset the lookup
            }

            if (self.data.items.len == 0) {
                // consider erroring here, it would be weird to remove an ID from an empty list
                return;
            }

            // swap removed index to end so we can simply shorten the length of the dense array
            try self.swap(idx, self.data.items.len - 1);
            self.data.items.len -= 1;
        }

        pub fn get(self: Self, id: usize) !?T {
            if (id >= self.lookup.items.len) {
                return SparseSetErr.IDOutOfBounds;
            }

            const idx = self.lookup.items[id] orelse return null;
            return self.data.items[idx];
        }

        pub fn getMut(self: *Self, id: usize) !?*T {
            if (id >= self.lookup.items.len) {
                return SparseSetErr.IDOutOfBounds;
            }

            const idx = self.lookup.items[id] orelse return null;
            return &self.data.items[idx];
        }

        pub inline fn items(self: Self) []const T {
            return self.data.items;
        }

        pub inline fn itemsMut(self: *Self) []T {
            return &self.data.items;
        }

        /// Swaps two items within the dense set, preserving sparse lookups. Can be used to implement a sort
        pub fn swap(self: *Self, idx: usize, swap_idx: usize) !void {
            if (idx >= self.data.items.len or swap_idx >= self.data.items.len) {
                return SparseSetErr.IDOutOfBounds;
            }

            const swap_item = self.data.items[swap_idx];
            const item = self.data.items[idx];
            self.data.items[swap_idx] = item;
            self.data.items[idx] = swap_item;
            self.lookup.items[@field(item, "id")] = swap_idx;
            self.lookup.items[@field(swap_item, "id")] = idx;
        }

        pub fn deinit(self: Self) void {
            self.data.deinit();
            self.lookup.deinit();
        }
    };
}

test "SparseSet" {
    const t = std.testing;
    const alloc = t.allocator;
    const Entity = @import("entity.zig");

    var set = SparseSet(Entity).init(alloc);
    defer set.deinit();

    const entity0 = try set.add(Entity.init());
    const entity1 = try set.add(Entity.init());
    const entity2 = try set.add(Entity.init());

    // ensure entities receive their respective IDs
    try t.expectEqual(0, entity0.id);
    try t.expectEqual(1, entity1.id);
    try t.expectEqual(2, entity2.id);

    try set.remove(1);
    try t.expectEqual(2, set.items().len);
    try t.expectEqual(3, set.lookup.items.len);
    try t.expectEqual(0, set.items()[0].id);
    try t.expectEqual(2, set.items()[1].id);

    const entity3 = try set.add(Entity.init());
    try t.expectEqual(entity3.id, 3);

    try set.swap(0, 1);
    // test ordering after swap
    try t.expectEqual(2, set.items()[0].id);
    try t.expectEqual(0, set.items()[1].id);

    // test IDs are still consistent
    try t.expectEqual(0, (try set.get(0)).?.id);
    try t.expectEqual(2, (try set.get(2)).?.id);
    try t.expectEqual(3, (try set.get(3)).?.id);
}
