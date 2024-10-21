const std = @import("std");
const log = @import("../log.zig");
const wav = @import("./wav.zig");
const pcm = @import("./pcm.zig");

// TODO (soggy): need to figure out if this is enough buffer to keep audio smooth even on disk drives
const BUFFER_SECONDS = 2;

// TODO (soggy): it would be nice to eventually do the file streaming on a separate thread, but for now this seems to work well enough
pub const Stream = struct {
    alloc: std.mem.Allocator,
    buf1: []u8,
    buf2: []u8,
    active_buf: []u8,
    back_buf: []u8,
    window: []u8,
    next_buf: []u8,
    wav: wav.Wav,

    frames_read: usize = 0,
    should_swap: bool = false,
    eof: bool = false,
    loop: bool = false,

    // TODO (soggy): because we init on an existing wav file, Streams as a source can only be played one at time. If we accept a path
    // during initialization and add a way of duplicating the Stream such that each instance gets its own file handle, we should be
    // able to play multiple instances of the same file
    pub fn init(alloc: std.mem.Allocator, w: wav.Wav) !Stream {
        const frame_size = w.frameSize();
        const bytes_per_second = frame_size * w.fmt.sample_rate;

        var stream = Stream{
            .alloc = alloc,
            .wav = w,
            .buf1 = try alloc.alloc(u8, bytes_per_second * BUFFER_SECONDS),
            .buf2 = try alloc.alloc(u8, bytes_per_second * BUFFER_SECONDS),
            .active_buf = undefined,
            .back_buf = undefined,
            .window = undefined,
            .next_buf = undefined,
        };

        stream.active_buf = stream.buf1;
        stream.back_buf = stream.buf2;
        stream.next_buf = stream.buf1[0..];

        // prefetch both buffers
        var bytes_read = try w.read(stream.buf1);
        if (bytes_read < stream.buf1.len) {
            stream.eof = true;
        }

        bytes_read = try w.read(stream.buf2);
        if (bytes_read < stream.buf2.len) {
            stream.eof = true;
        }

        return stream;
    }

    pub fn read(self: *Stream, frames: usize) !pcm.Result {
        const fmt = self.wav.getFormat();
        const frame_size = fmt.frameSize();
        self.window = self.next_buf;

        if (self.should_swap) {
            log.info("swapping buffers and streaming file", .{});
            const bytes_read = try self.wav.read(self.active_buf);
            if (bytes_read < self.active_buf.len) {
                self.eof = true;
            }

            const active_buf = self.active_buf;
            self.active_buf = self.back_buf;
            self.back_buf = active_buf;
            self.should_swap = false;
            log.info("done swapping", .{});
        }

        const bytes_to_read = frames * frame_size;
        if (self.window.len >= bytes_to_read) {
            self.next_buf = self.window[bytes_to_read..];
        } else {
            // if there isn't enough data to satisfy the frames requested, we can shift everything to the
            // beginning of the buffer and load from the beginning of the double buffer
            const bytes_short = bytes_to_read - self.window.len;
            @memcpy(self.active_buf[0..self.window.len], self.window);
            @memcpy(self.active_buf[self.window.len..bytes_to_read], self.back_buf[0..bytes_short]);
            self.next_buf = self.back_buf[bytes_short..];
            self.window = self.active_buf[0..bytes_to_read];
            self.should_swap = true;
        }

        return pcm.Result{
            .data = self.window[0..bytes_to_read],
            .frames_read = frames,
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
