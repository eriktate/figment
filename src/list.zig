const std = @import("std");

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        val: T,
        next: ?*Self,
    };
}

pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        alloc: std.mem.Allocator,
        root: ?*Node(T),
        ordered: bool,

        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .alloc = alloc,
                .root = null,
                .ordered = false,
            };
        }

        pub fn deinit(self: *Self) void {
            var node = self.root;

            while (node.next) |next_node| {
                self.alloc.free(node);
                node = next_node;
            }
        }

        pub fn add(self: *Self, val: T) !void {
            var node = try self.alloc.create(Node(T));

            node.val = val;
            if (self.root) |root| {
                node.next = root.next;
            }

            self.root = node;
        }

        pub fn insert(self: *Self, val: T) !void {
            var node = self.root orelse {
                self.add(val);
            };

            var new_node = try self.alloc.create(Node(T));
            while (node.next) |next_node| {
                if (next_node.val > val) {
                    break;
                }
            }

            new_node.val = val;
            new_node.next = node.next;
            node.next = new_node;
        }
    };
}
