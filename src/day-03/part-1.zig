const std = @import("std");
const EngineSchematic = @import("engine_schematic.zig").EngineSchematic;
const Vector2D = @import("vector2d.zig").Vector2D;
const print = std.debug.print;
const mem = std.mem;
const Allocator = mem.Allocator;

pub fn main() void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print(
        "Day 03 part 1 result: {}\n",
        .{try sumOfPartNumbersInEngineSchematic(gpa.allocator(), input)},
    );
}

fn sumOfPartNumbersInEngineSchematic(
    allocator: Allocator,
    input: []const u8,
) !u32 {
    var engine_schematic = try EngineSchematic.initFromString(allocator, input);
    defer engine_schematic.deinit();

    var result: u32 = 0;

    var grid_iterator = engine_schematic.gridIterator();

    while (grid_iterator.next()) |point| {
        const left_character =
            engine_schematic.items.get(point.plus(Vector2D.negative_x));
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
                const surrounding_items = try engine_schematic.surroundingItems(
                    allocator,
                    &current_point,
                );
                defer surrounding_items.deinit();

                for (surrounding_items.items) |neighbouring_item| {
                    switch (neighbouring_item.item) {
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
            result += std.fmt.parseInt(u32, character_list.items, 10) catch
                unreachable;
        }
    }

    return result;
}

test "works for example input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(
        4361,
        sumOfPartNumbersInEngineSchematic(testing.allocator, input),
    );
}

test "works for input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(
        553079,
        sumOfPartNumbersInEngineSchematic(testing.allocator, input),
    );
}
