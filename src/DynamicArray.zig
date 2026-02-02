const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn DynamicArray(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        capacity: usize = 10,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{ .items = &[_]T{}, .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            if (self.items.len > 0) {
                self.allocator.free(self.items);
            }
        }
    };
}

test "It should be able to initialize the Dynamic Array" {
    var array = DynamicArray(i32).init(testing.allocator);
    defer array.deinit();

    try testing.expectEqual(@as(usize, 0), array.items.len);
    try testing.expectEqual(@as(usize, 10), array.capacity);
}

test "It should be able to append a value to the array" {
    var array = DynamicArray(i32).init(testing.allocator);
    defer array.deinit();

    array.append(1);
    array.append(2);
    array.append(3);

    try testing.expectEqual(@as(usize, 3), array.items.len);
    try testing.expectEqual(@as(i32, 1), array.items[0]);
}
