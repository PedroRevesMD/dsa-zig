const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = struct {
            data: T,
            next: ?*Node = null,
        };
        items: []T,
        allocator: Allocator,
        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,
        index: usize,

        pub fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator };
        }
        pub fn deinit(self: *Self) Self {
            while (self.dequeue()) |_| {}
        }

        pub fn enqueue(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = .{ .data = value };

            if (self.tail) |tail| {
                tail.next = node;
            } else {
                self.head = node;
            }
            self.tail = node;
            self.len += 1;
        }

        pub fn dequeue(self: *Self) ?T {
            const node = self.head orelse return null;
            defer self.allocator.destroy(node);

            self.head = node.next;
            if (self.head == null) self.tail = null;
            self.len -= 1;
            return node.data;
        }

        pub fn peek(self: *Self) ?T {
            return if (self.head) |h| h.data else null;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.len == 0;
        }
    };
}
