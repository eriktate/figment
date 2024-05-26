const std = @import("std");
const c = @import("c.zig");
const log = @import("log.zig");

pub const AudioErr = error{
    DeviceInit,
    ContextInit,
    DecoderInit,
};

pub const Sound = enum {
    speech,
};

pub const State = enum {
    play,
    pause,
    stop,
};

pub const SoundIns = struct {
    state: State,
    sound: Sound,
    decoder: c.ma_decoder,

    pub fn init(sound: Sound) SoundIns {
        return .{
            .state = .play,
            .sound = sound,
            .decoder = decoders.get(sound),
        };
    }
};

var device: c.ma_device = undefined;
var decoders: std.EnumArray(c.ma_decoder) = undefined;
var active_sounds = [_]?SoundIns{null} ** 50;

export fn audio_callback(_: ?*c.ma_device, out: anyopaque, _: anyopaque, frame_count: u32) void {
    for (active_sounds, 0..) |sound, idx| {
        var frames_read: u64 = undefined;
        if (c.ma_decoder_read_pcm_frames(sound.decoder, out, frame_count, &frames_read) != c.MA_SUCCESS) {
            log.err("failed to read PCM frames");
        }

        if (frames_read < frame_count) {
            active_sounds[idx] = null;
        }
    }
}

pub fn init(alloc: std.mem.Allocator) !void {
    var config = c.ma_device_config_init(c.ma_device_type_playback);
    config.playback.format = c.ma_format_f32;
    config.playback.channels = 2;
    config.sampleRate = 48000;
    config.dataCallback = audio_callback;
    config.pUserData = null;

    if (c.ma_device_init(null, &config, &device) != c.MA_SUCCESS) {
        return AudioErr.DeviceInit;
    }

    c.ma_device_start(&device);

    const file = try std.fs.cwd().openFile("assets/sounds/speech.wav", .{ .mode = .read_only });
    defer file.close();

    const file_info = try file.stat();
    const sound_buf = try alloc.alloc(u8, file_info.size); // TODO: fix leak
    _ = try file.readAll(sound_buf);
    const decoder = decoders.getPtr(.speech);
    if (c.ma_decoder_init_memory(sound_buf.ptr, sound_buf.len, null, decoder) != c.MA_SUCCESS) {
        return AudioErr.DecoderInit;
    }
}

pub fn deinit() void {
    c.ma_device_uninit(device);
    for (decoders) |decoder| {
        c.ma_decoder_uninit(&decoder);
    }
}

pub fn play(sound: Sound) !void {
    for (active_sounds, 0..) |active_snd, idx| {
        if (active_snd != null) {
            continue;
        }

        active_sounds[idx] = SoundIns.init(sound);
    }
}
