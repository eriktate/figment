const std = @import("std");
const fs = std.fs;

const MAX_JOYSTICKS_ON_LINUX = 32;

const EventType = enum(u8) {
    button = 0x01,
    axis = 0x02,
    init = 0x80,
    init_button = 0x81,
    init_axis = 0x82,
};

/// Can be cast directly from events read from /dev/input/js*.
const JoystickEvent = extern struct {
    time: u32,
    value: i16,
    type: EventType,
    number: u8,
};

const Joystick = struct {
    id: usize = 0, // id assigned to Joystick by mwl
    device: u8, // joystick device id (e.g. js0 would be 0, js1 would be 1)
    name: [128]u8 = std.mem.zeroes([128]u8),
    name_len: usize = 0,
    fd: fs.File = null,

    pub inline fn getName(self: Joystick) []const u8 {
        return self.name[0..self.name_len];
    }
};

fn getJoystick(id: u8) !Joystick {
    var joystick = Joystick{
        .id = id,
    };

    var buf = std.mem.zeroes([128]u8);

    const name_path = try std.fmt.bufPrint(&buf, "/sys/class/input/js{d}/device/name", .{id});
    const name_file = try fs.openFileAbsolute(name_path, .{ .mode = .read_only });
    joystick.name_len = try name_file.readAll(&joystick.name);
    name_file.close();

    const fd_path = try std.fmt.bufPrint(&buf, "/dev/input/js{d}", .{id});
    joystick.fd = try fs.openFileAbsolute(fd_path, .{ .mode = .read_only, .lock_nonblocking = true });

    return joystick;
}

const JoystickManager = struct {
    alloc: std.mem.Allocator,
    joysticks: std.ArrayList(Joystick),
    event_buffer: [256]JoystickEvent,

    pub fn init(alloc: std.mem.Allocator) !JoystickManager {
        return JoystickManager{
            .alloc = alloc,
            .joysticks = try std.ArrayList(Joystick).initCapacity(alloc, MAX_JOYSTICKS_ON_LINUX),
            .event_buffer = std.mem.zeroes([128]JoystickEvent),
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

                try self.joysticks.append(try getJoystick(device));
            }
        }

        return self.joysticks.len;
    }

    pub fn poll(self: *JoystickManager) !void {
        var buf = std.mem.zeroes([@sizeOf(JoystickEvent) * 64]u8);
        // TODO (soggy): Add ring buffer to append events to

        for (self.joysticks.items) |js| {
            const len = try js.fd.read(&buf);
            var offset = 0;

            while (len - offset > 0) {
                var ev: *JoystickEvent = @alignCast(@ptrCast(&buf));
                offset += @sizeOf(JoystickEvent);
            }
        }
    }
};
