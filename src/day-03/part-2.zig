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
        "Day 03 part 2 result: {}\n",
        .{
            try sumOfGearRatiosInEngineSchematic(gpa.allocator(), input),
        },
    );
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

fn sumOfGearRatiosInEngineSchematic(
    allocator: Allocator,
    input: []const u8,
) !u32 {
    var engine_schematic = try EngineSchematic.initFromString(allocator, input);
    defer engine_schematic.deinit();

    var result: u32 = 0;

    var items_iterator = engine_schematic.items.iterator();

    while (items_iterator.next()) |entry| {
        const item = entry.value_ptr.*;
        switch (item) {
            .digit => continue,
            .symbol => |s| {
                if (s != '*') {
                    continue;
                }
            },
        }

        const surrounding_number_points = try surroundingNumberStartingPoints(
            allocator,
            &engine_schematic,
            entry.key_ptr,
        );
        defer surrounding_number_points.deinit();

        if (surrounding_number_points.items.len != 2) {
            continue;
        }

        const item1 = surrounding_number_points.items[0];
        const item2 = surrounding_number_points.items[1];

        result +=
            numberStartingAt(&engine_schematic, &item1) *
            numberStartingAt(&engine_schematic, &item2);
    }

    return result;
}

fn surroundingNumberStartingPoints(
    allocator: Allocator,
    engine_schematic: *EngineSchematic,
    point: *Vector2D,
) !std.ArrayList(Vector2D) {
    var surrounding_items = try engine_schematic.surroundingItems(
        allocator,
        point,
    );
    defer surrounding_items.deinit();

    var surrounding_number_points_map = std.AutoHashMap(Vector2D, void).init(
        allocator,
    );
    defer surrounding_number_points_map.deinit();

    for (surrounding_items.items) |item| {
        switch (item.item) {
            .symbol => continue,
            .digit => {},
        }

        var current_point = item.point;
        while (true) {
            const next_point = current_point.plus(Vector2D.negative_x);
            const next_entry =
                engine_schematic.items.getPtr(next_point) orelse
                break;

            switch (next_entry.*) {
                .digit => {},
                .symbol => break,
            }
            current_point = next_point;
        }

        try surrounding_number_points_map.put(current_point, undefined);
    }

    var surrounding_number_points = std.ArrayList(Vector2D).init(allocator);
    var iterator = surrounding_number_points_map.keyIterator();

    while (iterator.next()) |p| {
        try surrounding_number_points.append(p.*);
    }

    return surrounding_number_points;
}

fn numberStartingAt(engine_schematic: *const EngineSchematic, point: *const Vector2D) u32 {
    var buffer: [5]u8 = undefined;

    var current_point = point.*;
    var current_index: usize = 0;
    while (true) {
        const item = engine_schematic.items.get(current_point) orelse break;

        switch (item) {
            .symbol => break,
            .digit => |d| {
                buffer[current_index] = d;
            },
        }

        current_point = current_point.plus(Vector2D.positive_x);
        current_index += 1;
    }

    return std.fmt.parseInt(u32, buffer[0..current_index], 10) catch
        unreachable;
}

test "works for example input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(
        467835,
        sumOfGearRatiosInEngineSchematic(testing.allocator, input),
    );
}

test "works for input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(
        84363105,
        sumOfGearRatiosInEngineSchematic(testing.allocator, input),
    );
}
