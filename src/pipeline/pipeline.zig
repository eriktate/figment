const std = @import("std");
const c = @import("c");
const fmt = std.fmt;
const sprite = @import("../sprite.zig");
const render = @import("../render.zig");
const ase = @import("../ase.zig");
const strings = @import("../strings.zig");
const log = @import("../log.zig");
const dim = @import("../dim.zig");

const INITIAL_ANIM_CAP = 512;
const BITMAP_WIDTH = 2048;
const BITMAP_HEIGHT = 2048;
const PADDING = 1;

const GEN_FINAL_PATH = "./src/gen.zig";
const GEN_OUTPUT_PATH = GEN_FINAL_PATH ++ ".tmp";
const HEADER = "// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten\n\nconst std = @import(\"std\");\nconst sprite = @import(\"sprite.zig\");\nconst render = @import(\"render.zig\");\n\n";

pub const Animation = struct {
    name: []u8,
    frames: []sprite.Frame,
};

pub const Frame = struct {
    name: []u8,
    frame: sprite.Frame,
};

const Area = struct {
    pos: dim.Vec2(u16),
    w: u16,
    h: u16,
};

pub const Context = struct {
    alloc: std.mem.Allocator,
    animations: std.ArrayList(Animation),
    frames: std.ArrayList(Frame),
    bitmap_w: usize,
    bitmap_h: usize,
    bitmap: []ase.RGBA,
    file: std.fs.File,
    offset: usize,
    padding: usize,

    pub fn init(alloc: std.mem.Allocator) !Context {
        return Context{
            .alloc = alloc,
            .animations = try std.ArrayList(Animation).initCapacity(alloc, INITIAL_ANIM_CAP),
            .frames = try std.ArrayList(Frame).initCapacity(alloc, INITIAL_ANIM_CAP),
            .bitmap = undefined,
            .bitmap_w = 0,
            .bitmap_h = 0,
            .padding = PADDING,
            .offset = (PADDING * BITMAP_WIDTH) + PADDING,
            .file = try initFile(GEN_OUTPUT_PATH),
        };
    }

    pub fn deinit(ctx: Context) void {
        ctx.file.close();
        ctx.animations.deinit();
        ctx.alloc.free(ctx.bitmap);
    }
};

pub fn initFile(path: []const u8) !std.fs.File {
    var file = try std.fs.cwd().createFile(path, .{});
    errdefer file.close();

    _ = try file.write(HEADER);

    return file;
}

pub fn processFolder(ctx: *Context, path: []const u8) !void {
    const dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(ctx.alloc);
    while (try walker.next()) |entry| {
        log.info("processing '{s}'", .{entry.path});
        if (strings.hasSuffix(".ase", entry.path) or strings.hasSuffix(".aseprite", entry.path)) {
            var path_buf: [1024]u8 = undefined;
            const real_path = try dir.realpath(entry.path, &path_buf);
            try processAseFile(ctx, real_path);
        }
    }
}

const NamedHeader = struct {
    name: []const u8,
    path: []const u8,
    header: ase.Header,
};

fn collectSortedAseHeaders(ctx: *Context, path: []const u8) !std.ArrayList(NamedHeader) {
    var headers = std.ArrayList(NamedHeader).init(ctx.alloc);
    const dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(ctx.alloc);
    while (try walker.next()) |entry| {
        if (strings.hasSuffix(".ase", entry.path) or strings.hasSuffix(".aseprite", entry.path)) {
            var path_buf: [1024]u8 = undefined;
            const real_path = try dir.realpath(entry.path, &path_buf);
            const file_name = strings.stripSuffix(".aseprite", strings.stripSuffix(".ase", try strings.splitLast(entry.path, "/")));

            var new_header = NamedHeader{ .name = try strings.copy(ctx.alloc, file_name), .path = try strings.copy(ctx.alloc, real_path), .header = try ase.Header.fromFile(real_path) };
            // const new_area = @as(usize, @intCast(new_header.header.width)) * @as(usize, @intCast(new_header.header.height)) * @as(usize, @intCast(new_header.header.frames));
            const new_area = @as(usize, @intCast(new_header.header.width)) * @as(usize, @intCast(new_header.header.height));
            var inserted = false;

            // insertion sort
            for (headers.items, 0..) |header, idx| {
                // const existing_area = @as(usize, @intCast(header.header.width)) * @as(usize, @intCast(header.header.height)) * @as(usize, @intCast(header.header.frames));
                const existing_area = @as(usize, @intCast(header.header.width)) * @as(usize, @intCast(header.header.height));

                if (existing_area < new_area) {
                    inserted = true;
                    for (headers.items[idx..], idx..) |hd, i| {
                        headers.items[i] = new_header;
                        new_header = hd;
                    }
                    try headers.append(new_header);
                    break;
                }
            }

            if (!inserted) {
                try headers.append(new_header);
            }
        }
    }

    return headers;
}

