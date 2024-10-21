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
            if (!self.full and self.idx == self.end) {
                return null;
            }

            if (self.idx == self.buf.len) {
                self.idx = 0;
            }

            const item = self.buf[self.idx];
            self.idx += 1;
            self.full = false;
            return item;
        }

        pub fn len(self: Self) usize {
            if (self.idx < self.end) {
                return self.end - self.idx;
            }

            if (!self.full and self.idx == self.end) {
                return 0;
            }

            if (self.full) {
                return self.buf.len;
            }

            return (self.buf.len - self.idx) + self.end;
        }
    };
}

test "ring buffer push" {
    const t = std.testing;

    var buf = std.mem.zeroes([3]u8);
    var rb = RingBuffer(u8).init(&buf);
    try t.expectEqual(0, rb.len());

    rb.push(1);
    rb.push(2);
    rb.push(3);

    try t.expectEqual(3, rb.len());
    try t.expectEqual(1, rb.next());
    try t.expectEqual(2, rb.next());
    try t.expectEqual(3, rb.next());
    try t.expectEqual(null, rb.next());
    try t.expectEqual(0, rb.len());

    rb.push(4);
    rb.push(5);
    rb.push(6);

    try t.expectEqual(3, rb.len());
    try t.expectEqual(4, rb.next());
    try t.expectEqual(5, rb.next());
    try t.expectEqual(6, rb.next());
    try t.expectEqual(null, rb.next());
    try t.expectEqual(0, rb.len());
    try t.expectEqual(0, rb.len());

    rb.push(7);
    rb.push(8);
    rb.push(9);
    rb.push(10);
    rb.push(11);

    try t.expectEqual(3, rb.len());
    try t.expectEqual(9, rb.next());
    try t.expectEqual(10, rb.next());
    try t.expectEqual(11, rb.next());
    try t.expectEqual(0, rb.len());
}
