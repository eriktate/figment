const std = @import("std");
const render = @import("render.zig");
const c = @import("c");
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
    info: c.stbtt_fontinfo,
    height: u16,
    ascent: u32,
    line_gap: u32,

    glyphs: [ENDING_CHAR_IDX - STARTING_CHAR_IDX]Glyph,
    quads: [ENDING_CHAR_IDX - STARTING_CHAR_IDX]render.Quad,

    font_atlas: []render.Color,
    atlas_w: usize,
    atlas_h: usize,

    pub fn getAtlasDimensions(self: Font) render.TexPos {
        var width = 0;
        for (self.glyphs) |glyph| {
            width += glyph.width;
        }

        return render.TexPos.init(width, self.height);
    }

    /// Generate quads representing the given string at the given position. Single line only for now.
    pub fn drawText(self: Font, pos: render.Pos, text: []const u8, out: *std.ArrayList(render.Quad)) !void {
        // var offset: c_int = 0;
        var offset: usize = 0;

        for (text) |char| {
            if (char == ' ') {
                offset += 4;
            }

            const glyph = self.glyphs[char - STARTING_CHAR_IDX];
            var quad = self.quads[char - STARTING_CHAR_IDX];
            // const advance = c.stbtt_GetGlyphKernAdvance(&self.info, prev_char, char);
            quad.setPos(pos.add(.{ .x = @floatFromInt(offset), .y = @floatFromInt(glyph.y) }));
            quad.setTexID(.font);
            offset += @intFromFloat(quad.br.pos.x - quad.tl.pos.x + 1);
            // log.info("appending char '{c}' tl=({d}, {d}) br=({d}, {d})", .{ char, quad.tl.tex_pos.x, quad.tl.tex_pos.y, quad.br.tex_pos.x, quad.br.tex_pos.y });
            try out.append(quad);
        }
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
    for (STARTING_CHAR_IDX..ENDING_CHAR_IDX) |char| {
        const glyph = try Glyph.init(&font_info, ascent, scale, @intCast(char));
        font.glyphs[char - STARTING_CHAR_IDX] = glyph;

        // std.log.info("'{c}' x: {d}, y: {d}, w: {d}, h: {d}", .{ char, glyph.x, glyph.y, glyph.w, glyph.h });
        const offset: usize = @intCast(x + glyph.lsb + (glyph.y * bitmap_w));
        c.stbtt_MakeGlyphBitmap(&font_info, &bitmap[offset], @intCast(glyph.w), @intCast(glyph.h), @intCast(bitmap_w), scale, scale, glyph.id);
        var quad = render.Quad.init(
            .{},
            @floatFromInt(glyph.w),
            @floatFromInt(glyph.h),
        );
        quad.setTex(
            .{ .x = @intCast(x + glyph.lsb), .y = @intCast(glyph.y) },
            .{ .x = @intCast(x + glyph.lsb + glyph.w), .y = @intCast(glyph.y + glyph.h) },
        );

        font.quads[char - STARTING_CHAR_IDX] = quad;
        x += glyph.width;
    }
    log.info("glyph generation done!", .{});

    var rgba_bitmap = alloc.alloc(render.Color, bitmap.len) catch return FontErr.BitmapAllocErr;
    for (bitmap, 0..) |pixel, i| {
        rgba_bitmap[i] = render.Color.init(255, 255, 255, pixel);
    }

    log.info("writing font atlas", .{});
    if (c.stbi_write_png("./font_atlas.png", @intCast(bitmap_w), @intCast(bitmap_h), 4, @ptrCast(rgba_bitmap.ptr), @intCast(bitmap_w * @sizeOf(render.Color))) == 0) {
        std.log.err("could not write atlas", .{});
    }

    log.info("done writing font atlas! bitmap size: {d}", .{@sizeOf(@TypeOf(bitmap)) * bitmap.len});

    font.info = font_info;
    font.font_atlas = rgba_bitmap;
    font.atlas_w = bitmap_w;
    font.atlas_h = bitmap_h;
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
