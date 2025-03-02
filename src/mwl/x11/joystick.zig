const std = @import("std");
const log = @import("../../log.zig");
const fs = std.fs;
const RingBuffer = @import("../../ringbuffer.zig").RingBuffer;
const events = @import("../../input/events.zig");
const epoll = @import("../../platform/linux/epoll.zig");

const MAX_JOYSTICKS_ON_LINUX = 32;
const MAX_INPUT_BUFFER = 64;

pub const EventType = enum(u8) {
    button = 0x01,
    axis = 0x02,
    init = 0x80,
    init_button = 0x81,
    init_axis = 0x82,
};

const ButtonMap = [15]events.Button;
const AxisMap = [6]events.Axis;

const defaultButtonMap: ButtonMap = .{
    .a,
    .b,
    .x,
    .y,
    .l1,
    .r1,
    .select,
    .start,
    .up,
    .l3,
    .r3,
    .down,
    .left,
    .right,
    .menu,
};

const defaultAxisMap: AxisMap = .{
    .l_stick_x,
    .l_stick_y,
    .l_trigger,
    .r_stick_x,
    .r_stick_y,
    .r_trigger,
};

/// Can be cast directly from events read from /dev/input/js*.
const RawEvent = extern struct {
    time: u32,
    value: i16,
    type: u8,
    number: u8,

    pub fn toJoystickEvent(self: RawEvent, id: usize) JoystickEvent {
        return .{
            .id = id,
            .time = self.time,
            .type = @enumFromInt(self.type),
            .number = self.number,
            .value = self.value,
        };
    }
};

pub const JoystickEvent = struct {
    id: usize,
    type: EventType,
    number: u8,
    value: i16,
    time: u32,

    pub fn toEvent(self: JoystickEvent) ?events.Event {
        return switch (self.type) {
            .button => events.Event{
                .button = .{
                    .id = @intCast(self.id),
                    .button = defaultButtonMap[self.number],
                    .pressed = self.value != 0,
                },
            },
            .axis => events.Event{
                .axis = .{
                    .id = @intCast(self.id),
                    .axis = defaultAxisMap[self.number],
                    .strength = @as(f32, @floatFromInt(self.value)) / @as(f32, std.math.maxInt(i16)),
                },
            },
            else => null,
        };
    }
};

pub const Joystick = struct {
    id: usize = 0, // id assigned to Joystick by mwl
    device: u8, // joystick device id (e.g. js0 would be 0, js1 would be 1)
    name: [128]u8 = std.mem.zeroes([128]u8),
    name_len: usize = 0,
    file: *epoll.File = undefined,

    pub inline fn getName(self: Joystick) []const u8 {
        return self.name[0..self.name_len];
    }

    pub fn init(device: u8, file_pool: *epoll.FilePool) !Joystick {
        var joystick = Joystick{
            .device = device,
        };

        var buf = std.mem.zeroes([128]u8);

        const name_path = try std.fmt.bufPrint(&buf, "/sys/class/input/js{d}/device/name", .{device});
        const name_file = try fs.openFileAbsolute(name_path, .{ .mode = .read_only, .lock_nonblocking = true });
        joystick.name_len = try name_file.readAll(&joystick.name);
        name_file.close();

        const file_path = try std.fmt.bufPrint(&buf, "/dev/input/js{d}", .{device});
        joystick.file = try file_pool.open(file_path, .{ .mode = .read_only, .lock_nonblocking = true });

        return joystick;
    }
};

pub const JoystickManager = struct {
    alloc: std.mem.Allocator,
    joysticks: std.ArrayList(Joystick),
    file_pool: epoll.FilePool,

    pub fn init(alloc: std.mem.Allocator) !JoystickManager {
        return JoystickManager{
            .alloc = alloc,
            .joysticks = try std.ArrayList(Joystick).initCapacity(alloc, MAX_JOYSTICKS_ON_LINUX),
            .file_pool = try epoll.FilePool.init(alloc),
        };
    }

    pub fn detectJoysticks(self: *JoystickManager) !usize {
        var input_dir = try fs.openDirAbsolute("/sys/class/input", .{ .iterate = true });
        defer input_dir.close();

        var input_iter = input_dir.iterate();
        while (try input_iter.next()) |fil| {
            if (std.mem.startsWith(u8, fil.name, "js")) {
                const device = try std.fmt.parseInt(u8, fil.name[2..], 10);
                var skip = false;
                // don't reinit joysticks we're already tracking
                for (self.joysticks.items) |js| {
                    if (js.device == device) {
                        skip = true;
                        break;
                    }
                }

                if (skip) {
                    continue;
                }

                var joystick = try Joystick.init(device, &self.file_pool);
                joystick.id = self.joysticks.items.len;
                try self.joysticks.append(joystick);
            }
        }

        return self.joysticks.items.len;
    }

    pub fn poll(self: *JoystickManager, event_buffer: *RingBuffer(events.Event)) !void {
        var buf = std.mem.zeroes([@sizeOf(RawEvent) * MAX_INPUT_BUFFER]u8);

        try self.file_pool.poll();
        for (self.joysticks.items) |js| {
            const len = try js.file.read(&buf);
            var offset: usize = 0;

            while (len - offset > 0) {
                var ev: *RawEvent = @alignCast(@ptrCast(&buf[offset]));
                offset += @sizeOf(RawEvent);
                if (ev.toJoystickEvent(js.id).toEvent()) |event| {
                    event_buffer.push(event);
                }
            }
        }
    }

    pub fn getJoystick(self: JoystickManager, id: usize) ?Joystick {
        if (id < self.joysticks.items.len) {
            return self.joysticks.items[id];
        }

        return null;
    }

    pub fn deinit(self: JoystickManager) void {
        for (self.joysticks.items) |js| {
            js.deinit();
        }

        self.joysticks.deinit();
    }
};