fn canFit(ctx: Context, width: usize, height: usize, idx: usize, bitmap: []?ase.RGBA) bool {
    const w = width + (ctx.padding * 2);
    const h = height + (ctx.padding * 2);

    // bounds checking
    if ((idx % ctx.bitmap_w) + w > ctx.bitmap_w) {
        return false;
    }

    if ((idx / ctx.bitmap_w) + h > ctx.bitmap_h) {
        return false;
    }

    // looking for empty slot
    for (0..h) |y| {
        for (0..w) |x| {
            const offset = idx + (y * ctx.bitmap_w) + x;
            if (offset > bitmap.len) {
                return false;
            }

            if (bitmap[offset] != null) {
                return false;
            }
        }
    }

    return true;
}

fn packTexture(ctx: *Context, headers: []NamedHeader) !void {
    // width is the larger of the widest individual texture and the computed side length of the square containing the entire area of all textures
    var total_area: usize = 0;
    for (headers) |header| {
        if (@as(usize, @intCast(header.header.width)) > ctx.bitmap_w) {
            ctx.bitmap_w = @intCast(header.header.width);
        }

        total_area += @as(usize, @intCast(header.header.width)) * @as(usize, @intCast(header.header.height)) * @as(usize, @intCast(header.header.frames));
    }

    const computed_width: usize = @intFromFloat(@ceil(@sqrt(@as(f32, @floatFromInt(total_area)))) * 1.2);
    if (computed_width > ctx.bitmap_w) {
        ctx.bitmap_w = computed_width;
    }

    ctx.bitmap_h = ctx.bitmap_w;
    log.info("bitmap_w = {d}, bitmap_h = {d}, total_area = {d}", .{ ctx.bitmap_w, ctx.bitmap_h, total_area });
    const bitmap = try ctx.alloc.alloc(?ase.RGBA, ctx.bitmap_w * ctx.bitmap_h);
    for (bitmap, 0..) |_, idx| {
        bitmap[idx] = null;
    }

    for (headers) |header| {
        try processNamedHeader(ctx, header, bitmap);
    }

    const rows = getTrimmableRows(ctx.*, bitmap);
    const trimmed_bitmap = bitmap[0 .. bitmap.len - (rows * ctx.bitmap_w)];
    ctx.bitmap_h -= rows;
    ctx.bitmap = try ctx.alloc.alloc(ase.RGBA, trimmed_bitmap.len);
    for (trimmed_bitmap, 0..) |pixel, idx| {
        if (pixel) |px| {
            ctx.bitmap[idx] = px;
            continue;
        }
        ctx.bitmap[idx] = .{ 0, 0, 0, 0 };
    }
}

fn clearArea(ctx: Context, bitmap: []?ase.RGBA, idx: usize, width: usize, height: usize) void {
    const w = width + (ctx.padding * 2);
    const h = height + (ctx.padding * 2);

    for (0..h) |y| {
        for (0..w) |x| {
            bitmap[idx + (y * ctx.bitmap_w + x)] = .{ 0, 0, 0, 0 };
        }
    }
}

fn getTrimmableRows(ctx: Context, bitmap: []?ase.RGBA) usize {
    var count: usize = 0;
    while (bitmap[bitmap.len - 1 - count] == null) {
        count += 1;
    }

    return count / ctx.bitmap_w;
}

