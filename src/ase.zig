const std = @import("std");
const zlib = std.compress.zlib;
const c = @import("c.zig");

const AseErr = error{
    HeaderMagicNumber,
    HeaderZeroes,
    FrameHeaderMagicNumber,
    UnexpectedReadCount,
    InvalidColorDepth,
    InvalidBitsPerTile,
    FrameOutOfBounds,
};

const MAGIC_NUMBER_ASE_HEADER = 0xa5e0;
const MAGIC_NUMBER_FRAME_HEADER = 0xf1fa;

const BYTE = u8;
const WORD = u16;
const SHORT = i16;
const DWORD = u32;
const LONG = i32;
const FIXED = u32; // 32-bit fixed point (16.16) value. Figure out how to deal with these later
const FLOAT = f32;
const DOUBLE = f64;
const QWORD = u64;
const LONG64 = i64;
const UUID = [16]BYTE;

const POINT = struct {
    x: LONG,
    y: LONG,
};

const SIZE = struct {
    width: LONG,
    height: LONG,
};

const RECT = struct {
    origin: POINT,
    size: SIZE,
};

pub const RGBA = [4]BYTE;
pub const GRAYSCALE = [2]BYTE;
pub const INDEX = BYTE;

const PixelType = enum(WORD) {
    rgba = 32,
    grayscale = 16,
    indexed = 8,
};

const PIXELS = union(PixelType) {
    rgba: []RGBA,
    grayscale: []GRAYSCALE,
    indexed: []INDEX,
};

const TILES = union {
    byte: []BYTE,
    word: []WORD,
    dword: []DWORD,
};

const ChunkType = enum(WORD) {
    old_palette_1 = 0x0004, // deprecated if new palette chunk present
    old_palette_2 = 0x0011, // deprecated if new palette chunk present
    layer = 0x2004,
    cel = 0x2005,
    cel_extra = 0x2006,
    color_profile = 0x2007,
    external_files = 0x2008,
    mask = 0x2016, // deprecated
    path = 0x2017, // never used
    tags = 0x2018,
    palette = 0x2019,
    user_data = 0x2020,
    slice = 0x2022,
    tileset = 0x2023,
};

const Header = struct {
    file_size: DWORD,
    magic_number: WORD,
    frames: WORD,
    width: WORD,
    height: WORD,
    color_depth: PixelType,
    flags: DWORD,
    speed: WORD,
    zero_1: DWORD,
    zero_2: DWORD,
    transparent_index: BYTE,
    ignored: [3]BYTE,
    num_colors: WORD,
    pixel_width: BYTE,
    pixel_height: BYTE,
    x_pos: SHORT,
    y_pos: SHORT,
    grid_width: WORD,
    grid_height: WORD,
    future: [84]BYTE,
};

const FrameHeader = struct {
    frame_size: DWORD,
    magic_number: WORD,
    old_chunks: WORD,
    frame_duration: WORD,
    future: [2]BYTE,
    chunks: DWORD,
};

const Chunk = struct {
    size: DWORD,
    type: ChunkType,
    chunk: ChunkInner,
};

const ChunkInner = union(ChunkType) {
    old_palette_1: OldPaletteChunk,
    old_palette_2: OldPaletteChunk,
    layer: LayerChunk,
    cel: CelChunk,
    cel_extra: CelExtraChunk,
    color_profile: ColorProfileChunk,
    external_files: ExternalFilesChunk,
    mask: MaskChunk,
    path: PathChunk,
    tags: TagsChunk,
    palette: PaletteChunk,
    user_data: UserDataChunk,
    slice: SliceChunk,
    tileset: TilesetChunk,
};

const ColorProfileChunk = struct {
    type: WORD,
    flags: WORD,
    fixed_gamma: FIXED,
    reserved: [8]BYTE,
    icc_data_len: DWORD,
    icc_data: ?[]BYTE,
};

const Frame = struct {
    header: FrameHeader,
    chunks: []Chunk,
    // ordered virtual lists that point to cels within chunks
    cels: std.ArrayList(*CelChunk),
};

