test "It should be able to Initialize an empty LinkedList" {
    var linkedlist = LinkedList(i32).init(testing.allocator);
    defer linkedlist.deinit();

    try testing.expectEqual(@as(usize, 0), linkedlist.len);
    try testing.expect(linkedlist.head == null);
    try testing.expect(linkedlist.tail == null);
}