fn processNamedHeader(ctx: *Context, header: NamedHeader, bitmap: []?ase.RGBA) !void {
    log.info("processing {s}", .{header.name});
    const alloc = ctx.alloc;
    const file = try ase.Ase.fromFile(ctx.alloc, header.path);
    var frames = try ctx.alloc.alloc(sprite.Frame, file.frames.len);
    for (file.frames, 0..) |frame, frame_idx| {
        var offset: usize = 0;
        for (bitmap, 0..) |pixel, idx| {
            if (pixel == null) {
                if (canFit(ctx.*, file.header.width, file.header.height, idx, bitmap)) {
                    clearArea(ctx.*, bitmap, idx, file.header.width, file.header.height);
                    offset = idx + (ctx.padding * ctx.bitmap_w) + ctx.padding;
                    break;
                }
            }
        }

        try file.renderFrame(frame_idx, bitmap[offset..], ctx.bitmap_w);
        frames[frame_idx] = .{
            .tex_pos = render.TexPos.init(@intCast(offset % ctx.bitmap_w), @intCast(offset / ctx.bitmap_w)),
            .w = file.header.width,
            .h = file.header.height,
            .duration = frame.header.frame_duration,
        };
    }

    // handle still images slightly differently
    if (frames.len == 1) {
        const frame = Frame{
            .name = try strings.copy(alloc, header.name),
            .frame = frames[0],
        };

        try ctx.frames.append(frame);
        return;
    }

    if (file.getTags()) |tags| {
        for (tags) |tag| {
            const anim_name = strings.lower(try strings.concat(alloc, "_", header.name, tag.name));

            const anim = Animation{
                .name = anim_name,
                .frames = frames[tag.from_frame .. tag.to_frame + 1],
            };

            try ctx.animations.append(anim);
        }
    }
}

pub fn processAseFile(ctx: *Context, path: []const u8) !void {
    const alloc = ctx.alloc;
    const file = try ase.Ase.fromFile(ctx.alloc, path);
    var file_parts = std.mem.split(u8, strings.stripSuffix(".aseprite", strings.stripSuffix(".ase", path)), "/");
    var name: []const u8 = undefined;
    while (file_parts.next()) |part| {
        name = part;
    }

    var frames = try ctx.alloc.alloc(sprite.Frame, file.frames.len);
    for (file.frames, 0..) |frame, idx| {
        try file.renderFrame(idx, ctx.bitmap[ctx.offset..], BITMAP_WIDTH);
        frames[idx] = .{
            .tex_pos = render.TexPos.init(@intCast(ctx.offset % BITMAP_WIDTH), @intCast(ctx.offset / BITMAP_WIDTH)),
            .w = file.header.width,
            .h = file.header.width,
            .duration = frame.header.frame_duration,
        };
        ctx.offset += file.header.width + PADDING;
    }

    if (file.getTags()) |tags| {
        for (tags) |tag| {
            const anim_name = strings.lower(try strings.concat(alloc, "_", name, tag.name));

            const anim = Animation{
                .name = anim_name,
                .frames = frames[tag.from_frame .. tag.to_frame + 1],
            };

            try ctx.animations.append(anim);
        }
    }
}

pub fn writeBitmap(ctx: Context, out_path: []const u8) !void {
    _ = c.stbi_write_png(out_path.ptr, @intCast(ctx.bitmap_w), @intCast(ctx.bitmap_h), 4, @ptrCast(ctx.bitmap.ptr), @intCast(ctx.bitmap_w * 4));
}

fn writeAnimationEnum(ctx: Context) !void {
    _ = try ctx.file.write("pub const Anim = enum {\n");
    for (ctx.animations.items) |anim| {
        _ = try ctx.file.write("    ");
        _ = try ctx.file.write(anim.name);
        _ = try ctx.file.write(",\n");
    }

    _ = try ctx.file.write("};\n\n");
}

fn writeAnimation(ctx: Context, curr_indent: comptime_int, anim: Animation) !void {
    const base_indent = " " ** curr_indent;
    const outer_indent = " " ** (curr_indent + 4);
    const indent = " " ** (curr_indent + 8);

    try fmt.format(ctx.file.writer(), "{s}map.set(.{s}, &.{{\n", .{ base_indent, anim.name });
    for (anim.frames) |frame| {
        try fmt.format(ctx.file.writer(), "{s}.{{\n", .{outer_indent});
        try fmt.format(ctx.file.writer(), "{s}.tex_pos = render.TexPos.init({d}, {d}),\n", .{ indent, frame.tex_pos.x, frame.tex_pos.y });
        try fmt.format(ctx.file.writer(), "{s}.w = {d},\n", .{ indent, frame.w });
        try fmt.format(ctx.file.writer(), "{s}.h = {d},\n", .{ indent, frame.h });
        try fmt.format(ctx.file.writer(), "{s}.duration = {d},\n", .{ indent, frame.duration }); // aseprite defaults to 100
        try fmt.format(ctx.file.writer(), "{s}}},\n", .{outer_indent});
    }

    try fmt.format(ctx.file.writer(), "{s}}});\n", .{base_indent});
}

