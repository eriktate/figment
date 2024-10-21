const c = @import("c");
const wav = @import("./wav.zig");
const pcm = @import("./pcm.zig");

pub const SourceKind = enum {
    buffer,
    empty,
};

pub const Source = union(SourceKind) {
    buffer: pcm.Buffer,
    empty: void,

    pub fn read(self: *Source, frames: usize) !pcm.Result {
        switch (self.*) {
            .buffer => |*buffer| {
                const result = buffer.read(frames);
                return result;
            },
            .empty => {
                return pcm.Result{ .frames_read = 0, .data = undefined };
            },
        }
    }

    pub fn seek(self: *Source, frame_idx: usize) !void {
        switch (self.*) {
            .buffer => |*buffer| {
                return buffer.seek(frame_idx);
            },
            .empty => return,
        }
    }

    pub fn getDataFormat(self: *Source) !pcm.Format {
        return switch (self.*) {
            .buffer => |buffer| buffer.fmt,
            // TODO (soggy): figure out something better for this
            .empty => pcm.Format{
                .channels = 2,
                .sample_fmt = .s16,
                .sample_rate = 22050,
            },
        };
    }

    pub fn getCursor(self: *Source) !usize {
        switch (self.*) {
            .buffer => |buffer| {
                return buffer.getFrameOffset();
            },
            .empty => return 0,
        }
    }

    pub fn getLength(self: *Source) !usize {
        switch (self.*) {
            .buffer => |buffer| {
                return buffer.getFrameLength();
            },
            .empty => return 0,
        }
    }

    pub fn deinit(_: *Source) void {
        return;
    }
};
