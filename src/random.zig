const std = @import("std");
const RndGen = std.Random.DefaultPrng;

var rng = RndGen.init(0);

pub fn getEnum(T: type) T {
    return rng.random().enumValue(T);
}

pub fn lessThan(limit: usize) usize {
    return rng.random().uintLessThan(usize, limit);
}