const LayerFlags = packed struct(WORD) {
    visible: bool,
    editable: bool,
    locked: bool,
    background: bool,
    prefer_linked_cels: bool,
    collapse_group: bool,
    reference: bool,
    _padding: u9,
};

const LayerType = enum(WORD) {
    normal = 0,
    group = 1,
    tilemap = 2,
};

const BlendMode = enum(WORD) {
    normal = 0,
    multiply,
    screen,
    overlay,
    darken,
    lighten,
    color_dodge,
    color_burn,
    hard_light,
    soft_light,
    difference,
    exclusion,
    hue,
    saturation,
    color,
    luminosity,
    addition,
    subtract,
    divide,
};

const LayerChunk = struct {
    flags: LayerFlags,
    type: LayerType,
    child_level: WORD,
    width: WORD, // ignored
    height: WORD, // ignored
    blend_mode: BlendMode,
    opacity: BYTE,
    future: [3]BYTE,
    layer_name: []u8,
    tileset_index: ?DWORD, // only for type == 2
};

const CelType = enum(WORD) {
    raw = 0,
    linked,
    compressed_image,
    compressed_tilemap,
};

const CelData = union(CelType) {
    raw: PixelCel,
    linked: LinkedCel,
    compressed_image: PixelCel,
    compressed_tilemap: TilemapCel,
};

const CelChunk = struct {
    layer_index: WORD,
    x: SHORT,
    y: SHORT,
    opacity: BYTE,
    type: CelType,
    z: SHORT,
    future: [5]BYTE,
    data: CelData,
};

const PixelCel = struct {
    width: WORD,
    height: WORD,
    pixels: PIXELS,
};

const LinkedCel = struct {
    frame_pos: WORD,
};

const TilemapCel = struct {
    width: WORD,
    height: WORD,
    bits_per_tile: WORD,
    tile_id_mask: DWORD,
    x_flip_mask: DWORD,
    y_flip_mask: DWORD,
    diagonal_flip_mask: DWORD,
    reserved: [10]BYTE,
    tiles: TILES,
};

const CelExtraChunk = struct {};

const OldPaletteChunk = struct {};
const PaletteEntry = struct {
    flags: WORD,
    red: BYTE,
    green: BYTE,
    blue: BYTE,
    alpha: BYTE,
    name: ?[]u8,
};

const PaletteChunk = struct {
    size: DWORD,
    first_color: DWORD,
    last_color: DWORD,
    future: [8]BYTE,
    entries: []PaletteEntry,
};

const ExternalFilesChunk = struct {};
const MaskChunk = struct {};
const PathChunk = struct {};
const TagsChunk = struct {
    count: WORD,
    future: [8]BYTE,
    tags: []Tag,
};

const AnimDirection = enum(BYTE) {
    forward,
    reverse,
    ping_pong,
    ping_pong_reverse,
};

const Tag = struct {
    from_frame: WORD,
    to_frame: WORD,
    direction: AnimDirection,
    repeat: WORD,
    future: [6]BYTE,
    deprecated: [3]BYTE,
    zero: BYTE,
    name: []u8,
};

const UserDataChunk = struct {};
const SliceChunk = struct {};
const TilesetChunk = struct {};

