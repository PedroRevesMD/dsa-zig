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

test "It should be able to initialize and deinitialize the HashMap" {
    var hashmap = try Hashmap(i32, i32).init(testing.allocator, 0);
    defer hashmap.deinit();

    try testing.expectEqual(@as(usize, 0), hashmap.len);
    try testing.expectEqual(@as(usize, 10), hashmap.buckets.len);
}

test "It should be able to initialize with custom capacity and deinitialize the HashMap" {
    var hashmap = try Hashmap(i32, i32).init(testing.allocator, 5);
    defer hashmap.deinit();

    try testing.expectEqual(@as(usize, 0), hashmap.len);
    try testing.expectEqual(@as(usize, 5), hashmap.buckets.len);
}
