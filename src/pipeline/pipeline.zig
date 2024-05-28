const std = @import("std");
const fmt = std.fmt;
const sprite = @import("../sprite.zig");
const render = @import("../render/render.zig");
const ase = @import("../ase.zig");
const strings = @import("../strings.zig");
const log = @import("../log.zig");
const dim = @import("../dim.zig");
const c = @import("../c.zig");

const INITIAL_ANIM_CAP = 512;
const BITMAP_WIDTH = 1024;
const BITMAP_HEIGHT = 1024;
const PADDING = 2;

const GEN_FINAL_PATH = "./src/gen.zig";
const GEN_OUTPUT_PATH = GEN_FINAL_PATH ++ ".tmp";
const HEADER = "// DO NOT EDIT! This file is generated each time the asset pipeline runs and any manual changes will be overwritten\n\nconst std = @import(\"std\");\nconst sprite = @import(\"sprite.zig\");\nconst render = @import(\"render/render.zig\");\n\n";

pub const Animation = struct {
    name: []u8,
    frames: []sprite.Frame,
};

const Area = struct {
    pos: dim.Vec2(u16),
    w: u16,
    h: u16,
};

pub const Context = struct {
    alloc: std.mem.Allocator,
    animations: std.ArrayList(Animation),
    bitmap: []ase.RGBA,
    file: std.fs.File,
    offset: usize,

    pub fn init(alloc: std.mem.Allocator) !Context {
        const bitmap = try alloc.alloc(ase.RGBA, BITMAP_WIDTH * BITMAP_HEIGHT);
        for (bitmap, 0..) |_, i| {
            bitmap[i] = .{ 0, 0, 0, 0 };
        }

        return Context{
            .alloc = alloc,
            .animations = try std.ArrayList(Animation).initCapacity(alloc, INITIAL_ANIM_CAP),
            .bitmap = bitmap,
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
            .tex_pos = render.TexPos.init(@intCast(ctx.offset % BITMAP_WIDTH), @intCast(ctx.offset / BITMAP_HEIGHT)),
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
    _ = c.stbi_write_png(out_path.ptr, BITMAP_WIDTH, @intCast(BITMAP_HEIGHT), 4, @ptrCast(ctx.bitmap.ptr), BITMAP_WIDTH * 4);
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

pub fn genAnimationCode(ctx: Context) !void {
    try writeAnimationEnum(ctx);
    try writeAnimationArray(ctx);
    try writeGetAnimFn(ctx);

    try std.fs.cwd().deleteFile(GEN_FINAL_PATH);
    try std.fs.cwd().rename(GEN_OUTPUT_PATH, GEN_FINAL_PATH);
}

pub fn run() !void {
    const alloc = std.heap.page_allocator;
    var ctx = try Context.init(alloc);
    defer ctx.deinit();

    try processFolder(&ctx, "./assets/sprites/");
    try writeBitmap(ctx, "./assets/sprites/atlas.png");
    try genAnimationCode(ctx);
}
