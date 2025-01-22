const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const input = @embedFile("aoc-input/input.txt");

    print("Day 01 part 2 result: {}\n", .{try sum_of_calibration_values(input)});
}

const SumOfCalibrationValuesError = error{
    InvalidLine,
};

const DigitString = struct { string: []const u8, value: u8 };

const digit_strings = [_]DigitString{
    .{ .string = "zero", .value = 0 },
    .{ .string = "one", .value = 1 },
    .{ .string = "two", .value = 2 },
    .{ .string = "three", .value = 3 },
    .{ .string = "four", .value = 4 },
    .{ .string = "five", .value = 5 },
    .{ .string = "six", .value = 6 },
    .{ .string = "seven", .value = 7 },
    .{ .string = "eight", .value = 8 },
    .{ .string = "nine", .value = 9 },
};

fn sum_of_calibration_values(input: []const u8) SumOfCalibrationValuesError!u16 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var result: u16 = 0;
    result = 0;

    while (lines.next()) |line| {
        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;

        for (0..line.len) |i| {
            const character = line[i];

            if (std.ascii.isDigit(character)) {
                const digit = character - '0';
                if (first_digit == null) {
                    first_digit = digit;
                }
                last_digit = digit;
            } else {
                const line_remainder = line[i..line.len];

                for (digit_strings) |digit_string| {
                    if (std.mem.startsWith(u8, line_remainder, digit_string.string)) {
                        if (first_digit == null) {
                            first_digit = digit_string.value;
                        }
                        last_digit = digit_string.value;
                        break;
                    }
                }
            }
        }

        if (first_digit == null or last_digit == null) {
            return SumOfCalibrationValuesError.InvalidLine;
        }

        result += first_digit.? * 10 + last_digit.?;
    }

    return result;
}

test "works with example data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input-2.txt");

    try testing.expectEqual(281, sum_of_calibration_values(input));
}

test "works with input data" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(54885, sum_of_calibration_values(input));
}
