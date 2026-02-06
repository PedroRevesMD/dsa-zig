const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        const GROWTH_FACTOR: usize = 2;
        len: usize = 0,
        items: []T = &.{},
        allocator: std.mem.Allocator,
        pub fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator };
        }
        pub fn deinit(self: *Self) void {
            if (self.len == 0) return;
            self.allocator.free(self.items.ptr[0..self.len]);
            self.len = 0;
            self.items = &.{};
        }
        pub fn pop(self: *Self) ?T {
            if (self.items.len == 0) return null;
            self.items.len -= 1;
            return self.items.ptr[self.items.len];
        }
        pub fn push(self: *Self, value: T) !void {
            if (self.items.len >= self.len) {
                try self.grow();
            }

            self.items.ptr[self.items.len] = value;
            self.items.len += 1;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.items.len == 0;
        }

        fn grow(self: *Self) !void {
            const oldLen = self.items.len;
            const newCapacity = if (self.len == 0) 8 else self.len * GROWTH_FACTOR;
            self.items = try self.allocator.realloc(self.items.ptr[0..self.len], newCapacity);
            self.len = newCapacity;
            self.items.len = oldLen;
        }
    };
}

test "It should be able to initialize the stack" {
    var stack = Stack(i32).init(testing.allocator);
    defer stack.deinit();

    try testing.expectEqual(@as(usize, 0), stack.len);
    try testing.expectEqual(@as(usize, 0), stack.items.len);
}

test "It should be able to add values into the stack" {
    var stack = Stack(i32).init(testing.allocator);
    defer stack.deinit();

    try stack.push(10);
    try stack.push(20);
    try stack.push(30);
    try stack.push(40);

    try testing.expectEqual(@as(usize, 4), stack.items.len);
}

test "It should be able to pop the last value inserted in the stack" {
    var stack = Stack(i32).init(testing.allocator);
    defer stack.deinit();

    try stack.push(10);
    try stack.push(20);
    try stack.push(30);
    try stack.push(40);

    const lastValue: ?i32 = stack.pop().?;

    try testing.expectEqual(@as(usize, 3), stack.items.len);
    try testing.expectEqual(@as(i32, 40), lastValue);
}
