/// This module contains types and functions specific to integrating with miniaudio
const std = @import("std");
const c = @import("c");

const log = @import("../log.zig");
const pcm = @import("./pcm.zig");
const source = @import("./source.zig");
const SoundIns = @import("../audio.zig").SoundIns;

pub const MiniaudioErr = error{
    DeviceInit,
    DeviceStart,

    DataSourceInit,
    NullBackend,
};

var device: c.ma_device = undefined;
var mix_buf = std.mem.zeroes([4096]i16);

pub fn initDevice(active_sounds: *[]SoundIns, format: pcm.Format) !void {
    log.debug("initializing audio device config", .{});
    var cfg = c.ma_device_config_init(c.ma_device_type_playback);
    cfg.playback.format = switch (format.sample_fmt) {
        .s16 => c.ma_format_s16,
        .s24 => c.ma_format_s24,
        .float32 => c.ma_format_f32,
    };
    cfg.playback.channels = @intCast(format.channels);
    cfg.sampleRate = @intCast(format.sample_rate);
    cfg.dataCallback = audioCallback;
    cfg.pUserData = @ptrCast(active_sounds);

    log.debug("initializing audio device", .{});
    if (c.ma_device_init(null, &cfg, &device) != c.MA_SUCCESS) {
        return MiniaudioErr.DeviceInit;
    }

    log.debug("starting audio device", .{});
    if (c.ma_device_start(&device) != c.MA_SUCCESS) {
        return MiniaudioErr.DeviceStart;
    }
}

pub fn deinitDevice() void {
    c.ma_device_uninit(&device);
}

export fn audioCallback(dev: ?*anyopaque, out: ?*anyopaque, _: ?*const anyopaque, frame_count: u32) void {
    const output: [*]i16 = @alignCast(@ptrCast(out));
    const d: *c.ma_device = @alignCast(@ptrCast(dev));
    const active_sounds: *[]SoundIns = @alignCast(@ptrCast(d.pUserData));
    for (active_sounds.*) |*snd| {
        if (snd.state == .stop) {
            if (snd._miniaudio_source) |*ma_source| {
                ma_source.deinit();
                snd._miniaudio_source = null;
            }

            continue;
        }

        if (snd.state == .pause or snd.state == .stop) {
            continue;
        }

        if (snd._miniaudio_source == null) {
            DataSource.init(snd) catch {
                log.err("failed to initialize DataSource", .{});
                snd.state = .stop;
                continue;
            };
        }

        var frames_read: usize = 0;
        if (c.ma_data_source_read_pcm_frames(@ptrCast(&snd._miniaudio_source), &mix_buf, frame_count, &frames_read) != c.MA_SUCCESS) {
            log.err("failed to read PCM frames from data source: {any}", .{snd.sound});
        }

        for (0..frames_read * d.playback.channels) |sample| {
            // consider clamping final value
            output[sample] += mix_buf[sample];
        }

        if (frames_read < frame_count and snd.state != .loop) {
            snd.state = .stop;
        }
    }
}

var source_config: c.ma_data_source_config = undefined;
var initialized_source_config = false;

pub fn initSourceConfig() void {
    log.debug("initializing custom audio source", .{});
    if (initialized_source_config) {
        return;
    }

    source_config = c.ma_data_source_config_init();
    source_config.vtable = &source_vtable;
    initialized_source_config = true;
}

pub const DataSource = extern struct {
    base: c.ma_data_source_base = undefined,

    loop: bool = false,
    source: *source.Source,

    /// initialize a new DataSource as part of a SoundIns. This is kind of a weird function since
    /// it initializes itself onto an existing sound so it might make sense for this _not_ to be
    /// a method.
    pub fn init(sound: *SoundIns) !void {
        std.debug.assert(initialized_source_config);

        if (sound._miniaudio_source != null) {
            sound._miniaudio_source.?.deinit();
        }

        sound._miniaudio_source = DataSource{
            .source = &sound.source,
        };

        if (c.ma_data_source_init(&source_config, &sound._miniaudio_source) != c.MA_SUCCESS) {
            return MiniaudioErr.DataSourceInit;
        }
    }

    pub fn deinit(self: *DataSource) void {
        c.ma_data_source_uninit(&self.base);
    }
};

// callbacks for implementing vtable for miniaudio custom data source
export fn onRead(src: ?*c.ma_data_source, frames_out: ?*anyopaque, frame_count: u64, frames_read: [*c]u64) c.ma_result {
    var data_source: *DataSource = @alignCast(@ptrCast(src));
    const result = data_source.source.read(frame_count) catch return c.MA_ERROR;
    const output: [*]u8 = @alignCast(@ptrCast(frames_out));
    @memcpy(output, result.data);
    frames_read.* = result.frames_read;
    return c.MA_SUCCESS;
}

export fn onSeek(src: ?*c.ma_data_source, frame_index: usize) c.ma_result {
    var data_source: *DataSource = @alignCast(@ptrCast(src));
    data_source.source.seek(frame_index) catch return c.MA_ERROR;
    return c.MA_SUCCESS;
}

export fn onGetDataFormat(src: ?*c.ma_data_source, format: [*c]c.ma_format, channels: [*c]u32, sample_rate: [*c]u32, _: [*c]c.ma_channel, _: usize) c.ma_result {
    var data_source: *DataSource = @alignCast(@ptrCast(src));
    const fmt = data_source.source.getDataFormat() catch return c.MA_ERROR;
    format.* = switch (fmt.sample_fmt) {
        .s16 => c.ma_format_s16,
        .s24 => c.ma_format_s24,
        .float32 => c.ma_format_f32,
    };
    channels.* = @intCast(fmt.channels);
    sample_rate.* = @intCast(fmt.sample_rate);

    return c.MA_SUCCESS;
}

export fn onGetCursor(src: ?*c.ma_data_source, cursor: [*c]u64) c.ma_result {
    var data_source: *DataSource = @alignCast(@ptrCast(src));
    cursor.* = @intCast(data_source.source.getCursor() catch return c.MA_ERROR);
    return c.MA_SUCCESS;
}

export fn onGetLength(src: ?*c.ma_data_source, length: [*c]u64) c.ma_result {
    var data_source: *DataSource = @alignCast(@ptrCast(src));
    length.* = @intCast(data_source.source.getLength() catch return c.MA_ERROR);
    return c.MA_SUCCESS;
}

export fn onSetLooping(src: ?*c.ma_data_source, is_looping: c.ma_bool32) c.ma_result {
    var data_source: *DataSource = @alignCast(@ptrCast(src));
    data_source.loop = is_looping != 0;
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
