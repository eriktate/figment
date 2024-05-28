const dim = @import("../dim.zig");

pub const Pos = dim.Vec3(f32);
pub const TexPos = dim.Vec2(u16);
pub const Color = dim.Vec4(u8);

pub const Vertex = extern struct {
    pos: Pos = Pos.zero(),
    tex_pos: TexPos = TexPos.zero(),
    // default color of white so that we can actually see things
    color: Color = .{ .x = 255, .y = 255, .z = 255, .w = 255 },
};

pub const Quad = extern struct {
    tl: Vertex,
    tr: Vertex,
    bl: Vertex,
    br: Vertex,

    pub fn init(pos: Pos, width: f32, height: f32) Quad {
        return .{
            .tl = Vertex{ .pos = pos },
            .tr = Vertex{ .pos = pos.add(.{ .x = width }) },
            .bl = Vertex{ .pos = pos.add(.{ .y = height }) },
            .br = Vertex{ .pos = pos.add(.{ .x = width, .y = height }) },
        };
    }

    pub fn initCorners(tl: Pos, br: Pos) Quad {
        return .{
            .tl = Vertex{ .pos = tl },
            .tr = Vertex{ .pos = tl.add(.{ .x = br.x }) },
            .bl = Vertex{ .pos = tl.add(.{ .y = br.y }) },
            .br = Vertex{ .pos = br },
        };
    }

    pub fn setTex(self: *Quad, tl: TexPos, br: TexPos) void {
        self.tl.tex_pos = tl;
        self.tr.tex_pos = .{ .x = br.x, .y = tl.y };
        self.bl.tex_pos = .{ .x = tl.x, .y = br.y };
        self.br.tex_pos = br;
    }

    pub fn withTex(self: Quad, tl: TexPos, br: TexPos) Quad {
        var quad = self;
        quad.setTex(tl, br);
        return quad;
    }

    pub fn setColor(self: *Quad, color: Color) void {
        self.tl.color = color;
        self.tr.color = color;
        self.bl.color = color;
        self.br.color = color;
    }

    pub fn withColor(self: Quad, color: Color) Quad {
        var quad = self;
        quad.setColor(color);
        return quad;
    }

    pub fn translate(self: *Quad, pos: Pos) void {
        self.tl.pos.addMut(pos);
        self.tr.pos.addMut(pos);
        self.bl.pos.addMut(pos);
        self.br.pos.addMut(pos);
    }

    pub fn setPos(self: *Quad, pos: Pos) void {
        const diff = pos.sub(self.tl.pos);
        self.translate(diff);
    }
};
