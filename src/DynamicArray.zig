const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn DynamicArray(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        capacity: usize,
        allocator: Allocator,

        pub fn init(allocator: Allocator) !Self {
            const initialCapacity: i32 = 10;
            const memory = try allocator.alloc(T, initialCapacity);
            return Self{ .items = memory[0..0], .allocator = allocator, .capacity = initialCapacity };
        }

        pub fn deinit(self: *Self) void {
            if (self.capacity > 0) {
                const memory = self.items.ptr[0..self.capacity];
                self.allocator.free(memory);
            }
        }

        pub fn append(self: *Self, value: i32) !void {
            if (self.items.len == self.capacity) {
                const newCapacity = self.capacity * 2;
                const oldMemory = self.items.ptr[0..self.capacity];
                const newSlice = try self.allocator.realloc(oldMemory, newCapacity);
                self.capacity = newCapacity;
                self.items.ptr = newSlice.ptr;
            }

            const newLength = self.items.len + 1;
            self.items = self.items.ptr[0..newLength];
            self.items[newLength - 1] = value;
        }

        pub fn length(self: *Self) usize {
            return self.items.len;
        }

        pub fn pop(self: *Self) ?T {
            if (self.items.len == 0) {
                return null;
            }
            const size = self.length();
            const value: T = self.items[size - 1];

            self.items = self.items.ptr[0 .. size - 1];
            return value;
        }
    };
}

test "It should be able to initialize the Dynamic Array" {
    var array = try DynamicArray(i32).init(testing.allocator);
    defer array.deinit();

    try testing.expectEqual(@as(usize, 0), array.items.len);
    try testing.expectEqual(@as(usize, 10), array.capacity);
}

test "It should be able to append a value to the array" {
    var array = try DynamicArray(i32).init(testing.allocator);
    defer array.deinit();

    try array.append(1);
    try array.append(2);
    try array.append(3);

    try testing.expectEqual(@as(usize, 3), array.items.len);
    try testing.expectEqual(@as(i32, 1), array.items[0]);
}

test "It should be able to return the length of the array" {
    var array = try DynamicArray(i32).init(testing.allocator);
    defer array.deinit();

    try array.append(1);
    try array.append(2);
    try array.append(3);
    try array.append(4);
    try array.append(5);

    try testing.expectEqual(@as(usize, 5), array.items.len);
}

test "It should be able to delete a value from the first index in the array" {
    var array = try DynamicArray(i32).init(testing.allocator);
    defer array.deinit();

    try array.append(1);
    try array.append(2);
    try array.append(3);
    try array.append(4);
    try array.append(5);

    const sut = array.pop();

    try testing.expectEqual(@as(?i32, 5), sut);
    try testing.expectEqual(@as(usize, 4), array.items.len);
}
