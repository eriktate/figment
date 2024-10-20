const std = @import("std");

const Level = enum {
    info,
    err,
    debug,
};

pub const Logger = struct {
    start_time: i64, // microsend timestamp of logger creation
    last_time: i64, // microsecond timestamp of last log

    fn log(self: *Logger, comptime level: Level, comptime format: []const u8, args: anytype) void {
        const now = std.time.microTimestamp();
        if (self.start_time == 0) {
            self.last_time = now;
            self.start_time = now;
        }

        const total_elapsed: f32 = @floatFromInt(now - self.start_time);
        const elapsed: f32 = @floatFromInt(now - self.last_time);
        self.last_time = now;
        const args_type = @TypeOf(args);
        const args_type_info = @typeInfo(args_type);

        const logFn = switch (level) {
            .info => std.log.info,
            .err => std.log.err,
            .debug => std.log.debug,
        };

        switch (args_type_info) {
            .@"struct" => |struct_args| {
                if (struct_args.is_tuple) {
                    return logFn("({d}s)({d}ms) " ++ format, .{ total_elapsed / 1000 / 1000, elapsed / 1000 } ++ @as(args_type, args));
                }
            },
            else => {},
        }
        @compileError("args to Logger.info must be a tuple");
    }

    pub fn info(self: *Logger, comptime format: []const u8, args: anytype) void {
        self.log(.info, format, args);
    }

    pub fn debug(self: *Logger, comptime format: []const u8, args: anytype) void {
        self.log(.debug, format, args);
    }

    pub fn err(self: *Logger, comptime format: []const u8, args: anytype) void {
        self.log(.err, format, args);
    }
};

var global_log: Logger = Logger{
    .last_time = 0,
    .start_time = 0,
};

pub fn info(comptime format: []const u8, args: anytype) void {
    global_log.info(format, args);
}

pub fn debug(comptime format: []const u8, args: anytype) void {
    global_log.debug(format, args);
}

pub fn err(comptime format: []const u8, args: anytype) void {
    global_log.err(format, args);
}
