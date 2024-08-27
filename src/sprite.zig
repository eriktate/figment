//! Implements sprites as a fundamental primitive for drawing 2D images to the screen. This allows game logic to be
//! written in terms of sprites, frames, and animations rather than textures, regions, and quads.

const std = @import("std");
const render = @import("render.zig");
const dim = @import("dim.zig");

/// Represents a region within a texture to be rendered. The optional `duration` field is only used when the playing
/// an `Animation`. When rendering a static sprite, a single `Frame` is used.
pub const Frame = struct {
    tex_pos: render.TexPos,
    w: u16,
    h: u16,
    duration: u16 = 16, // in ms
};

/// Self-contained animation state. The `frames` slice is _not_ expected to be owned by the `Animation`. The
/// `frame_rate` field is a multiplier over the `duration` defined for each `Frame`. Which means a `Frame`
/// with a default duration of `16` within an `Animation` with `frame_rate` of 2 will be displayed for approximately
/// 8ms.
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
    none,
};

pub const Source = union(SourceType) {
    frame: Frame,
    animation: Animation,
    none: void,
};

/// Fundamental 2D rendering primitive. The `pos`, `width`, and `height` determine the exact area the sprite should be
/// rendered in pixels. The dimensions of the underlying `source` will be scaled to the `width` and `height` of the
/// `Sprite`.
pub const Sprite = struct {
    pos: render.Pos = render.Pos.zero(),
    width: f32 = 0,
    height: f32 = 0,
    h_flip: bool = false,
    v_flip: bool = false,
    source: Source = .{ .none = {} },

    pub fn getFrame(self: Sprite) ?Frame {
        return switch (self.source) {
            .frame => |frame| frame,
            .animation => |anim| anim.getFrame(),
            .none => null,
        };
    }

    pub fn toQuad(self: Sprite, offset: render.Pos) ?render.Quad {
        const frame = self.getFrame() orelse return null;
        const w: f32 = self.width;
        const h: f32 = self.height;
        var tex_tl = frame.tex_pos;
        var tex_br = frame.tex_pos.add(render.TexPos.init(frame.w, frame.h));

        if (self.h_flip) {
            tex_tl.x = tex_br.x;
            tex_br.x = frame.tex_pos.x;
        }

        return render.Quad.init(self.pos.add(offset), w, h).withTex(tex_tl, tex_br);
    }

    /// Mostly a proxy for calling `anim.tick()` in the case of an animated `Sprite`, which handles all of the
    /// necessary mutations required for cycling through frames given an elapsed frame delta of `dt`.
    pub fn tick(self: *Sprite, dt: f32) void {
        switch (self.source) {
            .animation => |*anim| anim.tick(dt),
            else => {},
        }
    }

    /// Sets the source of the `Sprite` to a new `Animation` tracking against the given `frames`.
    pub fn setAnimation(self: *Sprite, frames: []const Frame) void {
        switch (self.source) {
            .animation => |anim| {
                if (anim.frames.ptr == frames.ptr and anim.frames.len == frames.len) {
                    return;
                }
                self.source = makeAnimation(frames);
            },
            else => self.source = makeAnimation(frames),
        }
    }

    /// Set the source of the `Sprite` to the given `Frame`.
    pub fn setFrame(self: *Sprite, frame: Frame) void {
        self.source = .{ .frame = frame };
    }

    /// For static/frame sprites, this is a no-op. For animations, adjusts the `frame_rate` multiplier.
    pub fn setFrameRate(self: *Sprite, frame_rate: f32) void {
        switch (self.source) {
            .animation => self.source.animation.frame_rate = frame_rate,
            else => {},
        }
    }

    pub fn setScale(self: *Sprite, scale: dim.Vec2(f32)) void {
        self.pos = self.pos.mul(render.Pos.init(scale.x, scale.y, 1));
        self.width *= scale.x;
        self.height *= scale.y;
    }
};

pub inline fn makeAnimation(frames: []const Frame) Source {
    return .{ .animation = Animation.init(frames) };
}
