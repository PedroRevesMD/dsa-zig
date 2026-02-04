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
                self.allocator.destroy(node);
                current = next;
            }

            self.head = null;
            self.tail = null;
            self.len = 0;
        }
        pub fn add(self: *Self, value: T) !void {
            const newNode = try self.allocator.create(Node);
            newNode.* = .{ .data = value, .next = null };

            if (self.tail) |lastNode| {
                lastNode.next = newNode;
                self.tail = newNode;
            } else {
                self.head = newNode;
                self.tail = newNode;
            }
            self.len += 1;
        }
        pub fn addFirst(self: *Self, value: T) !void {
            const newNode = try self.allocator.create(Node);
            newNode.* = .{ .data = value, .next = self.head };

            if (self.tail == null) {
                self.tail = newNode;
            }

            self.head = newNode;
            self.len += 1;
        }
        pub fn addLast(self: *Self, value: T) !void {
            const newNode = try self.allocator.create(Node);
            newNode.* = .{ .data = value, .next = null };

            if (self.tail) |oldTail| {
                oldTail.next = newNode;
                self.tail = newNode;
            } else {
                self.head = newNode;
                self.tail = newNode;
            }

            self.len += 1;
        }
        // pub fn remove(self: *Self, value: T) !void {}
        // pub fn peekFirst(self: *Self) !void {}
        // pub fn peekLast(self: *Self) !void {}
        // pub fn removeFirst(self: *Self) !void {}
        // pub fn indexOf(self: *Self, index: usize) usize {}
        // pub fn removeLast(self: *Self) void {}
        pub fn size(self: *Self) usize {
            return self.len;
        }
    };
}

test "It should be able to Initialize an empty LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try testing.expectEqual(@as(usize, 0), linkedlist.len);
    try testing.expect(linkedlist.head == null);
    try testing.expect(linkedlist.tail == null);
}

test "It should be able to return the length of the LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    const length = linkedlist.size();
    try testing.expectEqual(@as(usize, 0), length);
}

test "It should be able to add an element to a LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try linkedlist.add(10);
    try linkedlist.add(20);

    const length = linkedlist.size();
    try testing.expectEqual(@as(usize, 2), length);
    try testing.expect(linkedlist.head != null);
    try testing.expect(linkedlist.head.?.data == 10);
}

test "It should be able to add an element to a LinkedList (Stacked Way)" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try linkedlist.addFirst(10);
    try linkedlist.addFirst(20);
    try linkedlist.addFirst(30);

    const length = linkedlist.size();
    try testing.expectEqual(@as(usize, 3), length);
    try testing.expect(linkedlist.head != null);
    try testing.expect(linkedlist.head.?.data == 30);
    try testing.expect(linkedlist.tail.?.data == 10);
}

test "It should be able to add an element to the last position of a LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try linkedlist.addLast(10);
    try linkedlist.addLast(20);

    const length = linkedlist.size();
    try testing.expectEqual(@as(usize, 2), length);
    try testing.expect(linkedlist.head != null);
    try testing.expect(linkedlist.head.?.data == 10);
    try testing.expect(linkedlist.tail.?.data == 20);
}

test "It should be able to return the index of an element inserted on the LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try linkedlist.addLast(10);
    try linkedlist.addLast(20);
    try linkedlist.addLast(30);

    const length = linkedlist.size();
    try testing.expectEqual(@as(usize, 3), length);
    try testing.expectEqual(@as(usize, 1), linkedlist.indexOf(10));
    try testing.expectEqual(@as(usize, 2), linkedlist.indexOf(20));

    try testing.expectEqual(@as(usize, 30), linkedlist.tail.?.data);
}
