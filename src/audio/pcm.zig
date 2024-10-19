pub const SampleDepth = enum {
    s16,
    s24,
    float32,

    pub inline fn size(self: SampleDepth) u16 {
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
    depth: SampleDepth,
    channels: u16,
    sample_rate: u32,
};

pub const Buffer = struct {
    fmt: Format,

    offset: usize,
    buf: []u8,

    pub fn read(self: *Buffer, frames: usize) Result {
        const sample_len = self.sampleSize();
        var new_offset = self.offset + frames * sample_len;
        var data = Result{
            .frames_read = frames,
            .data = undefined,
        };

        if (new_offset > self.buf.len) {
            new_offset = self.buf.len;
            data.frames_read = (new_offset - self.offset) / sample_len;
        }

        data.data = self.buf[self.offset..new_offset];
        self.offset = new_offset;
        return data;
    }

    pub fn seek(self: *Buffer, frame_idx: usize) !void {
        const idx = frame_idx * self.sampleSize();
        self.offset = idx;
    }

    pub inline fn sampleSize(self: Buffer) usize {
        return self.fmt.channels * (self.fmt.depth.size() / 8);
    }

    pub fn getFrameOffset(self: Buffer) usize {
        return self.offset * self.sampleSize();
    }

    pub fn getFrameLength(self: Buffer) usize {
        return self.buf.len / self.sampleSize();
    }
};
