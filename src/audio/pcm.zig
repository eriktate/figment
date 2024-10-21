pub const SampleFmt = enum {
    s16,
    s24,
    float32,

    pub inline fn size(self: SampleFmt) u16 {
        return switch (self) {
            .s16 => 16,
            .s24 => 24,
            .float32 => 32,
        };
    }
};

pub const Result = struct {
    frames_read: usize,
    data: []u8,
};

pub const Format = struct {
    sample_fmt: SampleFmt,
    channels: u16,
    sample_rate: u32,

    pub inline fn frameSize(self: Format) usize {
        return self.channels * (self.sample_fmt.size() / 8);
    }
};

pub const Buffer = struct {
    fmt: Format,

    offset: usize,
    buf: []u8,

    pub fn read(self: *Buffer, frames: usize) Result {
        const frame_size = self.fmt.frameSize();
        var new_offset = self.offset + frames * frame_size;
        var data = Result{
            .frames_read = frames,
            .data = undefined,
        };

        if (new_offset > self.buf.len) {
            new_offset = self.buf.len;
            data.frames_read = (new_offset - self.offset) / frame_size;
        }

        data.data = self.buf[self.offset..new_offset];
        self.offset = new_offset;
        return data;
    }

    pub fn seek(self: *Buffer, frame_idx: usize) !void {
        const idx = frame_idx * self.fmt.frameSize();
        self.offset = idx;
    }

    pub fn getFrameOffset(self: Buffer) usize {
        return self.offset / self.fmt.frameSize();
    }

    pub fn getFrameLength(self: Buffer) usize {
        return self.buf.len / self.fmt.frameSize();
    }
};
