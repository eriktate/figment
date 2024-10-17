const std = @import("std");
const c = @import("c");
const log = @import("log.zig");

const MAX_AUDIO_BUFFER_SIZE = 20 * 1024 * 1024; // 4MB is the largest PCM buffer size allowed for in-memory buffer sources

pub const AudioErr = error{
    DeviceInit,
    DeviceStart,
    ContextInit,
    DecoderInit,
    DecodingFail,
    BufferInit,
};

pub const Sound = enum {
    speech,
    bark,
    bg_seeing_die_dog,
};

pub const State = enum {
    stop,
    pause,
    play,
    loop,
};

const Buffer = struct {
    buf: []f32, // backing data for buffer to be free'd
    buffer: c.ma_audio_buffer,
};

const Stream = struct {
    stream: *c.ma_decoder, // TODO (soggy): replace this with a custom implementation to guarantee buffered streaming behavior
};

const SourceKind = enum {
    buffer,
    stream,
};

const Source = union(SourceKind) {
    buffer: Buffer,
    stream: Stream,
};

pub const SoundIns = struct {
    state: State,
    sound: Sound,
    source: Source,

    pub fn init(sound: Sound) SoundIns {
        return .{
            .state = .play,
            .sound = sound,
            .source = sources.get(sound),
        };
    }

    pub fn play(self: *SoundIns) void {
        self.state = .play;
    }

    pub fn pause(self: *SoundIns) void {
        self.state = .pause;
    }

    pub fn stop(self: *SoundIns) void {
        self.state = .stop;
    }
};

var device: c.ma_device = undefined;
var active_sounds: [50]?SoundIns = undefined;
var sources = std.EnumArray(Sound, Source).initFill(undefined);
var alloc: std.mem.Allocator = undefined;
var channels: usize = 2;

export fn audioCallback(_: ?*anyopaque, out: ?*anyopaque, _: ?*const anyopaque, frame_count: u32) void {
    const output: [*]f32 = @alignCast(@ptrCast(out));
    mixAudio(output, frame_count);
}

fn mixAudio(out: [*]f32, frame_count: u32) void {
    var mix_buf = std.mem.zeroes([4096]f32);
    for (active_sounds, 0..) |sound, idx| {
        if (sound == null) {
            continue;
        }

        const snd = &active_sounds[idx].?;

        if (snd.state == .pause) {
            continue;
        }

        if (snd.state == .stop) {
            active_sounds[idx] = null;
            continue;
        }

        var frames_read: usize = 0;
        switch (snd.source) {
            .stream => {
                if (c.ma_decoder_read_pcm_frames(snd.source.stream.stream, &mix_buf, frame_count, &frames_read) != c.MA_SUCCESS) {
                    log.err("failed to read PCM frames from stream: {any}", .{snd.sound});
                }
            },
            .buffer => {
                frames_read = c.ma_audio_buffer_read_pcm_frames(&snd.source.buffer.buffer, &mix_buf, frame_count, @intFromBool(snd.state == .loop));
            },
        }

        for (0..frames_read * channels) |sample| {
            // consider clamping final value to  -1 to 1
            out[sample] += mix_buf[sample];
        }

        if (frames_read < frame_count and snd.state != .loop) {
            switch (snd.source) {
                .stream => _ = c.ma_decoder_seek_to_pcm_frame(snd.source.stream.stream, 0),
                else => {},
            }

            active_sounds[idx] = null;
        }
    }
}

pub fn init(allocator: std.mem.Allocator) !void {
    alloc = allocator;
    var config = c.ma_device_config_init(c.ma_device_type_playback);
    config.playback.format = c.ma_format_f32;
    config.playback.channels = @intCast(channels);
    config.sampleRate = 48000;
    config.dataCallback = audioCallback;
    config.pUserData = null;

    if (c.ma_device_init(null, &config, &device) != c.MA_SUCCESS) {
        return AudioErr.DeviceInit;
    }

    if (c.ma_device_start(&device) != c.MA_SUCCESS) {
        return AudioErr.DeviceStart;
    }

    try initSound(.speech, "assets/sounds/speech.wav", null);
    try initSound(.bark, "assets/sounds/bark.wav", null);
    try initSound(.bg_seeing_die_dog, "assets/sounds/seeingdiedog.wav", null);
    for (active_sounds, 0..) |_, idx| {
        active_sounds[idx] = null;
    }

    const audioBytes: f32 = @floatFromInt(memBytes());
    log.info("memory reserved for sounds: {d}M", .{audioBytes / 1024 / 1024});
}

