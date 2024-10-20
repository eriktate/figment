const std = @import("std");
const c = @import("c");
const log = @import("log.zig");
const wav = @import("audio/wav.zig");
const source = @import("audio/source.zig");

const MAX_AUDIO_BUFFER_SIZE = 20 * 1024 * 1024; // 20MB is the largest PCM buffer size allowed for in-memory buffer sources

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

pub const SoundIns = struct {
    state: State,
    sound: Sound,
    backend: source.Backend,
    source: source.Source,

    pub fn init(sound: Sound) SoundIns {
        return .{
            .state = .play,
            .sound = sound,
            .backend = sources.get(sound),
            .source = undefined,
        };
    }

    pub fn play(self: *SoundIns) void {
        self.state = .play;
    }

    pub fn loop(self: *SoundIns) void {
        self.state = .loop;
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
var sources = std.EnumArray(Sound, source.Backend).initFill(undefined);
var alloc: std.mem.Allocator = undefined;
var channels: usize = 2;

export fn audioCallback(_: ?*anyopaque, out: ?*anyopaque, _: ?*const anyopaque, frame_count: u32) void {
    const output: [*]i16 = @alignCast(@ptrCast(out));
    mixAudio(output, frame_count);
}

fn mixAudio(out: [*]i16, frame_count: u32) void {
    var mix_buf = std.mem.zeroes([4096]i16);
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
        if (c.ma_data_source_read_pcm_frames(@ptrCast(&snd.source), &mix_buf, frame_count, &frames_read) != c.MA_SUCCESS) {
            log.err("failed to read PCM frames from data source: {any}", .{snd.sound});
        }

        for (0..frames_read * channels) |sample| {
            // consider clamping final value to  -1 to 1
            out[sample] += mix_buf[sample];
        }

        if (frames_read < frame_count and snd.state != .loop) {
            active_sounds[idx] = null;
        }
    }
}

pub fn init(allocator: std.mem.Allocator) !void {
    alloc = allocator;
    var config = c.ma_device_config_init(c.ma_device_type_playback);
    config.playback.format = c.ma_format_s16;
    config.playback.channels = @intCast(channels);
    config.sampleRate = 44100;
    config.dataCallback = audioCallback;
    config.pUserData = null;

    log.info("initializing audio device", .{});
    if (c.ma_device_init(null, &config, &device) != c.MA_SUCCESS) {
        return AudioErr.DeviceInit;
    }

    log.info("starting audio device", .{});
    if (c.ma_device_start(&device) != c.MA_SUCCESS) {
        return AudioErr.DeviceStart;
    }

    try initSound(.speech, "assets/sounds/speech.wav");
    try initSound(.bark, "assets/sounds/bark.wav");
    try initSound(.bg_seeing_die_dog, "assets/sounds/seeingdiedog.wav");

    for (active_sounds, 0..) |_, idx| {
        active_sounds[idx] = null;
    }

    const audioBytes: f32 = @floatFromInt(memBytes());
    log.info("memory reserved for sounds: {d}M", .{audioBytes / 1024 / 1024});
}

fn initSound(sound: Sound, path: []const u8) !void {
    log.info("init sound {any} from path {s}", .{ sound, path });
    const wav_file = try wav.loadFromFile(path);

    log.info("convert sound to PCMBuffer", .{});
    const buf = try wav_file.toBuffer(alloc);

    log.info("save buffer for later", .{});
    sources.set(sound, .{ .buffer = buf });
}

pub fn deinit() void {
    // for (sources.values) |src| {
    //     src.deinit();
    // }

    c.ma_device_uninit(&device);
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
    var ins = &active_sounds[idx].?;
    const src = source.create(&ins.backend);
    ins.source = src;
    ins.source.init() catch log.err("failed to init audio source", .{});
    ins.play();

    return ins;
}

pub fn loop(sound: Sound) *SoundIns {
    const snd = SoundIns.init(sound);
    var idx: usize = 0;
    for (active_sounds) |active_snd| {
        if (active_snd == null) {
            break;
        }

        idx += 1;
    }

    active_sounds[idx] = snd;
    var ins = &active_sounds[idx].?;
    const src = source.create(&ins.backend);
    ins.source = src;
    ins.source.init() catch log.err("failed to init audio source", .{});
    ins.loop();

    return ins;
}

pub fn memBytes() usize {
    var bytes: usize = 0;

    for (sources.values) |src| {
        switch (src) {
            .buffer => |buffer| bytes += buffer.buf.len * @sizeOf(f32),
        }
    }

    return bytes;
}
