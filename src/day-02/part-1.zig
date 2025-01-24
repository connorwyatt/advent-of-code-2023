const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const Allocator = mem.Allocator;

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

const Game = struct {
    allocator: Allocator,
    id: u8,
    cube_sets: []CubeSet,

    const Self = @This();

    const CubeSet = struct { red: u8 = 0, green: u8 = 0, blue: u8 = 0 };

    const ParseGameError = error{
        OutOfMemory,
        InvalidLine,
    };

    fn parse(allocator: Allocator, line: []const u8) ParseGameError!Self {
        var tokens = mem.tokenizeAny(u8, line, ":;");

        const game_id_string = tokens.next() orelse return ParseGameError.InvalidLine;

        const game_id = std.fmt.parseInt(u8, game_id_string[5..], 10) catch return ParseGameError.InvalidLine;

        var cube_sets_list = std.ArrayList(CubeSet).init(allocator);
        defer cube_sets_list.deinit();

        while (tokens.next()) |cube_set_string| {
            var cube_set = CubeSet{};
            var colored_cubes_strings = mem.tokenizeAny(u8, cube_set_string, ",");

            while (colored_cubes_strings.next()) |colored_cubes_string| {
                var colored_cube_string_parts = mem.tokenizeAny(u8, colored_cubes_string, " ");
                const count_string = colored_cube_string_parts.next() orelse return ParseGameError.InvalidLine;

                const count = std.fmt.parseInt(u8, count_string, 10) catch return ParseGameError.InvalidLine;

                const color = colored_cube_string_parts.next() orelse return ParseGameError.InvalidLine;

                if (mem.eql(u8, color, "red")) {
                    cube_set.red = count;
                } else if (mem.eql(u8, color, "green")) {
                    cube_set.green = count;
                } else if (mem.eql(u8, color, "blue")) {
                    cube_set.blue = count;
                } else {
                    return ParseGameError.InvalidLine;
                }
            }

            try cube_sets_list.append(cube_set);
        }

        const cube_sets = try allocator.dupe(CubeSet, cube_sets_list.items);

        return Self{ .allocator = allocator, .id = game_id, .cube_sets = cube_sets };
    }

    fn deinit(self: *const Self) void {
        self.allocator.free(self.cube_sets);
    }
};

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
