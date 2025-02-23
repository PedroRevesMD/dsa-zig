const std = @import("std");
const mem = std.mem;
const testing = std.testing;

pub fn quickSort(array: []u32, left: usize, right: usize) void {
    if (array.len < 0 or left >= right) return;
    const pivot = partition(array, left, right);
    if (pivot > 0) quickSort(array, left, pivot - 1);
    quickSort(array, pivot + 1, right);
}

fn partition(array: []u32, left: usize, right: usize) usize {
    const pivot = array[right];
    var i = left;
    var j = left;
    while (j < right) : (j += 1) {
        if (array[j] < pivot) {
            mem.swap(u32, &array[i], &array[j]);
            i += 1;
        }
    }
    mem.swap(u32, &array[i], &array[j]);
    return i;
}

test "Ordenação QuickSort" {
    var arr = [_]u32{ 2, 3, 5, 6, 7, 4, 1, 15, 9, 10, 20, 8 };
    const expected = [_]u32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20 };

    quickSort(&arr, 0, arr.len - 1);
    try testing.expectEqualSlices(u32, &expected, &arr);
}

test "Ordenação QuickSort (1 valor)" {
    var arr = [_]u32{2};
    const expected = [_]u32{2};

    quickSort(&arr, 0, arr.len - 1);
    try testing.expectEqualSlices(u32, &expected, &arr);
}

test "Ordenação QuickSort (nulo)" {
    var arr = [_]u32{};
    quickSort(&arr, 0, 0);
    const length = arr.len;
    try testing.expect(length == 0);
}
