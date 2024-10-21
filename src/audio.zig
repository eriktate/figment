const std = @import("std");
const log = @import("log.zig");
const wav = @import("audio/wav.zig");
const source = @import("audio/source.zig");
const pcm = @import("audio/pcm.zig");
const stream = @import("audio/stream.zig");
const miniaudio = @import("audio/miniaudio.zig");

pub const Format = pcm.Format;

const MAX_AUDIO_BUFFER_SIZE = 2 * 1024 * 1024; // 2MB is the largest PCM buffer size allowed for in-memory buffer sources

pub const Sound = enum {
    speech,
    bark,
    bg_seeing_die_dog,
};

pub const State = enum {
    /// a stopped sound can be reclaimed
    stop,
    /// a paused sound doesn't play, but can't be reclaimed
    pause,
    /// a playing sound is a one shot that transitions to stop after finishing
    play,
    /// a looping sound plays indefinitely until manually changed to pause or stop
    loop,
};

pub const SoundIns = struct {
    state: State = .stop,
    sound: Sound = .bark,
    source: source.Source = .{ .empty = {} },

    _miniaudio_source: ?miniaudio.DataSource = null,

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

var sound_buffer = [_]SoundIns{.{}} ** 50;
var active_sounds: []SoundIns = &sound_buffer;
var sources = std.EnumArray(Sound, source.Source).initFill(undefined);
var alloc: std.mem.Allocator = undefined;
var channels: usize = 2;

pub fn init(allocator: std.mem.Allocator, format: Format) !void {
    alloc = allocator;
    try miniaudio.initDevice(&active_sounds, format);
    miniaudio.initSourceConfig();

    // TODO (soggy): consider validating that all initialized sources match the format specified for the device
    try initSource(.speech, "assets/sounds/speech.wav");
    try initSource(.bark, "assets/sounds/bark.wav");
    try initSource(.bg_seeing_die_dog, "assets/sounds/seeingdiedog.wav");

    const audioBytes: f32 = @floatFromInt(memBytes());
    log.info("memory reserved for sounds: {d}M", .{audioBytes / 1024 / 1024});
}

fn initSource(sound: Sound, path: []const u8) !void {
    log.info("init sound {any} from path {s}", .{ sound, path });
    const wav_file = try wav.loadFromFile(path);

    if (wav_file.data.size <= MAX_AUDIO_BUFFER_SIZE) {
        log.info("convert sound to PCMBuffer", .{});
        const buf = try wav_file.toBuffer(alloc);

        log.info("save buffer for later", .{});
        sources.set(sound, .{ .buffer = buf });
    } else {
        log.info("create stream", .{});
        const st = try stream.Stream.init(alloc, wav_file);
        log.info("save stream for later", .{});
        sources.set(sound, .{ .stream = st });
    }
}

pub fn deinit() void {
    for (&sources.values) |*src| {
        src.deinit();
    }

    miniaudio.deinitDevice();
}

fn addSound(sound: SoundIns) *SoundIns {
    var new_sound: *SoundIns = undefined;
    for (active_sounds) |*active_snd| {
        if (active_snd.state == .stop) {
            new_sound = active_snd;
            break;
        }
    }

    new_sound.* = sound;
    new_sound.play();

    return new_sound;
}

pub fn play(sound: Sound) *SoundIns {
    var snd = SoundIns.init(sound);
    snd.state = .play;
    return addSound(snd);
}

pub fn loop(sound: Sound) *SoundIns {
    var snd = SoundIns.init(sound);
    snd.state = .loop;
    return addSound(snd);
}

pub fn memBytes() usize {
    var bytes: usize = 0;

    for (sources.values) |src| {
        switch (src) {
            .buffer => |buffer| bytes += buffer.buf.len * @sizeOf(f32),
            .stream => continue,
            .empty => continue,
        }
    }

    return bytes;
}
