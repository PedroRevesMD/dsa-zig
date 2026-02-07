const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Hashmap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const GROWTH_FACTOR: usize = 2;

        buckets: []?*Entry,
        len: usize,
        allocator: Allocator,

        const Entry = struct { key: K, value: V, next: ?*Entry };

        pub fn init(allocator: Allocator, initial_cap: usize) !Self {
            const capacity = if (initial_cap == 0) 10 else initial_cap;
            const buckets = try allocator.alloc(?*Entry, capacity);
            for (buckets) |*bucket| {
                bucket.* = null;
            }

            return Self{ .buckets = buckets, .allocator = allocator, .len = 0 };
        }
        pub fn deinit(self: *Self) void {
            for (self.buckets) |bucket| {
                var current = bucket;
                while (current) |entry| {
                    const next = entry.next;
                    self.allocator.destroy(entry);
                    current = next;
                }
            }
            self.allocator.free(self.buckets);
        }
    };
}

test "It should be able to initialize and deinitialize the HashMap" {
    var hashmap = try Hashmap(i32, i32).init(testing.allocator, 0);
    defer hashmap.deinit();

    try testing.expectEqual(@as(usize, 0), hashmap.len);
    try testing.expectEqual(@as(usize, 10), hashmap.buckets.len);
}

test "It should be able to initialize with custom capacity and deinitialize the HashMap" {
    var hashmap = try Hashmap(i32, i32).init(testing.allocator, 5);
    defer hashmap.deinit();

    try testing.expectEqual(@as(usize, 0), hashmap.len);
    try testing.expectEqual(@as(usize, 5), hashmap.buckets.len);
}