fn initSound(sound: Sound, path: []const u8, source_override: ?SourceKind) !void {
    var path_buf: [1024 * 4]u8 = undefined;
    const absolute_path = try std.fs.cwd().realpath(path, path_buf[0..]);
    path_buf[absolute_path.len] = 0;
    const decoder = try alloc.create(c.ma_decoder);
    var dec_config = c.ma_decoder_config_init(c.ma_format_f32, @intCast(channels), 48000);
    dec_config.encodingFormat = c.ma_encoding_format_wav;

    // I don't love that miniaudio has to allocate using this method. At some point I'll probably build my own WAV and OGG decoders
    // to ensure streaming behaviors and control all allocations
    const result = c.ma_decoder_init_file(absolute_path.ptr, &dec_config, decoder);
    if (result != c.MA_SUCCESS) {
        log.err("failed to init decoder: {d}", .{result});
        return AudioErr.DecoderInit;
    }

    const tmp = try alloc.alloc(f32, MAX_AUDIO_BUFFER_SIZE);
    defer alloc.free(tmp);

    const frame_count = 1200;
    var frames_read: u64 = frame_count;
    var total_frames: usize = 0;
    while (frames_read == frame_count) {
        if (c.ma_decoder_read_pcm_frames(decoder, &tmp[total_frames * channels], frame_count, &frames_read) != c.MA_SUCCESS) {
            return AudioErr.DecodingFail;
        }
        total_frames += frames_read;
    }

    // forcing source_override to .buffer for now
    const override = if (source_override == .buffer) SourceKind.buffer else SourceKind.buffer;

    // stream source
    if (override == .stream or (override != .buffer and total_frames * channels * @sizeOf(f32) > MAX_AUDIO_BUFFER_SIZE)) {
        log.info("setting {any} to stream", .{sound});
        _ = c.ma_decoder_seek_to_pcm_frame(decoder, 0);
        sources.set(sound, .{ .stream = .{ .stream = decoder } });
        return;
    }

    log.info("setting {any} to buffer", .{sound});

    // buffer source
    defer _ = c.ma_decoder_uninit(decoder);
    const pcm_buf = try alloc.alloc(f32, total_frames * channels);
    @memcpy(pcm_buf, tmp[0 .. total_frames * channels]);

    var buf_config = c.ma_audio_buffer_config_init(c.ma_format_f32, @intCast(channels), pcm_buf.len / channels, pcm_buf.ptr, null);
    var audio_buffer: c.ma_audio_buffer = undefined;
    if (c.ma_audio_buffer_init(&buf_config, &audio_buffer) != c.MA_SUCCESS) {
        return AudioErr.BufferInit;
    }

    sources.set(sound, .{ .buffer = .{ .buf = pcm_buf, .buffer = audio_buffer } });
}

pub fn deinit() void {
    c.ma_device_uninit(&device);
    for (sources.values) |source| {
        switch (source) {
            .stream => |stream| _ = c.ma_decoder_uninit(stream.stream),
            .buffer => |buf| alloc.free(buf.buf),
        }
    }
}

pub fn play(sound: Sound) *SoundIns {
    const snd = SoundIns.init(sound);
    var idx: usize = 0;
    for (active_sounds) |active_snd| {
        if (active_snd == null) {
            break;
        }

        idx += 1;
    }

    active_sounds[idx] = snd;
    return &active_sounds[idx].?;
}

pub fn loop(sound: Sound) *SoundIns {
    var snd = SoundIns.init(sound);
    snd.state = .loop;
    var idx: usize = 0;
    for (active_sounds) |active_snd| {
        if (active_snd == null) {
            break;
        }

        idx += 1;
    }

    active_sounds[idx] = snd;
    return &active_sounds[idx].?;
}

pub fn memBytes() usize {
    var bytes: usize = 0;

    for (sources.values) |source| {
        switch (source) {
            .buffer => bytes += source.buffer.buf.len * @sizeOf(f32),
            .stream => {},
        }
    }

    return bytes;
}
