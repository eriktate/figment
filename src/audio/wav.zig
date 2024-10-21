const std = @import("std");
const io = std.io;
const pcm = @import("./pcm.zig");
const log = @import("../log.zig");

const WavErr = error{
    InvalidRIFF,
    InvalidFormat,
    InvalidFmt,
    InvalidData,
    UnexpectedReadCount,
};

const RiffDescriptor = struct {
    id: [4]u8,
    size: u32,
    format: [4]u8,
};

const FmtChunk = struct {
    id: [4]u8,
    size: u32,
    audio_format: u16,
    num_channels: u16,
    sample_rate: u32,
    byte_rate: u32,
    block_align: u16,
    bits_per_sample: u16,
};

const DataChunk = struct {
    id: [4]u8,
    size: usize,
};

pub const Wav = struct {
    descriptor: RiffDescriptor,
    fmt: FmtChunk,
    data: DataChunk,
    file: ?std.fs.File,
    stream: io.AnyReader,
    bytes_read: usize,

    pub fn read(self: Wav, out: []u8) !usize {
        return self.file.?.read(out);
    }

    pub fn getFormat(self: Wav) pcm.Format {
        return pcm.Format{
            .sample_fmt = switch (self.fmt.bits_per_sample) {
                16 => .s16,
                24 => .s24,
                32 => .float32,
                else => @panic("invalid sample format"),
            },
            .channels = self.fmt.num_channels,
            .sample_rate = self.fmt.sample_rate,
        };
    }

    pub fn toBuffer(self: Wav, alloc: std.mem.Allocator) !pcm.Buffer {
        std.debug.assert(self.bytes_read == 0);

        const buffer = pcm.Buffer{
            .fmt = self.getFormat(),
            .offset = 0,
            .buf = try alloc.alloc(u8, self.data.size),
        };

        var total_bytes_read: usize = 0;
        var stream = self.file.?.reader().any();

        while (true) {
            const bytes_read = try stream.read(buffer.buf[total_bytes_read..]);
            if (bytes_read == 0) {
                break;
            }
            total_bytes_read += bytes_read;
        }

        std.debug.assert(total_bytes_read == self.data.size);
        return buffer;
    }

    pub fn frameSize(self: Wav) usize {
        return @intCast(self.fmt.num_channels * self.fmt.bits_per_sample / 8);
    }
};

fn readLE(T: type, stream: io.AnyReader) !T {
    var buf = std.mem.zeroes([@sizeOf(T)]u8);
    const bytes_read = try stream.read(&buf);
    if (bytes_read != buf.len) {
        return WavErr.UnexpectedReadCount;
    }

    return std.mem.readInt(T, @constCast(&buf), .little);
}

fn readBE(T: type, stream: io.AnyReader) !T {
    var buf = std.mem.zeroes([@sizeOf(T)]u8);
    const bytes_read = try stream.read(&buf);
    if (bytes_read != buf.len) {
        return WavErr.UnexpectedReadCount;
    }

    return std.mem.readInt(T, @constCast(&buf), .big);
}

fn parseRIFF(stream: io.AnyReader) !RiffDescriptor {
    var descriptor: RiffDescriptor = undefined;
    _ = try stream.read(&descriptor.id);
    if (!std.mem.eql(u8, &descriptor.id, "RIFF")) {
        return WavErr.InvalidRIFF;
    }

    descriptor.size = try readLE(u32, stream);
    _ = try stream.read(&descriptor.format);

    if (!std.mem.eql(u8, &descriptor.format, "WAVE")) {
        return WavErr.InvalidFormat;
    }

    return descriptor;
}

fn parseFmt(stream: io.AnyReader) !FmtChunk {
    var fmt: FmtChunk = undefined;
    _ = try stream.read(&fmt.id);
    if (!std.mem.eql(u8, &fmt.id, "fmt ")) {
        return WavErr.InvalidFmt;
    }

    fmt.size = try readLE(u32, stream);
    fmt.audio_format = try readLE(u16, stream);
    fmt.num_channels = try readLE(u16, stream);
    fmt.sample_rate = try readLE(u32, stream);
    fmt.byte_rate = try readLE(u32, stream);
    fmt.block_align = try readLE(u16, stream);
    fmt.bits_per_sample = try readLE(u16, stream);

    return fmt;
}

fn parseData(stream: io.AnyReader) !DataChunk {
    var data: DataChunk = undefined;
    _ = try stream.read(&data.id);
    if (!std.mem.eql(u8, &data.id, "data")) {
        return WavErr.InvalidData;
    }

    data.size = try readLE(u32, stream);

    return data;
}

pub fn parseWav(stream: io.AnyReader) !Wav {
    return Wav{
        .descriptor = try parseRIFF(stream),
        .fmt = try parseFmt(stream),
        .data = try parseData(stream),
        .bytes_read = 0,
        .file = null,
        .stream = stream,
    };
}

pub fn loadFromFile(path: []const u8) !Wav {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });

    const stream = file.reader().any();
    var wav = try parseWav(stream);
    wav.file = file;
    log.info("loading wav {s} channels={d} sample_rate={d} bits_per_sample={d}", .{ path, wav.fmt.num_channels, wav.fmt.sample_rate, wav.fmt.bits_per_sample });
    return wav;
}

test "parse wav file" {
    const t = std.testing;

    const wav = try loadFromFile("./assets/sounds/bark.wav");
    std.debug.print("{any}", .{wav});

    try t.expect(std.mem.eql(u8, &wav.descriptor.id, "RIFF"));
}
