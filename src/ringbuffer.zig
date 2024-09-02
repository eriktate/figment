const std = @import("std");

pub fn RingBuffer(T: type) type {
    return struct {
        buf: []T,
        idx: usize,
        end: usize,
        full: bool,

        const Self = @This();

        pub fn init(buf: []T) Self {
            return Self{
                .buf = buf,
                .idx = 0,
                .end = 0,
                .full = false,
            };
        }

        pub fn push(self: *Self, item: T) void {
            defer std.debug.print("push {any}: {any}\n", .{ item, self });
            if (self.end == self.buf.len) {
                self.end = 0;
                self.full = self.full or self.idx == 0;
            }

            self.buf[self.end] = item;
            self.end += 1;
            self.full = self.full or self.end == self.idx;

            if (self.full) {
                self.idx = self.end;
            }
        }

        pub fn next(self: *Self) ?T {
            var item: ?T = undefined;
            defer std.debug.print("next {any}: {any}\n", .{ item, self });
            if (!self.full and self.idx == self.end) {
                item = null;
                return null;
            }

            if (self.idx == self.buf.len) {
                self.idx = 0;
            }

            item = self.buf[self.idx];
            self.idx += 1;
            self.full = false;
            return item;
        }
    };
}

// 1
// 1 2
// 1 2 3
// 4 2 3
test "ring buffer" {
    const t = std.testing;

    var buf = std.mem.zeroes([3]u8);
    var ring = RingBuffer(u8).init(&buf);

    ring.push(1);
    ring.push(2);
    ring.push(3);

    try t.expectEqual(1, ring.next());
    try t.expectEqual(2, ring.next());
    try t.expectEqual(3, ring.next());
    try t.expectEqual(null, ring.next());

    ring.push(4);
    ring.push(5);
    ring.push(6);

    try t.expectEqual(4, ring.next());
    try t.expectEqual(5, ring.next());
    try t.expectEqual(6, ring.next());
    try t.expectEqual(null, ring.next());

    ring.push(7);
    ring.push(8);
    ring.push(9);
    ring.push(10);
    ring.push(11);

    try t.expectEqual(9, ring.next());
    try t.expectEqual(10, ring.next());
    try t.expectEqual(11, ring.next());
}
