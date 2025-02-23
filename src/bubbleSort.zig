const std = @import("std");
const mem = std.mem;
const testing = std.testing;

const bubbleSortError = error{SliceVazio};

pub fn bubbleSort(comptime T: type, array: []T, compare: fn (*const T, *const T) bool) !void {
    if (array.len < 0) {
        return bubbleSortError.SliceVazio;
    }

    var arrLen = array.len;
    var swapped = true;

    while (swapped) {
        swapped = false;
        var newLen: usize = 0;

        for (0..arrLen - 1) |i| {
            if (compare(&array[i], &array[i + 1])) {
                mem.swap(T, &array[i], &array[i + 1]);
                swapped = true;
                newLen = i + 1;
            }
        }

        arrLen = newLen;
    }
}

test "1º Ordenação (Crescente)" {
    var arr = [_]i32{ 5, 8, 7, 9, 10, 20, 1, 2, 4, 6 };
    const expected = [_]i32{ 1, 2, 4, 5, 6, 7, 8, 9, 10, 20 };

    bubbleSort(i32, &arr, struct {
        fn compare(a: *const i32, b: *const i32) bool {
            return a.* > b.*;
        }
    }.compare);

    try std.testing.expectEqualSlices(i32, &expected, &arr);
}

test "2º Ordenação (Decrescente)" {
    var arr = [_]i32{ 5, 8, 7, 9, 10, 20, 1, 2, 4, 6 };
    const expected = [_]i32{ 20, 10, 9, 8, 7, 6, 5, 4, 2, 1 };
    bubbleSort(i32, &arr, struct {
        fn compare(a: *const i32, b: *const i32) bool {
            return a.* < b.*;
        }
    }.compare);

    try std.testing.expectEqualSlices(i32, &expected, &arr);
}
