const c = @import("c");
const wav = @import("./wav.zig");
const pcm = @import("./pcm.zig");
const stream = @import("./stream.zig");

pub const SourceKind = enum {
    buffer,
    stream,
    empty,
};

pub const Source = union(SourceKind) {
    buffer: pcm.Buffer,
    stream: stream.Stream,
    empty: void,

    pub fn read(self: *Source, frames: usize) !pcm.Result {
        return switch (self.*) {
            .buffer => |*buffer| buffer.read(frames),
            .stream => |*strm| try strm.read(frames),
            .empty => pcm.Result{ .frames_read = 0, .data = undefined },
        };
    }

    pub fn seek(self: *Source, frame_idx: usize) !void {
        return switch (self.*) {
            .buffer => |*buffer| buffer.seek(frame_idx),
            .stream => |*strm| strm.seek(frame_idx),
            .empty => {},
        };
    }

    pub fn getDataFormat(self: *Source) !pcm.Format {
        return switch (self.*) {
            .buffer => |buffer| buffer.fmt,
            .stream => |strm| strm.getFormat(),
            // TODO (soggy): figure out something better for this
            .empty => pcm.Format{
                .channels = 2,
                .sample_fmt = .s16,
                .sample_rate = 22050,
            },
        };
    }

    pub fn getCursor(self: *Source) !usize {
        return switch (self.*) {
            .buffer => |buffer| buffer.getFrameOffset(),
            .stream => |strm| strm.getFrameOffset(),
            .empty => 0,
        };
    }

    pub fn getLength(self: *Source) !usize {
        return switch (self.*) {
            .buffer => |buffer| buffer.getFrameLength(),
            .stream => |strm| strm.getFrameLength(),
            .empty => 0,
        };
    }

    pub fn deinit(_: *Source) void {
        return;
    }
};
