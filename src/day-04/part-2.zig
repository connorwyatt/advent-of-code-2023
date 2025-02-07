const std = @import("std");
const Scratchcard = @import("scratchcard.zig").Scratchcard;
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print(
        "Day 04 part 2 result: {}\n",
        .{
            try totalScratchcards(gpa.allocator(), input),
        },
    );
}

fn totalScratchcards(allocator: Allocator, input: []const u8) !u32 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var scratchcard_counts = std.AutoHashMap(u8, u32).init(allocator);
    defer scratchcard_counts.deinit();

    while (lines.next()) |line| {
        const scratchcard = try Scratchcard.init(allocator, line);
        defer scratchcard.deinit();

        try incrementScratchcardCount(
            &scratchcard_counts,
            scratchcard.card_number,
            1,
        );

        var matching_numbers: u8 = 0;

        for (scratchcard.your_numbers) |your_number| {
            for (scratchcard.winning_numbers) |winning_number| {
                if (your_number == winning_number) {
                    matching_numbers += 1;
                    break;
                }
            }
        }

        const current_scratchcard_count =
            scratchcard_counts.get(scratchcard.card_number).?;

        var i = scratchcard.card_number + 1;
        while (i <= scratchcard.card_number + matching_numbers) : (i += 1) {
            try incrementScratchcardCount(
                &scratchcard_counts,
                i,
                current_scratchcard_count,
            );
        }
    }

    return sumScratchcardCounts(&scratchcard_counts);
}

fn incrementScratchcardCount(
    scratchcard_counts: *std.AutoHashMap(u8, u32),
    card_number: u8,
    count: u32,
) Allocator.Error!void {
    const entry = try scratchcard_counts.getOrPutValue(card_number, 0);

    entry.value_ptr.* += count;
}

fn sumScratchcardCounts(scratchcard_counts: *std.AutoHashMap(u8, u32)) u32 {
    var total: u32 = 0;
    var scratchcard_counts_iterator = scratchcard_counts.valueIterator();

    while (scratchcard_counts_iterator.next()) |count| {
        total += count.*;
    }

    return total;
}

test "works for example input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(
        30,
        totalScratchcards(testing.allocator, input),
    );
}

test "works for input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(
        5704953,
        totalScratchcards(testing.allocator, input),
    );
}
