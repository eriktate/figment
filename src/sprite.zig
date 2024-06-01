const std = @import("std");
const render = @import("render/render.zig");

pub const Frame = struct {
    tex_pos: render.TexPos,
    w: u16,
    h: u16,
    duration: u16 = 16, // in ms
};

pub const Animation = struct {
    frames: []const Frame,
    current_frame: f32,
    frame_rate: f32,

    pub fn init(frames: []const Frame) Animation {
        return .{
            .frames = frames,
            .current_frame = 0,
            .frame_rate = 1,
        };
    }

    fn getFrame(self: Animation) Frame {
        const idx: usize = @intFromFloat(self.current_frame);
        return self.frames[idx % self.frames.len];
    }

    fn tick(self: *Animation, dt: f32) void {
        const frame_idx: usize = @intFromFloat(self.current_frame);
        const frame = self.frames[frame_idx];
        const dur: f32 = @floatFromInt(frame.duration);
        self.current_frame += dt * self.frame_rate / (dur / 1000);

        const frame_len: f32 = @floatFromInt(self.frames.len);
        if (self.current_frame >= frame_len) {
            self.current_frame = @mod(self.current_frame, frame_len);
        }
    }
};

pub const SourceType = enum {
    frame,
    animation,
};

pub const Source = union(SourceType) {
    frame: Frame,
    animation: Animation,
};

pub const Sprite = struct {
    pos: render.Pos,
    width: u32,
    height: u32,
    source: Source,

    pub fn getFrame(self: Sprite) Frame {
        return switch (self.source) {
            .frame => |frame| frame,
            .animation => |anim| anim.getFrame(),
        };
    }

    pub fn toQuad(self: Sprite) render.Quad {
        const frame = self.getFrame();
        const w: f32 = @floatFromInt(self.width);
        const h: f32 = @floatFromInt(self.height);
        const tex_tl = frame.tex_pos;
        const tex_br = frame.tex_pos.add(render.TexPos.init(frame.w, frame.h));

        return render.Quad.init(self.pos, w, h).withTex(tex_tl, tex_br);
    }

    pub fn tick(self: *Sprite, dt: f32) void {
        switch (self.source) {
            .animation => |*anim| anim.tick(dt),
            .frame => {},
        }
    }

    pub fn setAnimation(self: *Sprite, frames: []const Frame) void {
        self.source = makeAnimation(frames);
    }

    pub fn setFrameRate(self: *Sprite, frame_rate: f32) void {
        switch (self.source) {
            .animation => self.source.animation.frame_rate = frame_rate,
            .frame => {},
        }
    }
};

pub fn makeAnimation(frames: []const Frame) Source {
    return .{ .animation = Animation.init(frames) };
}
