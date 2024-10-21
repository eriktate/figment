const std = @import("std");
const log = @import("../log.zig");
const wav = @import("./wav.zig");
const pcm = @import("./pcm.zig");
const RingBuffer = @import("../ringbuffer.zig").RingBuffer;

const MAX_BUFFER_SECONDS = 3;
const MIN_BUFFER_SECONDS = 2;

pub const Stream = struct {
    alloc: std.mem.Allocator,
    buffer: []u8,
    rb: RingBuffer(u8),
    live_buf: []u8,
    wav: wav.Wav,

    frames_read: usize = 0,
    eof: bool = false,
    loop: bool = false,

    pub fn init(alloc: std.mem.Allocator, w: wav.Wav) !Stream {
        const frame_size = w.frameSize();
        const bytes_per_second = frame_size * w.fmt.sample_rate;

        var stream = Stream{
            .alloc = alloc,
            .wav = w,
            .buffer = try alloc.alloc(u8, bytes_per_second * MAX_BUFFER_SECONDS),
            .rb = undefined,
            .live_buf = try alloc.alloc(u8, bytes_per_second * MAX_BUFFER_SECONDS),
        };

        stream.rb = RingBuffer(u8).init(stream.buffer);

        return stream;
    }

    pub fn read(self: *Stream, frames: usize) !pcm.Result {
        log.info("reading audio from stream", .{});
        const frame_size = self.wav.frameSize();
        const bytes_per_second = frame_size * self.wav.fmt.sample_rate;

        var frames_read: usize = 0;
        for (0..frames * frame_size) |i| {
            if (self.rb.next()) |byte| {
                self.live_buf[i] = byte;
            } else {
                frames_read = i / frame_size;
                break;
            }
        }

        const rb_len = self.rb.len();
        if (rb_len / bytes_per_second <= MIN_BUFFER_SECONDS) {
            var read_buf: [1024]u8 = undefined;
            var total_bytes_read: usize = 0;
            while (total_bytes_read < (MAX_BUFFER_SECONDS * bytes_per_second - frame_size * 10 - rb_len)) {
                const bytes_read = try self.wav.read(read_buf[0 .. 1024 / frame_size * frame_size]);
                total_bytes_read += bytes_read;
                for (read_buf) |byte| {
                    self.rb.push(byte);
                }

                if (bytes_read < read_buf.len) {
                    // reached end of file
                    self.eof = true;
                    break;
                }
            }
        }

        self.frames_read += frames_read;
        return pcm.Result{
            .data = self.live_buf[0 .. frames * frame_size],
            .frames_read = frames_read,
        };
    }

    pub fn getFormat(self: Stream) pcm.Format {
        return pcm.Format{
            .channels = self.wav.fmt.num_channels,
            .sample_rate = self.wav.fmt.sample_rate,
            .sample_fmt = switch (self.wav.fmt.bits_per_sample) {
                16 => .s16,
                24 => .s24,
                32 => .float32,
                else => @panic("invalid bit size for PCM data"),
            },
        };
    }

    pub fn seek(_: *Stream, _: usize) !void {
        log.info("seeking isn't supported yet for streams", .{});
    }

    pub fn getFrameOffset(self: Stream) usize {
        return self.frames_read;
    }

    pub fn getFrameLength(self: Stream) usize {
        return self.wav.data.size / self.wav.frameSize();
    }
};
