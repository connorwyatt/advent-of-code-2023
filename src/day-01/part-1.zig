const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const input = @embedFile("aoc-input/input.txt");

    print("Result: {}\n", .{try sum_of_calibration_values(input)});
}

const SumOfCalibrationValuesError = error{
    InvalidLine,
};

fn sum_of_calibration_values(input: []const u8) SumOfCalibrationValuesError!u17 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var result: u16 = 0;

    while (lines.next()) |line| {
        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;

        for (0..line.len) |i| {
            const character = line[i];

            if (!std.ascii.isDigit(character)) {
                continue;
            }

            if (first_digit == null) {
                first_digit = character;
            }
            last_digit = character;
        }

        if (first_digit == null or last_digit == null) {
            return SumOfCalibrationValuesError.InvalidLine;
        }

        result += (first_digit.? - '0') * 10 + (last_digit.? - '0');
    }

    return result;
}

test "works with example data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(142, sum_of_calibration_values(input));
}
