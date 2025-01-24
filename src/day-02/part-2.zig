const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const Allocator = mem.Allocator;
const Game = @import("game.zig").Game;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print("Day 02 part 2 result: {}\n", .{try sumOfGamePowers(gpa.allocator(), input)});
}

fn sumOfGamePowers(allocator: Allocator, input: []const u8) !u32 {
    var lines = mem.tokenizeAny(u8, input, "\n");
    var sum_of_game_powers: u32 = 0;

    while (lines.next()) |line| {
        const game = try Game.parse(allocator, line);
        defer game.deinit();

        sum_of_game_powers += gamePower(&game);
    }

    return sum_of_game_powers;
}

fn gamePower(game: *const Game) u32 {
    var max_cube_set = Game.CubeSet{};

    for (game.cube_sets) |cube_set| {
        if (cube_set.red > max_cube_set.red) {
            max_cube_set.red = cube_set.red;
        }
        if (cube_set.green > max_cube_set.green) {
            max_cube_set.green = cube_set.green;
        }
        if (cube_set.blue > max_cube_set.blue) {
            max_cube_set.blue = cube_set.blue;
        }
    }

    return @as(u32, max_cube_set.red) * @as(u32, max_cube_set.green) * @as(u32, max_cube_set.blue);
}

test "works with example data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(2286, sumOfGamePowers(testing.allocator, input));
}

test "works with input data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(71585, sumOfGamePowers(testing.allocator, input));
}
