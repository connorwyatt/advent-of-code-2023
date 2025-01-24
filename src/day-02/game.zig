const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub const Game = struct {
    allocator: Allocator,
    id: u8,
    cube_sets: []CubeSet,

    const Self = @This();

    pub const CubeSet = struct { red: u8 = 0, green: u8 = 0, blue: u8 = 0 };

    pub const ParseGameError = error{
        OutOfMemory,
        InvalidLine,
    };

    pub fn parse(allocator: Allocator, line: []const u8) ParseGameError!Self {
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

    pub fn deinit(self: *const Self) void {
        self.allocator.free(self.cube_sets);
    }
};
