pub const Vector2D = struct {
    x: i32,
    y: i32,

    const Self = @This();

    pub const zero: Self = .{ .x = 0, .y = 0 };
    pub const negative_x: Self = .{ .x = -1, .y = 0 };
    pub const negative_y: Self = .{ .x = 0, .y = -1 };
    pub const positive_x: Self = .{ .x = 1, .y = 0 };
    pub const positive_y: Self = .{ .x = 0, .y = 1 };

    pub const directions = [_]Vector2D{
        negative_y,
        negative_y.plus(positive_x),
        positive_x,
        positive_x.plus(positive_y),
        positive_y,
        positive_y.plus(negative_x),
        negative_x,
        negative_x.plus(negative_y),
    };

    pub fn plus(self: *const Self, other: Self) Self {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }
};
