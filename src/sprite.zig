const render = @import("render/render.zig");

pub const Frame = struct {
    tex_pos: render.TexPos,
    w: u16,
    h: u16,
    duration: u32 = 1,
};

pub const Animation = struct {
    frames: []Frame,
    current_frame: f32,
    frame_rate: f32,

    fn getFrame(self: Animation) Frame {
        return self.frames[@intFromFloat(self.current_frame)];
    }

    fn tick(self: *Animation, dt: f32) void {
        self.current_frame += dt * self.frame_rate;

        const frame_idx: usize = @intFromFloat(self.current_frame);

        if (frame_idx > self.frames.len) {
            const new_base_frame: f32 = @floatFromInt(frame_idx % self.frames.len);
            const remainder: f32 = self.current_frame - frame_idx;

            self.current_frame = new_base_frame + remainder;
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
            .frame => null,
        }
    }
};