pub const Ase = struct {
    header: Header,
    frames: []Frame,
    layers: std.ArrayList(*LayerChunk),
    arena: std.heap.ArenaAllocator,

    pub fn deinit(self: Ase) void {
        self.arena.deinit();
    }

    pub fn fromFile(alloc: std.mem.Allocator, path: []const u8) !Ase {
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();

        const stream = file.reader().any();
        const header = try parseHeader(stream);
        var ase = Ase{
            .header = header,
            .frames = undefined,
            .layers = undefined,
            .arena = std.heap.ArenaAllocator.init(alloc),
        };
        errdefer ase.arena.deinit();

        ase.layers = try std.ArrayList(*LayerChunk).initCapacity(ase.arena.allocator(), 10);

        ase.frames = try ase.arena.allocator().alloc(Frame, header.frames);
        for (0..ase.header.frames) |frame_idx| {
            var frame = Frame{
                .header = try parseFrameHeader(stream),
                .cels = try std.ArrayList(*CelChunk).initCapacity(ase.arena.allocator(), 10),
                .chunks = undefined,
            };

            frame.chunks = try ase.arena.allocator().alloc(Chunk, frame.header.chunks);
            for (0..frame.header.chunks) |chunk_idx| {
                frame.chunks[chunk_idx] = try parseChunk(&ase, stream);
                switch (frame.chunks[chunk_idx].chunk) {
                    .layer => try ase.layers.append(&frame.chunks[chunk_idx].chunk.layer),
                    .cel => try frame.cels.append(&frame.chunks[chunk_idx].chunk.cel),
                    else => continue,
                }
            }

            ase.frames[frame_idx] = frame;
        }

        return ase;
    }

    pub fn renderFrame(ase: Ase, frame_idx: usize, bitmap: []RGBA, canvas_width: usize) !void {
        if (frame_idx >= ase.frames.len) {
            return AseErr.FrameOutOfBounds;
        }

        const frame = ase.frames[frame_idx];
        for (frame.cels.items) |cel| {
            const layer = ase.layers.items[cel.layer_index];
            switch (cel.data) {
                .compressed_image => |ci| {
                    switch (ci.pixels) {
                        .rgba => |pixels| {
                            for (pixels, 0..) |pixel, idx| {
                                const width: usize = @intCast(ci.width);
                                const x: usize = @intCast(cel.x);
                                const y: usize = @intCast(cel.y);

                                const origin = y * canvas_width + x;
                                const offset = (idx / width) * canvas_width + idx % width;
                                const current_pixel = bitmap[origin + offset];
                                bitmap[origin + offset] = blend(layer.blend_mode, pixel, current_pixel);
                            }
                        },
                        else => std.log.err("unhandled pixel data type", .{}),
                    }
                },
                else => std.log.err("unhandled cel data type", .{}),
            }
        }
    }

    pub fn renderSheet(ase: Ase, alloc: std.mem.Allocator) ![]RGBA {
        const frame_width = ase.header.width;
        const canvas_width = frame_width * ase.frames.len;
        const canvas_height = ase.header.height;

        var canvas_pixels = try alloc.alloc(RGBA, canvas_width * canvas_height);
        for (canvas_pixels, 0..) |_, i| {
            canvas_pixels[i] = .{ 0, 0, 0, 0 };
        }

        for (ase.frames, 0..) |_, frame_idx| {
            const frame_offset = frame_width * frame_idx;
            try renderFrame(ase, frame_idx, canvas_pixels[frame_offset..], canvas_width);
        }

        return canvas_pixels;
    }

    pub fn getTags(ase: Ase) ?[]Tag {
        for (ase.frames) |frame| {
            for (frame.chunks) |chunk| {
                switch (chunk.chunk) {
                    .tags => |tag_chunk| return tag_chunk.tags,
                    else => {},
                }
            }
        }

        return null;
    }

    fn blend(mode: BlendMode, s: RGBA, d: RGBA) RGBA {
        // alpha compositing equation is:
        // R = S*Sa + (1 - Sa)*Da*D
        // where R is the result, S is the Source, D is the destination, and all values
        // are NOT premultiplied alpha
        // This equation should be repeated for each color component (including alpha)
        switch (mode) {
            .normal => {
                const src_alpha: f32 = @floatFromInt(s[3]);
                const dest_alpha: f32 = @floatFromInt(d[3]);
                const alpha_s = src_alpha / 255;
                const alpha_d = dest_alpha / 255;

                const sr: f32 = @floatFromInt(s[0]);
                const sg: f32 = @floatFromInt(s[1]);
                const sb: f32 = @floatFromInt(s[2]);

                const dr: f32 = @floatFromInt(d[0]);
                const dg: f32 = @floatFromInt(d[1]);
                const db: f32 = @floatFromInt(d[2]);

                // TODO (etate): consider making this SIMD?
                return .{
                    @intFromFloat(sr * alpha_s + (1 - alpha_s) * alpha_d * dr),
                    @intFromFloat(sg * alpha_s + (1 - alpha_s) * alpha_d * dg),
                    @intFromFloat(sb * alpha_s + (1 - alpha_s) * alpha_d * db),
                    @intFromFloat(src_alpha * alpha_s + (1 - alpha_s) * alpha_d * dest_alpha),
                };
            },
            else => {
                std.log.err("unhandled blend mode '{any}'", .{mode});
                return s;
            },
        }
    }

    fn parseChunk(ase: *Ase, stream: std.io.AnyReader) !Chunk {
        const alloc = ase.arena.allocator();

        var chunk = Chunk{
            .size = try readCast(DWORD, stream),
            .type = @enumFromInt(try readCast(WORD, stream)),
            .chunk = undefined,
        };

        chunk.chunk = switch (chunk.type) {
            .color_profile => .{ .color_profile = try parseColorProfile(alloc, stream) },
            .palette => .{ .palette = try parsePaletteChunk(alloc, stream) },
            .layer => .{ .layer = try parseLayerChunk(alloc, stream) },
            .cel => .{ .cel = try parseCelChunk(ase, stream) },
            .tags => .{ .tags = try parseTagsChunk(ase, stream) },
            else => brk: {
                std.log.warn("skipping: {any}", .{chunk.type});
                const skip_len: u64 = chunk.size - @sizeOf(DWORD) - @sizeOf(WORD);
                try stream.skipBytes(skip_len, .{});
                break :brk .{ .path = PathChunk{} };
            },
        };

        return chunk;
    }

    fn parseCelChunk(ase: *Ase, stream: std.io.AnyReader) !CelChunk {
        var cel = CelChunk{
            .layer_index = try readCast(WORD, stream),
            .x = try readCast(SHORT, stream),
            .y = try readCast(SHORT, stream),
            .opacity = try readCast(BYTE, stream),
            .type = @enumFromInt(try readCast(WORD, stream)),
            .z = try readCast(SHORT, stream),
            .future = try readCast([5]BYTE, stream),
            .data = undefined,
        };

        cel.data = switch (cel.type) {
            .raw => .{ .raw = try ase.parsePixelCel(stream, false) },
            .linked => .{ .linked = LinkedCel{ .frame_pos = try readCast(WORD, stream) } },
            .compressed_image => .{ .compressed_image = try ase.parsePixelCel(stream, true) },
            .compressed_tilemap => .{ .compressed_tilemap = try parseTileCel(
                ase,
                stream,
            ) },
        };

        return cel;
    }

    fn parsePixelCel(ase: *Ase, stream: std.io.AnyReader, compressed: bool) !PixelCel {
        const alloc = ase.arena.allocator();
        var cel = PixelCel{
            .width = try readCast(WORD, stream),
            .height = try readCast(WORD, stream),
            .pixels = undefined,
        };

        const raw_pixels = try alloc.alloc(u8, cel.width * cel.height * (@intFromEnum(ase.header.color_depth) / 8));

        if (compressed) {
            var zstream = zlib.decompressor(stream);
            // defer zstream.deinit();
            _ = try zstream.read(raw_pixels);
            // there's a zlib checksum at the end of the compressed data that we can
            // validate and by reading one more byte from the stream (this also progresses
            // our stream to the next chunk/frame in the file)
            var buf: [1]u8 = undefined;
            _ = try zstream.read(buf[0..]);
        } else {
            _ = try stream.read(raw_pixels);
        }

        cel.pixels = switch (ase.header.color_depth) {
            .indexed => .{ .indexed = raw_pixels },
            .grayscale => .{ .grayscale = std.mem.bytesAsSlice(GRAYSCALE, raw_pixels) },
            .rgba => .{ .rgba = std.mem.bytesAsSlice(RGBA, raw_pixels) },
        };

        return cel;
    }

    fn parseTileCel(ase: *Ase, stream: std.io.AnyReader) !TilemapCel {
        const alloc = ase.arena.allocator();

        var cel = TilemapCel{
            .width = try readCast(WORD, stream),
            .height = try readCast(WORD, stream),
            .bits_per_tile = try readCast(WORD, stream),
            .tile_id_mask = try readCast(DWORD, stream),
            .x_flip_mask = try readCast(DWORD, stream),
            .y_flip_mask = try readCast(DWORD, stream),
            .diagonal_flip_mask = try readCast(DWORD, stream),
            .reserved = try readCast([10]BYTE, stream),
            .tiles = undefined,
        };

        const raw_tiles = try alloc.alloc(u8, cel.width * cel.height * cel.bits_per_tile);
        var ztream = zlib.decompressor(stream);
        _ = try ztream.read(raw_tiles);
        cel.tiles = switch (cel.bits_per_tile) {
            8 => .{ .byte = raw_tiles },
            // NOTE: these casts were weird to compile and I'm not sure if they'll work in practice
            16 => .{ .word = @alignCast(std.mem.bytesAsSlice(WORD, raw_tiles)) },
            32 => .{ .dword = @alignCast(std.mem.bytesAsSlice(DWORD, raw_tiles)) },
            else => return AseErr.InvalidBitsPerTile,
        };

        return cel;
    }

    fn parseTagsChunk(ase: *Ase, stream: std.io.AnyReader) !TagsChunk {
        const alloc = ase.arena.allocator();

        const count = try readCast(WORD, stream);
        const chunk = TagsChunk{
            .count = count,
            .future = try readCast([8]BYTE, stream),
            .tags = try alloc.alloc(Tag, count),
        };

        for (chunk.tags) |*tag| {
            tag.from_frame = try readCast(WORD, stream);
            tag.to_frame = try readCast(WORD, stream);
            tag.direction = @enumFromInt(try readCast(BYTE, stream));
            tag.repeat = try readCast(WORD, stream);
            tag.future = try readCast([6]BYTE, stream);
            tag.deprecated = try readCast([3]BYTE, stream);
            tag.zero = try readCast(BYTE, stream);
            tag.name = try readString(alloc, stream);
        }

        return chunk;
    }
};

