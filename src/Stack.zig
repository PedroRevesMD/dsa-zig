const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Stack(comptime _: type) type {
    return struct {};
test "It should be able to initialize the stack" {
    var stack = Stack(i32).init(testing.allocator);
    defer stack.deinit();

    try testing.expectEqual(@as(usize, 0), stack.len);
    try testing.expectEqual(@as(usize, 0), stack.items.len);
}
