const std = @import("std");

pub const Level = enum {
    info,
    err,
    debug,
};

pub const Metric = enum {
    update,
    quads,
    render,
    swap,
    sort,
    loop,
};

pub const Stat = struct {
    metric: Metric,
    started_at: i64,
    total_time: i64,
    count: i64,

    pub fn start(self: *Stat) void {
        self.started_at = std.time.microTimestamp();
    }

    pub fn finish(self: *Stat) void {
        self.total_time += std.time.microTimestamp() - self.started_at;
        self.count += 1;
    }

    pub fn clear(self: *Stat) void {
        self.total_time = 0;
        self.count = 0;
    }

    /// computes the metric rate per millisecond
    pub fn getRateMS(self: Stat) f64 {
        if (self.total_time == 0) {
            return 0;
        }

        const total_time: f64 = @floatFromInt(self.total_time);
        const count: f64 = @floatFromInt(self.count);
        const rate = (count / (total_time / 1000));
        return rate;
    }

    pub fn getRate(self: Stat) i64 {
        return @intFromFloat(getRateMS(self) * 1000);
    }

    pub fn getAverageTimeMS(self: Stat) f64 {
        if (self.count == 0) {
            return 0;
        }

        const total_time: f64 = @floatFromInt(self.total_time);
        const count: f64 = @floatFromInt(self.count);
        const avg = (total_time / count) / 1000;
        return avg;
    }

    pub fn zero() Stat {
        return Stat{
            .metric = .update,
            .started_at = 0,
            .total_time = 0,
            .count = 0,
        };
    }
};

pub const Logger = struct {
    start_time: i64, // microsend timestamp of logger creation
    last_time: i64, // microsecond timestamp of last log

    prev_stats: std.EnumArray(Metric, Stat),
    stats: std.EnumArray(Metric, Stat),

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

    pub fn start(self: *Logger, metric: Metric) void {
        self.stats.getPtr(metric).start();
    }

    pub fn finish(self: *Logger, metric: Metric) void {
        self.stats.getPtr(metric).finish();
    }

    pub fn reset(self: *Logger) void {
        for (&self.stats.values) |*stat| {
            self.prev_stats.set(stat.metric, stat.*);
            stat.clear();
        }
    }

    pub fn showStats(self: *Logger) void {
        for (&self.stats.values) |stat| {
            const val_f: f64 = @floatFromInt(@divTrunc(stat.total_time, stat.count));
            self.info("{any} avg time {d}ms", .{ stat.metric, val_f / 1000 });
        }
    }

    pub fn getStat(self: *Logger, metric: Metric) Stat {
        return self.stats.get(metric);
    }

    pub fn getLastStat(self: *Logger, metric: Metric) Stat {
        return self.prev_stats.get(metric);
    }
};

fn getEmptyStats() std.EnumArray(Metric, Stat) {
    comptime {
        var emptyStats = std.EnumArray(Metric, Stat).initUndefined();
        for (0..@intFromEnum(Metric.loop) + 1) |idx| {
            var stat = Stat.zero();
            stat.metric = @enumFromInt(idx);
            emptyStats.set(stat.metric, stat);
        }

        return emptyStats;
    }
}

var global_log: Logger = Logger{
    .last_time = 0,
    .start_time = 0,
    .stats = getEmptyStats(),
    .prev_stats = getEmptyStats(),
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

pub fn start(metric: Metric) void {
    global_log.start(metric);
}

pub fn finish(metric: Metric) void {
    global_log.finish(metric);
}

pub fn reset() void {
    global_log.reset();
}

pub fn stats() void {
    global_log.showStats();
}

pub fn getStat(metric: Metric) Stat {
    return global_log.getStat(metric);
}

pub fn getLastStat(metric: Metric) Stat {
    return global_log.getLastStat(metric);
}
