const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const Allocator = mem.Allocator;
const Game = @import("game.zig").Game;

const total_red_cubes = 12;
const total_green_cubes = 13;
const total_blue_cubes = 14;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print("Day 02 part 1 result: {}\n", .{try sumOfPossibleGameIds(gpa.allocator(), input)});
}

fn sumOfPossibleGameIds(allocator: Allocator, input: []const u8) !u16 {
    var lines = mem.tokenizeAny(u8, input, "\n");
    var possible_games: u16 = 0;

    while (lines.next()) |line| {
        const game = try Game.parse(allocator, line);
        defer game.deinit();

        if (isGamePossible(&game)) {
            possible_games += game.id;
        }
    }

    return possible_games;
}

fn isGamePossible(game: *const Game) bool {
    for (game.cube_sets) |cube_set| {
        if (cube_set.red > total_red_cubes) {
            return false;
        } else if (cube_set.green > total_green_cubes) {
            return false;
        } else if (cube_set.blue > total_blue_cubes) {
            return false;
        }
    }

    return true;
}

test "works with example data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(8, sumOfPossibleGameIds(testing.allocator, input));
}

test "works with input data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(2331, sumOfPossibleGameIds(testing.allocator, input));
}