fn readCast(comptime T: type, stream: std.io.AnyReader) !T {
    var buffer: [@sizeOf(T)]u8 = undefined;
    const bytes_read = try stream.read(buffer[0..]);
    if (buffer.len != bytes_read) {
        return AseErr.UnexpectedReadCount;
    }

    const val: *T = @ptrCast(@alignCast(&buffer));

    return val.*;
}

fn readString(alloc: std.mem.Allocator, stream: std.io.AnyReader) ![]u8 {
    const len = try readCast(WORD, stream);
    const str = try alloc.alloc(u8, len);
    _ = try stream.read(str);

    return str;
}

// NOTE: because of struct padding, we can't just @ptrCast sections of the file directly. Handling each field
// individually is an easy workaround and prevents the need for marking everything as extern
fn parseHeader(stream: std.io.AnyReader) !Header {
    const header = Header{
        .file_size = try readCast(DWORD, stream),
        .magic_number = try readCast(WORD, stream),
        .frames = try readCast(WORD, stream),
        .width = try readCast(WORD, stream),
        .height = try readCast(WORD, stream),
        .color_depth = @enumFromInt(try readCast(WORD, stream)),
        .flags = try readCast(DWORD, stream),
        .speed = try readCast(WORD, stream),
        .zero_1 = try readCast(DWORD, stream),
        .zero_2 = try readCast(DWORD, stream),
        .transparent_index = try readCast(BYTE, stream),
        .ignored = try readCast([3]BYTE, stream),
        .num_colors = try readCast(WORD, stream),
        .pixel_width = try readCast(BYTE, stream),
        .pixel_height = try readCast(BYTE, stream),
        .x_pos = try readCast(SHORT, stream),
        .y_pos = try readCast(SHORT, stream),
        .grid_width = try readCast(WORD, stream),
        .grid_height = try readCast(WORD, stream),
        .future = try readCast([84]BYTE, stream),
    };

    if (header.magic_number != MAGIC_NUMBER_ASE_HEADER) {
        return AseErr.HeaderMagicNumber;
    }

    return header;
}