fn writeAnimationArray(ctx: Context) !void {
    _ = try ctx.file.write("fn initAnims() std.EnumArray(Anim, []const sprite.Frame) {\n    comptime {\n");
    _ = try ctx.file.write("        var map = std.EnumArray(Anim, []const sprite.Frame).initUndefined();\n");
    for (ctx.animations.items) |anim| {
        try writeAnimation(ctx, 8, anim);
    }

    _ = try ctx.file.write("        return map;\n");
    _ = try ctx.file.write("    }\n");
    _ = try ctx.file.write("}\n\n");
    _ = try ctx.file.write("pub const anims = initAnims();\n\n");
}

fn writeGetAnimFn(ctx: Context) !void {
    _ = try ctx.file.write("pub inline fn getAnim(anim: Anim) []const sprite.Frame {\n");
    _ = try ctx.file.write("    return anims.get(anim);\n}\n\n");
}

fn writeFrameEnum(ctx: Context) !void {
    _ = try ctx.file.write("pub const Frame = enum {\n");
    for (ctx.frames.items) |frame| {
        _ = try ctx.file.write("    ");
        _ = try ctx.file.write(frame.name);
        _ = try ctx.file.write(",\n");
    }
    _ = try ctx.file.write("};\n\n");
}

fn writeFrame(ctx: Context, curr_indent: comptime_int, frame: Frame) !void {
    const base_indent = " " ** curr_indent;
    const indent = " " ** (curr_indent + 4);

    try fmt.format(ctx.file.writer(), "{s}map.set(.{s}, .{{\n", .{ base_indent, frame.name });
    try fmt.format(ctx.file.writer(), "{s}.tex_pos = render.TexPos.init({d}, {d}),\n", .{ indent, frame.frame.tex_pos.x, frame.frame.tex_pos.y });
    try fmt.format(ctx.file.writer(), "{s}.w = {d},\n", .{ indent, frame.frame.w });
    try fmt.format(ctx.file.writer(), "{s}.h = {d},\n", .{ indent, frame.frame.h });
    try fmt.format(ctx.file.writer(), "{s}.duration = {d},\n", .{ indent, frame.frame.duration }); // aseprite defaults to 100
    try fmt.format(ctx.file.writer(), "{s}}});\n", .{base_indent});
}

fn writeFrameArray(ctx: Context) !void {
    _ = try ctx.file.write("fn initFrames() std.EnumArray(Frame, sprite.Frame) {\n    comptime {\n");
    _ = try ctx.file.write("        var map = std.EnumArray(Frame, sprite.Frame).initUndefined();\n");
    for (ctx.frames.items) |frame| {
        try writeFrame(ctx, 8, frame);
    }

    _ = try ctx.file.write("        return map;\n");
    _ = try ctx.file.write("    }\n");
    _ = try ctx.file.write("}\n\n");
    _ = try ctx.file.write("pub const frames = initFrames();\n\n");
}

fn writeGetFrameFn(ctx: Context) !void {
    _ = try ctx.file.write("pub inline fn getFrame(frame: Frame) sprite.Frame {\n");
    _ = try ctx.file.write("    return frames.get(frame);\n}\n\n");
}

pub fn genAnimationCode(ctx: Context) !void {
    try writeAnimationEnum(ctx);
    try writeFrameEnum(ctx);

    try writeAnimationArray(ctx);
    try writeFrameArray(ctx);

    try writeGetAnimFn(ctx);
    try writeGetFrameFn(ctx);

    try std.fs.cwd().deleteFile(GEN_FINAL_PATH);
    try std.fs.cwd().rename(GEN_OUTPUT_PATH, GEN_FINAL_PATH);
}

pub fn run() !void {
    const alloc = std.heap.page_allocator;
    var ctx = try Context.init(alloc);
    defer ctx.deinit();

    // try processFolder(&ctx, "./assets/sprites/");
    const headers = try collectSortedAseHeaders(&ctx, "./assets/sprites");
    try packTexture(&ctx, headers.items);
    try writeBitmap(ctx, "./assets/sprites/atlas.png");
    try genAnimationCode(ctx);
}
