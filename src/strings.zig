const std = @import("std");

const StringsErr = error{
    Empty,
};

pub fn hasPrefix(prefix: []const u8, string: []const u8) bool {
    if (string.len < prefix.len) {
        return false;
    }

    for (prefix, 0..) |ch, idx| {
        if (string[idx] != ch) {
            return false;
        }
    }

    return true;
}

pub fn hasSuffix(suffix: []const u8, string: []const u8) bool {
    if (string.len < suffix.len) {
        return false;
    }

    for (suffix, 0..) |ch, idx| {
        if (string[string.len - suffix.len + idx] != ch) {
            return false;
        }
    }

    return true;
}

pub fn stripPrefix(prefix: []const u8, string: []const u8) []const u8 {
    if (!hasPrefix(prefix, string)) {
        return string;
    }

    return string[prefix.len..];
}

pub fn stripSuffix(suffix: []const u8, string: []const u8) []const u8 {
    if (!hasSuffix(suffix, string)) {
        return string;
    }

    return string[0 .. string.len - suffix.len];
}

pub fn splitLast(string: []const u8, sep: []const u8) ![]const u8 {
    var parts = std.mem.splitSequence(u8, string, sep);
    var result: []const u8 = parts.next() orelse return StringsErr.Empty;
    while (parts.next()) |part| {
        result = part;
    }

    return result;
}

pub fn copy(alloc: std.mem.Allocator, string: []const u8) ![]u8 {
    const copied = try alloc.alloc(u8, string.len);
    @memcpy(copied, string);
    return copied;
}

pub fn concat(alloc: std.mem.Allocator, sep: []const u8, left: []const u8, right: []const u8) ![]u8 {
    const strs: [2][]const u8 = .{ left, right };

    return try std.mem.join(alloc, sep, &strs);
}

pub fn lower(string: []u8) []u8 {
    for (string, 0..) |ch, idx| {
        if (ch >= 'A' and ch <= 'Z') {
            string[idx] = ch + ('a' - 'A');
        }
    }

    return string;
}

pub fn upper(string: []u8) []u8 {
    for (string, 0..) |ch, idx| {
        if (ch >= 'a' and ch <= 'z') {
            string[idx] = ch - ('a' - 'A');
        }
    }

    return string;
}

pub fn toLower(alloc: std.mem.Allocator, string: []const u8) ![]u8 {
    // NOTE (etate): this isn't optimal, but it's good enough for current usage
    return lower(try copy(alloc, string));
}

pub fn toUpper(alloc: std.mem.Allocator, string: []const u8) ![]u8 {
    // NOTE (etate): this isn't optimal, but it's good enough for current usage
    return upper(try copy(alloc, string));
}

test "strings.hasPrefix" {
    const t = std.testing;

    try t.expect(hasPrefix("sprite", "sprite.ase"));
    try t.expect(!hasPrefix("sprites", "sprite.ase"));
}

test "strings.hasSuffix" {
    const t = std.testing;

    try t.expect(hasSuffix(".ase", "sprite.ase"));
    try t.expect(!hasSuffix(".as", "sprite.ase"));
}

test "strings.stripPrefix" {
    const t = std.testing;

    try t.expect(std.mem.eql(u8, stripPrefix("sprite", "sprite.ase"), ".ase"));
    try t.expect(std.mem.eql(u8, stripPrefix("sprt", "sprite.ase"), "sprite.ase"));
}

test "strings.stripSuffix" {
    const t = std.testing;

    try t.expect(std.mem.eql(u8, stripSuffix(".ase", "sprite.ase"), "sprite"));
    try t.expect(std.mem.eql(u8, stripSuffix(".as", "sprite.ase"), "sprite.ase"));
}

test "strings.copy" {
    const t = std.testing;

    const original_string = "hello, world!";
    const copied_string = try copy(t.allocator, original_string);
    defer t.allocator.free(copied_string);

    try t.expect(std.mem.eql(u8, original_string, copied_string));
    try t.expect(original_string != copied_string.ptr); // ensure we're pointing at different memory
}

test "strings.concat" {
    const t = std.testing;

    const left = "hello,";
    const right = "world!";

    const concatenated = try concat(t.allocator, " ", left, right);
    defer t.allocator.free(concatenated);

    try t.expect(std.mem.eql(u8, concatenated, "hello, world!"));
}

test "strings.lower" {
    const t = std.testing;

    const string = try copy(t.allocator, "HeL10!"); // copying to get mutable slice
    defer t.allocator.free(string);

    try t.expect(std.mem.eql(u8, lower(string), "hel10!"));
}

test "strings.upper" {
    const t = std.testing;

    const string = try copy(t.allocator, "HeL10!"); // copying to get mutable slice
    defer t.allocator.free(string);

    try t.expect(std.mem.eql(u8, upper(string), "HEL10!"));
}

test "strings.toLower" {
    const t = std.testing;

    const string = "HeL10!";
    const lower_string = try toLower(t.allocator, string);
    defer t.allocator.free(lower_string);

    try t.expect(std.mem.eql(u8, lower_string, "hel10!"));
}

test "strings.toUpper" {
    const t = std.testing;

    const string = "HeL10!";
    const upper_string = try toUpper(t.allocator, string);
    defer t.allocator.free(upper_string);

    try t.expect(std.mem.eql(u8, upper_string, "HEL10!"));
}

test "strings.splitLast" {
    const t = std.testing;

    const string = "this/is/a/test/path";
    const name = try splitLast(string, "/");

    try t.expect(std.mem.eql(u8, name, "path"));
}
