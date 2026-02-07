const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Hashmap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const GROWTH_FACTOR: usize = 2;
        const RESIZING_FACTOR: f32 = 0.75;

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
        pub fn put(self: *Self, key: K, value: V) !void {
            // Calcula Load Factor
            const load_factor = @as(f64, @floatFromInt(self.len)) / @as(f64, @floatFromInt(self.buckets.len));
            // Se for maior que tal número, temos que fazer resizing
            if (load_factor > RESIZING_FACTOR) try self.resizing();
            // Calcula Hash da chave
            const hash = hashKey(key);
            const index = hash % self.buckets.len;
            // Encontra Índice no Bucket
            var current = self.buckets[index];
            // Verifica se tal chave já existe, se sim entra no bucket existente
            while (current) |entry| {
                if (keysEqual(entry.key, key)) {
                    entry.value = value;
                    return;
                }
                current = entry.next;
            }
            // Insere o Entry criado dentro do bucket
            const new_entry = try self.allocator.create(Entry);
            new_entry.* = Entry{
                .key = key,
                .value = value,
                .next = self.buckets[index],
            };
            self.buckets[index] = new_entry;
            self.len += 1;
        }
        pub fn get(self: *Self, key: K) ?V {
            const hash = hashKey(key);
            const index = hash % self.buckets.len;

            var current = self.buckets[index];
            while (current) |entry| {
                if (keysEqual(entry.key, key)) {
                    return entry.value;
                }
                current = entry.next;
            }

            return null;
        }
        fn hashKey(key: K) usize {
            if (K == []const u8) {
                var value = 5381;
                for (key) |c| {
                    value = ((value << 5) +% value) +% c;
                }
                return value;
            } else if (@typeInfo(K) == .int) {
                return @as(usize, @intCast(key));
            } else {
                @compileError("Tipo não suportado");
            }
        }
        fn keysEqual(key: K, otherKey: K) bool {
            if (K != []const u8) {
                return key == otherKey;
            }

            return std.mem.eql(u8, key, otherKey);
        }
        fn resizing(self: *Self) !void {
            const new_capacity = self.buckets.len * GROWTH_FACTOR;
            const new_buckets = try self.allocator.alloc(?*Entry, new_capacity);

            for (new_buckets) |*bucket| {
                bucket.* = null;
            }

            for (self.buckets) |bucket| {
                var current = bucket;
                while (current) |entry| {
                    const next = entry.next;
                    const hash = hashKey(entry.key);
                    const new_index = hash % new_capacity;
                    entry.next = new_buckets[new_index];
                    new_buckets[new_index] = entry;

                    current = next;
                }
            }
            self.allocator.free(self.buckets);
            self.buckets = new_buckets;
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

test "It should be able to insert a value inside the HashMap" {
    var hashmap = try Hashmap(i32, i32).init(testing.allocator, 3);
    defer hashmap.deinit();

    try hashmap.put(0, 1);
    try hashmap.put(1, 2);

    try testing.expectEqual(@as(usize, 2), hashmap.len);
    try testing.expectEqual(@as(i32, 1), hashmap.get(0).?);
    try testing.expectEqual(@as(i32, 2), hashmap.get(1).?);
    try testing.expect(hashmap.get(200) == null);
}
