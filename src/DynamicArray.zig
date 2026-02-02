const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

test "It should be able to initialize the Dynamic Array" {
    var array = DynamicArray(i32).init(testing.allocator);
    defer array.deinit;

    try testing.expectEqual(@as(usize, 0), array.items.len);
    try testing.expectEqual(@as(usize, 10), array.capacity);
}
