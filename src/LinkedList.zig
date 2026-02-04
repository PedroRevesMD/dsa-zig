const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            data: T,
            next: ?*Node = null,
        };

        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(current);
                current = next;
            }

            self.head = null;
            self.tail = null;
            self.size = null;
        }
        // pub fn add(self: *Self, value: T) !void {}
        // pub fn remove(self: *Self, value: T) !void {}
        // pub fn peekFirst(self: *Self) !void {}
        // pub fn peekLast(self: *Self) !void {}
        // pub fn addFirst(self: *Self) void {}
        // pub fn addLast(self: *Self) void {}
        // pub fn removeFirst(self: *Self) !void {}
        // pub fn indexOf(self: *Self, index: usize) usize {}
        // pub fn removeLast(self: *Self) void {}
        // pub fn size(self: *Self) usize {}
    };
}

test "It should be able to Initialize an empty LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try testing.expectEqual(@as(usize, 0), linkedlist.len);
    try testing.expect(linkedlist.head == null);
    try testing.expect(linkedlist.tail == null);
}
