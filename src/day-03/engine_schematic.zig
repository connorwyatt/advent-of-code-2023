const std = @import("std");
const Vector2D = @import("vector2d.zig").Vector2D;
const print = std.debug.print;
const mem = std.mem;
const Allocator = mem.Allocator;

pub const EngineSchematic = struct {
    allocator: Allocator,
    items: std.AutoHashMap(Vector2D, EngineSchematicItem),
    size: Vector2D,

    const Self = @This();

    pub const EngineSchematicItem = union(enum) {
        digit: u8,
        symbol: u8,
    };

    pub const EngineSchematicInitFromStringError = error{
        OutOfMemory,
    };

    pub fn initFromString(
        allocator: Allocator,
        input: []const u8,
    ) EngineSchematicInitFromStringError!Self {
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
                    try items.put(
                        .{ .x = x, .y = y },
                        .{ .digit = character },
                    );
                } else if (character != '.') {
                    try items.put(
                        .{ .x = x, .y = y },
                        .{ .symbol = character },
                    );
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

        return .{
            .allocator = allocator,
            .items = items,
            .size = size,
        };
    }

    pub const Entry = struct {
        point: Vector2D,
        item: EngineSchematicItem,
    };

    /// Returns an array list of surrounding items that are not empty.
    pub fn surroundingItems(
        self: *Self,
        allocator: Allocator,
        point: *Vector2D,
    ) !std.ArrayList(Entry) {
        var surrounding_item_points = std.ArrayList(Entry).init(allocator);

        for (Vector2D.directions) |direction| {
            const surrounding_point = point.plus(direction);

            if (self.items.get(surrounding_point)) |item| {
                try surrounding_item_points.append(.{
                    .point = surrounding_point,
                    .item = item,
                });
            }
        }

        return surrounding_item_points;
    }

    pub const GridIterator = struct {
        size: Vector2D,
        index: usize = 0,

        const IteratorSelf = @This();

        pub fn next(self: *IteratorSelf) ?Vector2D {
            const index: i32 = @intCast(self.index);
            self.index += 1;
            const point = Vector2D{
                .x = @rem(index, self.size.x),
                .y = @divTrunc(index, self.size.x),
            };
            return if (isInGrid(self.size, point)) point else null;
        }

        fn isInGrid(grid: Vector2D, position: Vector2D) bool {
            return position.x >= 0 and
                position.x < grid.x and
                position.y >= 0 and
                position.y < grid.y;
        }
    };

    pub fn gridIterator(self: *EngineSchematic) GridIterator {
        return .{ .size = self.size };
    }

    pub fn deinit(self: *Self) void {
        self.items.deinit();
    }
};

test "grid iterator works" {
    const testing = std.testing;

    var grid_iterator = EngineSchematic.GridIterator{
        .size = .{
            .x = 3,
            .y = 2,
        },
    };

    try testing.expectEqual(Vector2D{ .x = 0, .y = 0 }, grid_iterator.next());
    try testing.expectEqual(Vector2D{ .x = 1, .y = 0 }, grid_iterator.next());
    try testing.expectEqual(Vector2D{ .x = 2, .y = 0 }, grid_iterator.next());
    try testing.expectEqual(Vector2D{ .x = 0, .y = 1 }, grid_iterator.next());
    try testing.expectEqual(Vector2D{ .x = 1, .y = 1 }, grid_iterator.next());
    try testing.expectEqual(Vector2D{ .x = 2, .y = 1 }, grid_iterator.next());
}