fn parseFrameHeader(stream: std.io.AnyReader) !FrameHeader {
    // const header = try readCast(FrameHeader, stream);
    const header = FrameHeader{
        .frame_size = try readCast(DWORD, stream),
        .magic_number = try readCast(WORD, stream),
        .old_chunks = try readCast(WORD, stream),
        .frame_duration = try readCast(WORD, stream),
        .future = try readCast([2]BYTE, stream),
        .chunks = try readCast(DWORD, stream),
    };

    if (header.magic_number != MAGIC_NUMBER_FRAME_HEADER) {
        return AseErr.FrameHeaderMagicNumber;
    }

    return header;
}

fn parseColorProfile(alloc: std.mem.Allocator, stream: std.io.AnyReader) !ColorProfileChunk {
    var chunk = ColorProfileChunk{
        .type = try readCast(WORD, stream),
        .flags = try readCast(WORD, stream),
        .fixed_gamma = try readCast(FIXED, stream),
        .reserved = try readCast([8]BYTE, stream),
        .icc_data_len = 0,
        .icc_data = null,
    };

    if (chunk.type == 2) {
        chunk.icc_data_len = try readCast(DWORD, stream);
        chunk.icc_data = try alloc.alloc(u8, chunk.icc_data_len);
        _ = try stream.read(chunk.icc_data.?);
    }

    std.log.warn("color profile: {any}", .{chunk});
    return chunk;
}

