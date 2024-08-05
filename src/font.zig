const std = @import("std");
const render = @import("render.zig");
const c = @import("c.zig");
const cast = @import("cast.zig");
const log = @import("log.zig");
const dim = @import("dim.zig");

const STARTING_CHAR_IDX = ' ';
const ENDING_CHAR_IDX = '~' + 1; // have to add one because it's exclusive otherwise

const FontErr = error{
    LoadErr,
    InitErr,
    GlyphNotFound,
    BitmapAllocErr,
};

fn stbttQuadToQuad(q: c.stbtt_aligned_quad) render.Quad {
    var quad = render.Quad.initCorners(render.Pos.init(q.x0, q.y0, 1), render.Pos.init(q.x1, q.y1, 1));
    quad.setTex(render.TexPos(q.s0, q.t0), render.TexPos(q.s1, q.t1));
    return quad;
}

pub const Font = struct {
    height: u16,
    ascent: u32,
    line_gap: u32,

    glyphs: [ENDING_CHAR_IDX - STARTING_CHAR_IDX]Glyph,
    quads: [ENDING_CHAR_IDX - STARTING_CHAR_IDX]render.Quad,
    font_atlas: []u8,

    pub fn getAtlasDimensions(self: Font) render.TexPos {
        var width = 0;
        for (self.glyphs) |glyph| {
            width += glyph.width;
        }

        return render.TexPos.init(width, self.height);
    }
};

pub fn initAscii(alloc: std.mem.Allocator, font_path: []const u8, height: usize) FontErr!Font {
    log.info("begin loading font '{s}'", .{font_path});
    var font_file = std.fs.cwd().openFile(font_path, .{ .mode = .read_only }) catch return FontErr.LoadErr;
    var buffer: [1024 * 1024 * 2]u8 = undefined;
    _ = font_file.readAll(buffer[0..]) catch return FontErr.LoadErr;

    log.info("initializing font", .{});
    var font_info: c.stbtt_fontinfo = undefined;
    if (c.stbtt_InitFont(&font_info, &buffer, 0) == 0) {
        return FontErr.InitErr;
    }

    const scale = c.stbtt_ScaleForPixelHeight(&font_info, @floatFromInt(height));
    var ascent: i32 = 0;
    var descent: i32 = 0;
    var line_gap: i32 = 0;

    c.stbtt_GetFontVMetrics(&font_info, &ascent, &descent, &line_gap);

    ascent = @intFromFloat(@ceil(cast.mul(f32, ascent, scale)));
    descent = cast.mul(i32, descent, scale);

    var font: Font = undefined;
    const bitmap_w: usize = (ENDING_CHAR_IDX - STARTING_CHAR_IDX) * (height / 2);
    const bitmap_h = height;
    var bitmap = alloc.alloc(u8, bitmap_w * bitmap_h) catch return FontErr.BitmapAllocErr;
    for (bitmap, 0..) |_, idx| {
        bitmap[idx] = 0;
    }

    log.info("start glyph generation", .{});
    var x: usize = 0;
    for (STARTING_CHAR_IDX..ENDING_CHAR_IDX) |i| {
        const glyph = try Glyph.init(&font_info, ascent, scale, @intCast(i));
        font.glyphs[i - STARTING_CHAR_IDX] = glyph;

        // std.log.info("'{c}' x: {d}, y: {d}, w: {d}, h: {d}", .{ char, glyph.x, glyph.y, glyph.w, glyph.h });
        const offset: usize = @intCast(x + glyph.lsb + (glyph.y * bitmap_w));
        c.stbtt_MakeGlyphBitmap(&font_info, &bitmap[offset], @intCast(glyph.w), @intCast(glyph.h), @intCast(bitmap_w), scale, scale, glyph.id);
        x += glyph.width;
    }
    log.info("glyph generation done!", .{});

    var rgba_bitmap = alloc.alloc(render.Color, bitmap.len) catch return FontErr.BitmapAllocErr;
    for (bitmap, 0..) |pixel, i| {
        rgba_bitmap[i] = render.Color.init(0, 0, 0, pixel);
    }

    log.info("writing font atlas", .{});
    if (c.stbi_write_png("./font_atlas.png", @intCast(bitmap_w), @intCast(bitmap_h), 4, @ptrCast(rgba_bitmap.ptr), @intCast(bitmap_w * @sizeOf(render.Color))) == 0) {
        std.log.err("could not write atlas", .{});
    }

    log.info("done writing font atlas! bitmap size: {d}", .{@sizeOf(@TypeOf(bitmap)) * bitmap.len});

    return font;
}

pub const Glyph = struct {
    id: i32,
    width: usize,
    lsb: usize,

    // bounding box
    x: usize,
    y: usize,
    w: usize,
    h: usize,

    fn init(font_info: *c.stbtt_fontinfo, ascent: i32, scale: f32, char: u8) !Glyph {
        const idx = c.stbtt_FindGlyphIndex(font_info, char);
        if (idx == 0) {
            return FontErr.GlyphNotFound;
        }

        var width: i32 = 0;
        var lsb: i32 = 0;

        c.stbtt_GetGlyphHMetrics(font_info, idx, &width, &lsb);

        var x1: i32 = 0;
        var x2: i32 = 0;
        var y1: i32 = 0;
        var y2: i32 = 0;
        c.stbtt_GetGlyphBitmapBox(font_info, idx, scale, scale, &x1, &y1, &x2, &y2);

        // std.log.info("'{c}' width: {d}, x1: {d}, y1: {d}, x2: {d}, y2: {d}", .{ char, cast.mul(usize, width, scale), x1, y1, x2, y2 });
        return Glyph{
            .id = idx,
            .width = @intFromFloat(@ceil(cast.mul(f32, width, scale))),
            .lsb = cast.mul(usize, lsb, scale),
            .x = 0,
            .y = @intCast(ascent + y1),
            .w = @intCast(x2 - x1),
            .h = @intCast(y2 - y1),
        };
    }

    pub fn toQuad(self: Glyph) render.Quad {
        const pos = render.Pos.init(@floatFromInt(self.x), @floatFromInt(self.y), 1);

        var quad = render.Quad.init(pos, @floatFromInt(self.w), @floatFromInt(self.h));
        quad.setTex(render.TexPos(@intCast(self.x), @intCast(self.y), @intCast(self.x + self.w), @intCast(self.y + self.h)));

        return quad;
    }
};
