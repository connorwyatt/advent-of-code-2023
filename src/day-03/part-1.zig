const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const Allocator = mem.Allocator;

pub fn main() void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print("Day 03 part 1 result: {}\n", .{try sumOfPartNumbersInEngineSchematic(gpa.allocator(), input)});
}

const directions_to_check = [_]Vector2D{
    Vector2D.negative_y,
    Vector2D.negative_y.plus(Vector2D.positive_x),
    Vector2D.positive_x,
    Vector2D.positive_x.plus(Vector2D.positive_y),
    Vector2D.positive_y,
    Vector2D.positive_y.plus(Vector2D.negative_x),
    Vector2D.negative_x,
    Vector2D.negative_x.plus(Vector2D.negative_y),
};

fn sumOfPartNumbersInEngineSchematic(allocator: Allocator, input: []const u8) !u32 {
    var engine_schematic = try EngineSchematic.initFromString(allocator, input);
    defer engine_schematic.deinit();

    var result: u32 = 0;

    for (0..@intCast(engine_schematic.size.x)) |x| {
        for (0..@intCast(engine_schematic.size.y)) |y| {
            const point = Vector2D{ .x = @intCast(x), .y = @intCast(y) };

            const left_character = engine_schematic.items.get(point.plus(Vector2D.negative_x));
            if (left_character != null) {
                switch (left_character.?) {
                    .digit => continue,
                    .symbol => {},
                }
            }

            var current_point = point;
            var character_list = std.ArrayList(u8).init(allocator);
            defer character_list.deinit();

            var has_surrounding_symbol = false;

            while (true) : (current_point = current_point.plus(Vector2D.positive_x)) {
                const item = engine_schematic.items.get(current_point) orelse break;

                const digit = switch (item) {
                    .digit => |d| d,
                    .symbol => break,
                };

                try character_list.append(digit);

                if (!has_surrounding_symbol) {
                    for (directions_to_check) |direction| {
                        const neighbouring_item = engine_schematic.items.get(current_point.plus(direction)) orelse continue;

                        switch (neighbouring_item) {
                            .digit => continue,
                            .symbol => {
                                has_surrounding_symbol = true;
                                break;
                            },
                        }
                    }
                }
            }

            if (has_surrounding_symbol and character_list.items.len > 0) {
                result += std.fmt.parseInt(u32, character_list.items, 10) catch unreachable;
            }
        }
    }

    return result;
}

const Vector2D = struct {
    x: i32,
    y: i32,

    const Self = @This();

    const zero: Self = .{ .x = 0, .y = 0 };
    const negative_x: Self = .{ .x = -1, .y = 0 };
    const negative_y: Self = .{ .x = 0, .y = -1 };
    const positive_x: Self = .{ .x = 1, .y = 0 };
    const positive_y: Self = .{ .x = 0, .y = 1 };

    fn plus(self: *const Self, other: Self) Self {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

const EngineSchematic = struct {
    allocator: Allocator,
    items: std.AutoHashMap(Vector2D, EngineSchematicItem),
    size: Vector2D,

    const Self = @This();

    const EngineSchematicItem = union(enum) {
        digit: u8,
        symbol: u8,
    };

    const EngineSchematicInitFromStringError = error{
        OutOfMemory,
    };

    fn initFromString(allocator: Allocator, input: []const u8) EngineSchematicInitFromStringError!Self {
        var items = std.AutoHashMap(Vector2D, EngineSchematicItem).init(allocator);
        errdefer items.deinit();

        var size = Vector2D.zero;

        var x: i32 = 0;
        var y: i32 = 0;

        for (input) |character| {
            if (character == '\n') {
                x = 0;
                y += 1;
            } else {
                if (std.ascii.isDigit(character)) {
                    try items.put(.{ .x = x, .y = y }, .{ .digit = character });
                } else if (character != '.') {
                    try items.put(.{ .x = x, .y = y }, .{ .symbol = character });
                }
                x += 1;
            }

            if (x > size.x) {
                size.x = x;
            }
            if (y > size.y) {
                size.y = y;
            }
        }

        return .{ .allocator = allocator, .items = items, .size = size };
    }

    fn deinit(self: *Self) void {
        self.items.deinit();
    }
};

test "works for example input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(4361, sumOfPartNumbersInEngineSchematic(testing.allocator, input));
}

test "works for input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(553079, sumOfPartNumbersInEngineSchematic(testing.allocator, input));
}