fn parsePaletteChunk(alloc: std.mem.Allocator, stream: std.io.AnyReader) !PaletteChunk {
    var chunk = PaletteChunk{
        .size = try readCast(DWORD, stream),
        .first_color = try readCast(DWORD, stream),
        .last_color = try readCast(DWORD, stream),
        .future = try readCast([8]BYTE, stream),
        .entries = undefined,
    };

    chunk.entries = try alloc.alloc(PaletteEntry, chunk.last_color - chunk.first_color + 1);
    for (chunk.entries) |*entry| {
        entry.flags = try readCast(WORD, stream);
        entry.red = try readCast(BYTE, stream);
        entry.blue = try readCast(BYTE, stream);
        entry.green = try readCast(BYTE, stream);
        entry.alpha = try readCast(BYTE, stream);

        if (entry.flags == 1) {
            entry.name = try readString(alloc, stream);
            _ = try stream.read(entry.name.?);
        }
    }

    std.log.warn("palette chunk: {any}", .{chunk});
    return chunk;
}

fn parseLayerChunk(alloc: std.mem.Allocator, stream: std.io.AnyReader) !LayerChunk {
    var chunk = LayerChunk{
        .flags = try readCast(LayerFlags, stream),
        .type = @enumFromInt(try readCast(WORD, stream)),
        .child_level = try readCast(WORD, stream),
        .width = try readCast(WORD, stream),
        .height = try readCast(WORD, stream),
        .blend_mode = @enumFromInt(try readCast(WORD, stream)),
        .opacity = try readCast(BYTE, stream),
        .future = try readCast([3]BYTE, stream),
        .layer_name = try readString(alloc, stream),
        .tileset_index = null,
    };

    if (chunk.type == .tilemap) {
        chunk.tileset_index = try readCast(DWORD, stream);
    }

    std.log.warn("layer chunk: {any}", .{chunk});
    return chunk;
}

test "parse ase file" {
    const t = std.testing;

    const ase = try Ase.fromFile(t.allocator, "./assets/sprites/face.ase");
    defer ase.deinit();

    const pixels = ase.render();
    _ = c.stbi_write_png("./face.png", @intCast(ase.header.canvas_width), @intCast(ase.header.canvas_height), 4, @ptrCast(pixels.ptr), @intCast(ase.header.canvas_width * 4));
}

pub fn headerFromFile(path: []const u8) !Header {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const stream = file.reader().any();
    const header = try parseHeader(stream);
    return header;
}
