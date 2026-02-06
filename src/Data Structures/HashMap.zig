const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Hashmap(comptime _: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        pub fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator };
        }
        // pub fn deinit(se_f: *Self) void {}
    };
}
