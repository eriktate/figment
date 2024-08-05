const std = @import("std");

pub const Logger = struct {
    last_time: i64, // microsecond timestamp of last log

    pub fn info(self: *Logger, comptime format: []const u8, args: anytype) void {
        const now = std.time.microTimestamp();
        const elapsed: f32 = if (self.last_time > 0) @floatFromInt(now - self.last_time) else 0;
        self.last_time = now;

        const args_type = @TypeOf(args);
        const args_type_info = @typeInfo(args_type);
        switch (args_type_info) {
            .Struct => |struct_args| {
                if (struct_args.is_tuple) {
                    return std.log.info("({d}ms) " ++ format, .{elapsed / 1000} ++ @as(args_type, args));
                }
            },
            else => {},
        }
        @compileError("args to Logger.info must be a tuple");
    }

    pub fn debug(self: *Logger, comptime format: []const u8, args: anytype) void {
        const now = std.time.microTimestamp();
        const elapsed: f32 = if (self.last_time > 0) @floatFromInt(now - self.last_time) else 0;
        self.last_time = now;

        const args_type = @TypeOf(args);
        const args_type_info = @typeInfo(args_type);
        switch (args_type_info) {
            .Struct => |struct_args| {
                if (struct_args.is_tuple) {
                    return std.log.debug("({d}ms) " ++ format, .{elapsed / 1000} ++ @as(args_type, args));
                }
            },
            else => {},
        }
        @compileError("args to Logger.info must be a tuple");
    }

    pub fn err(self: *Logger, comptime format: []const u8, args: anytype) void {
        const now = std.time.microTimestamp();
        const elapsed: f32 = if (self.last_time > 0) @floatFromInt(now - self.last_time) else 0;
        self.last_time = now;

        const args_type = @TypeOf(args);
        const args_type_info = @typeInfo(args_type);
        switch (args_type_info) {
            .Struct => |struct_args| {
                if (struct_args.is_tuple) {
                    return std.log.err("({d}ms) " ++ format, .{elapsed / 1000} ++ @as(args_type, args));
                }
            },
            else => {},
        }
        @compileError("args to Logger.info must be a tuple");
    }
};

var global_log: Logger = Logger{
    .last_time = 0,
};

pub fn info(comptime format: []const u8, args: anytype) void {
    global_log.info(format, args);
}

pub fn err(comptime format: []const u8, args: anytype) void {
    global_log.err(format, args);
}
