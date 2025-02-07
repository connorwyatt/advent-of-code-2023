const std = @import("std");
const Scratchcard = @import("scratchcard.zig").Scratchcard;
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print(
        "Day 04 part 1 result: {}\n",
        .{
            try calculateScratchcardPoints(gpa.allocator(), input),
        },
    );
}

fn calculateScratchcardPoints(allocator: Allocator, input: []const u8) !u16 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var points: u16 = 0;

    while (lines.next()) |line| {
        const scratchcard = try Scratchcard.init(allocator, line);
        defer scratchcard.deinit();

        var matching_numbers: u16 = 0;

        for (scratchcard.your_numbers) |your_number| {
            for (scratchcard.winning_numbers) |winning_number| {
                if (your_number == winning_number) {
                    matching_numbers += 1;
                    break;
                }
            }
        }

        if (matching_numbers > 0) {
            points += std.math.pow(u16, 2, matching_numbers - 1);
        }
    }

    return points;
}

test "works for example input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(
        13,
        calculateScratchcardPoints(testing.allocator, input),
    );
}

test "works for input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(
        19135,
        calculateScratchcardPoints(testing.allocator, input),
    );
}
