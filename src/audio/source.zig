const c = @import("c");
const wav = @import("./wav.zig");
const pcm = @import("./pcm.zig");

pub fn create(backend: *Backend) Source {
    return Source{ .backend = backend };
}

pub const SourceErr = error{
    DataSourceInit,
    NullBackend,
};

pub const SourceKind = enum {
    buffer,
};

pub const Backend = union(SourceKind) {
    buffer: pcm.Buffer,

    pub fn read(self: *Backend, frames: usize) !pcm.Result {
        switch (self.*) {
            .buffer => |*buffer| {
                const result = buffer.read(frames);
                return result;
            },
        }
    }

    pub fn seek(self: *Backend, frame_idx: usize) !void {
        switch (self.*) {
            .buffer => |*buffer| {
                return buffer.seek(frame_idx);
            },
        }
    }

    pub fn getDataFormat(self: *Backend) !pcm.Format {
        switch (self.*) {
            .buffer => |buffer| {
                return buffer.fmt;
            },
        }
    }

    pub fn getCursor(self: *Backend) !usize {
        switch (self.*) {
            .buffer => |buffer| {
                return buffer.getFrameOffset();
            },
        }
    }

    pub fn getLength(self: *Backend) !usize {
        switch (self.*) {
            .buffer => |buffer| {
                return buffer.getFrameLength();
            },
        }
    }
};

pub const Source = extern struct {
    base: c.ma_data_source_base = undefined,

    loop: bool = false,
    backend: *Backend,

    pub fn init(self: *Source) !void {
        var cfg = c.ma_data_source_config_init();
        cfg.vtable = &source_vtable;
        if (c.ma_data_source_init(&cfg, &self.base) != c.MA_SUCCESS) {
            return SourceErr.DataSourceInit;
        }
    }

    pub fn deinit(self: *Source) void {
        c.ma_data_source_uninit(&self.base);
    }
};

// callbacks for implementing vtable for miniaudio custom data source
export fn onRead(data_source: ?*c.ma_data_source, frames_out: ?*anyopaque, frame_count: u64, frames_read: [*c]u64) c.ma_result {
    var source: *Source = @alignCast(@ptrCast(data_source));
    const result = source.backend.read(frame_count) catch return c.MA_ERROR;
    const output: [*]u8 = @alignCast(@ptrCast(frames_out));
    @memcpy(output, result.data);
    frames_read.* = result.frames_read;
    return c.MA_SUCCESS;
}

export fn onSeek(data_source: ?*c.ma_data_source, frame_index: usize) c.ma_result {
    var source: *Source = @alignCast(@ptrCast(data_source));
    source.backend.seek(frame_index) catch return c.MA_ERROR;
    return c.MA_SUCCESS;
}

export fn onGetDataFormat(data_source: ?*c.ma_data_source, format: [*c]c.ma_format, channels: [*c]u32, sample_rate: [*c]u32, _: [*c]c.ma_channel, _: usize) c.ma_result {
    var source: *Source = @alignCast(@ptrCast(data_source));
    const fmt = source.backend.getDataFormat() catch return c.MA_ERROR;
    format.* = switch (fmt.depth) {
        .s16 => c.ma_format_s16,
        .s24 => c.ma_format_s24,
        .float32 => c.ma_format_f32,
    };
    channels.* = @intCast(fmt.channels);
    sample_rate.* = @intCast(fmt.sample_rate);

    return c.MA_SUCCESS;
}

export fn onGetCursor(data_source: ?*c.ma_data_source, cursor: [*c]u64) c.ma_result {
    var source: *Source = @alignCast(@ptrCast(data_source));
    cursor.* = @intCast(source.backend.getCursor() catch return c.MA_ERROR);
    return c.MA_SUCCESS;
}

export fn onGetLength(data_source: ?*c.ma_data_source, length: [*c]u64) c.ma_result {
    var source: *Source = @alignCast(@ptrCast(data_source));
    length.* = @intCast(source.backend.getLength() catch return c.MA_ERROR);
    return c.MA_SUCCESS;
}

export fn onSetLooping(data_source: ?*c.ma_data_source, is_looping: c.ma_bool32) c.ma_result {
    var source: *Source = @alignCast(@ptrCast(data_source));
    source.loop = is_looping != 0;
    return c.MA_SUCCESS;
}

pub const source_vtable: c.ma_data_source_vtable = .{
    .onRead = &onRead,
    .onSeek = &onSeek,
    .onGetDataFormat = &onGetDataFormat,
    .onGetCursor = &onGetCursor,
    .onGetLength = &onGetLength,
    .onSetLooping = &onSetLooping,
    .flags = 1,
};
