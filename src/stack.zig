const std = @import("std");
const testing = std.testing;
const mem = std.mem;

const stackErrors = error{StackVazia};

pub fn stack(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const node = struct {
            next: ?*node = null,
            prev: ?*node = null,
            info: T,
        };

        allocator: *mem.Allocator,
        root: ?*node = null,
        size: usize = 0,

        pub fn pop(self: *Self) stackErrors!void {
            if (self.root == null) {
                return stackErrors.StackVazia;
            }

            const currentValue = self.root.?;
            defer self.allocator.destroy(currentValue);

            self.root = self.root.?.prev;
            self.size -= 1;
        }

        pub fn top(self: *Self) stackErrors!T {
            if (self.root == null) {
                return stackErrors.StackVazia;
            }
            return self.root.?.info;
        }

        pub fn push(self: *Self, key: T) void {
            const newNode = try self.allocator.create(node);
            newNode.* = node{ .info = key };

            if (self.root == null) {
                self.root = newNode;
                self.size += 1;
            } else {
                self.root.?.next = newNode;
                newNode.prev = self.root;
                self.root = newNode;
                self.size += 1;
            }
        }

        fn destroy(self: *Self) void {
            while (self.size != 0) : (try self.pop()) {}
            self.size = 0;
        }
    };
}
