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
            self.allocator.free(self.items.ptr[0..self.items.len]);
            self.len = 0;
            self.items = &.{};
        }
        // pub fn pop(self: *Self) ?T {}
        // pub fn push(self: *Self, value: T) ?T {}
        // pub fn isEmpty(self: *Self) bool {}
        // pub fn isFull(self: *Self) bool {}
        // fn grow(self: *Self) bool {}

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
