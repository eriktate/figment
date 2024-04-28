const std = @import("std");
const render = @import("render/render.zig");
const c = @import("c.zig");
const cast = @import("cast.zig");

const STARTING_CHAR_IDX = ' ';
const ENDING_CHAR_IDX = '~' + 1; // have to add one because it's exclusive otherwise

const FontErr = error{
    LoadErr,
    InitErr,
    GlyphIdxErr,
    BitmapAllocErr,
};

fn stbttQuadToQuad(q: c.stbtt_aligned_quad) render.Quad {
    var quad = render.Quad.initCorners(render.Pos.init(q.x0, q.y0, 1), render.Pos.init(q.x1, q.y1, 1));
    quad.setTex(render.TexPos(q.s0, q.t0), render.TexPos(q.s1, q.t1));
    return quad;
}

pub const Font = struct {
    glyphs: [ENDING_CHAR_IDX - STARTING_CHAR_IDX]i32,
    quads: [ENDING_CHAR_IDX - STARTING_CHAR_IDX]render.Quad,
    font_atlas: []u8,
};

pub fn initAscii(alloc: std.mem.Allocator, font_path: []const u8, height: u32) FontErr!Font {
    var font_file = std.fs.cwd().openFile(font_path, .{ .mode = .read_only }) catch return FontErr.LoadErr;
    var buffer: [1024 * 1024 * 2]u8 = undefined;
    _ = font_file.readAll(buffer[0..]) catch return FontErr.LoadErr;

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

    std.log.info("ascent={d}, descent={d}", .{ ascent, descent });

    var font: Font = undefined;
    const bitmap_w = 1024;
    const bitmap_h = 1024;
    var bitmap = alloc.alloc(u8, bitmap_w * bitmap_h) catch return FontErr.BitmapAllocErr;
    for (bitmap, 0..) |_, idx| {
        bitmap[idx] = 0;
    }

    var x: i32 = 0;
    for (STARTING_CHAR_IDX..ENDING_CHAR_IDX) |i| {
        const idx = c.stbtt_FindGlyphIndex(&font_info, @intCast(i));
        if (idx == 0) {
            return FontErr.GlyphIdxErr;
        }

        font.glyphs[i - STARTING_CHAR_IDX] = idx;

        var char_width: i32 = 0; // total width of the character
        var lsb: i32 = 0; // offset from left "border" to start of character
        c.stbtt_GetGlyphHMetrics(&font_info, idx, &char_width, &lsb);

        var x1: i32 = 0;
        var x2: i32 = 0;
        var y1: i32 = 0;
        var y2: i32 = 0;
        c.stbtt_GetGlyphBitmapBox(&font_info, idx, scale, scale, &x1, &y1, &x2, &y2);

        const y = ascent + y1;
        const char: u8 = @intCast(i);
        std.log.info("'{c}' x1: {d}, x2: {d}, y1: {d}, y2: {d}", .{ char, x1, x2, y1, y2 });
        const offset: usize = @intCast(x + @as(i32, @intFromFloat(@as(f32, @floatFromInt(lsb)) * scale)) + y * bitmap_w);
        c.stbtt_MakeGlyphBitmap(&font_info, &bitmap[offset], x2 - x1, y2 - y1, bitmap_w, scale, scale, idx);
        x += @intFromFloat(@ceil(cast.mul(f32, char_width, scale)));
    }

    if (c.stbi_write_png("./font_atlas.png", bitmap_w, bitmap_h, 1, @ptrCast(bitmap.ptr), bitmap_w) == 0) {
        std.log.err("could not write atlas", .{});
    }

    return font;
}
