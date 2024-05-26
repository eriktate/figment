const std = @import("std");
const c = @import("c.zig");
const log = @import("log.zig");

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
    buffer: c.ma_audio_buffer,

    pub fn init(sound: Sound) SoundIns {
        return .{
            .state = .play,
            .sound = sound,
            .buffer = sound_buffers.get(sound),
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
var sound_buffers = std.EnumArray(Sound, c.ma_audio_buffer).initFill(undefined);
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

        const frames_read = c.ma_audio_buffer_read_pcm_frames(&snd.buffer, &mix_buf, frame_count, @intFromBool(snd.state == .loop));

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

    try initSound(.speech, "assets/sounds/speech.wav");
    for (active_sounds, 0..) |_, idx| {
        active_sounds[idx] = null;
    }
}

fn initSound(sound: Sound, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const file_info = try file.stat();
    const sound_buf = try alloc.alloc(u8, file_info.size); // TODO: fix leak
    _ = try file.readAll(sound_buf);

    var decoder: c.ma_decoder = undefined;
    var dec_config = c.ma_decoder_config_init(c.ma_format_f32, @intCast(channels), 48000);
    dec_config.encodingFormat = c.ma_encoding_format_wav;

    if (c.ma_decoder_init_memory(sound_buf.ptr, sound_buf.len, &dec_config, &decoder) != c.MA_SUCCESS) {
        return AudioErr.DecoderInit;
    }
    defer _ = c.ma_decoder_uninit(&decoder);

    // number of frames should always at least be less than the file length
    const tmp = try alloc.alloc(f32, 1024 * 1024);
    defer alloc.free(tmp);

    const frame_count = 1200;
    var frames_read: u64 = frame_count;
    var total_frames: usize = 0;
    while (frames_read == frame_count) {
        if (c.ma_decoder_read_pcm_frames(&decoder, &tmp[total_frames * channels], frame_count, &frames_read) != c.MA_SUCCESS) {
            return AudioErr.DecodingFail;
        }
        total_frames += frames_read;
    }

    const pcm_buf = try alloc.alloc(f32, total_frames * channels);
    @memcpy(pcm_buf, tmp[0 .. total_frames * channels]);

    log.info("final PCM buf size: {d}kb", .{pcm_buf.len * @sizeOf(f32) / 1024});
    var buf_config = c.ma_audio_buffer_config_init(c.ma_format_f32, @intCast(channels), pcm_buf.len / channels, pcm_buf.ptr, null);
    var audio_buffer: c.ma_audio_buffer = undefined;
    if (c.ma_audio_buffer_init(&buf_config, &audio_buffer) != c.MA_SUCCESS) {
        return AudioErr.BufferInit;
    }

    sound_buffers.set(sound, audio_buffer);
}

pub fn deinit() void {
    c.ma_device_uninit(device);
    for (sound_buffers) |buf| {
        alloc.free(buf);
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
