const std = @import("std");
const fs = std.fs;
const RingBuffer = @import("../../ringbuffer.zig").RingBuffer;

const MAX_JOYSTICKS_ON_LINUX = 32;
const MAX_INPUT_BUFFER = 64;

pub const EventType = enum(u8) {
    button = 0x01,
    axis = 0x02,
    init = 0x80,
    init_button = 0x81,
    init_axis = 0x82,
};

/// Can be cast directly from events read from /dev/input/js*.
const RawEvent = extern struct {
    time: u32,
    value: i16,
    type: EventType,
    number: u8,

    pub fn toJoystickEvent(self: RawEvent, id: usize) JoystickEvent {
        return .{
            .id = id,
            .time = self.time,
            .type = self.type,
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
};

pub const Joystick = struct {
    id: usize = 0, // id assigned to Joystick by mwl
    device: u8, // joystick device id (e.g. js0 would be 0, js1 would be 1)
    name: [128]u8 = std.mem.zeroes([128]u8),
    name_len: usize = 0,
    fd: fs.File = undefined,

    pub inline fn getName(self: Joystick) []const u8 {
        return self.name[0..self.name_len];
    }

    pub fn init(device: u8) !Joystick {
        var joystick = Joystick{
            .device = device,
        };

        var buf = std.mem.zeroes([128]u8);

        const name_path = try std.fmt.bufPrint(&buf, "/sys/class/input/js{d}/device/name", .{device});
        const name_file = try fs.openFileAbsolute(name_path, .{ .mode = .read_only });
        joystick.name_len = try name_file.readAll(&joystick.name);
        name_file.close();

        const fd_path = try std.fmt.bufPrint(&buf, "/dev/input/js{d}", .{device});
        joystick.fd = try fs.openFileAbsolute(fd_path, .{ .mode = .read_only, .lock_nonblocking = true });

        return joystick;
    }

    pub fn deinit(self: Joystick) void {
        self.fd.close();
    }
};

pub const JoystickManager = struct {
    alloc: std.mem.Allocator,
    joysticks: std.ArrayList(Joystick),
    raw_buffer: [MAX_INPUT_BUFFER]JoystickEvent,
    event_buffer: RingBuffer(JoystickEvent),

    pub fn init(alloc: std.mem.Allocator) !JoystickManager {
        var mgr = JoystickManager{ .alloc = alloc, .joysticks = try std.ArrayList(Joystick).initCapacity(alloc, MAX_JOYSTICKS_ON_LINUX), .raw_buffer = std.mem.zeroes([MAX_INPUT_BUFFER]JoystickEvent), .event_buffer = undefined };
        mgr.event_buffer = RingBuffer(JoystickEvent).init(&mgr.raw_buffer);

        return mgr;
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

                var joystick = try Joystick.init(device);
                joystick.id = self.joysticks.items.len;
                try self.joysticks.append(joystick);
            }
        }

        return self.joysticks.items.len;
    }

    pub fn poll(self: *JoystickManager) !*RingBuffer(JoystickEvent) {
        // TODO (soggy): can't produce a default zeroed JoystickEvent because there is no
        // zero value for the EventType enum
        var buf = std.mem.zeroes([@sizeOf(JoystickEvent) * 64]u8);

        for (self.joysticks.items) |js| {
            const len = try js.fd.read(&buf);
            var offset: usize = 0;

            while (len - offset > 0) {
                var ev: *RawEvent = @alignCast(@ptrCast(&buf));
                offset += @sizeOf(JoystickEvent);
                self.event_buffer.push(ev.toJoystickEvent(js.id));
            }
        }

        return &self.event_buffer;
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
