const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const input = @embedFile("aoc-input/input.txt");

    print(
        "Day 05 part 1 result: {}\n",
        .{
            try lowestInitialSeedLocationNumber(gpa.allocator(), input),
        },
    );
}

fn lowestInitialSeedLocationNumber(allocator: Allocator, input: []const u8) !u64 {
    const almanac = try Almanac.init(allocator, input);
    defer almanac.deinit();

    var lowest_location_number: ?u64 = null;

    for (almanac.seeds) |seed| {
        var value = seed;
        value = mapValue(value, almanac.seed_to_soil_maps);
        value = mapValue(value, almanac.soil_to_fertilizer_maps);
        value = mapValue(value, almanac.fertilizer_to_water_maps);
        value = mapValue(value, almanac.water_to_light_maps);
        value = mapValue(value, almanac.light_to_temperature_maps);
        value = mapValue(value, almanac.temperature_to_humidity_maps);
        value = mapValue(value, almanac.humidity_to_location_maps);

        if (lowest_location_number) |lln| {
            if (value < lln) {
                lowest_location_number = value;
            }
        } else {
            lowest_location_number = value;
        }
    }

    return lowest_location_number.?;
}

fn mapValue(value: u64, maps: []const Map) u64 {
    return for (maps) |map| {
        const lower_bound = map.source_range_start;
        const upper_bound = lower_bound + map.range_length;

        if (lower_bound <= value and value < upper_bound) {
            break map.destination_range_start + value - map.source_range_start;
        }
    } else value;
}

const Almanac = struct {
    allocator: Allocator,
    seeds: []const u64,
    seed_to_soil_maps: []const Map,
    soil_to_fertilizer_maps: []const Map,
    fertilizer_to_water_maps: []const Map,
    water_to_light_maps: []const Map,
    light_to_temperature_maps: []const Map,
    temperature_to_humidity_maps: []const Map,
    humidity_to_location_maps: []const Map,

    const Self = @This();

    const ParseAlmanacError = error{
        InvalidInput,
    } || Allocator.Error;

    fn init(allocator: Allocator, input: []const u8) ParseAlmanacError!Self {
        var lines = std.mem.splitAny(u8, input, "\n");

        const seeds_line = lines.next() orelse
            return ParseAlmanacError.InvalidInput;
        const seeds = try allocParseSeeds(allocator, seeds_line);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;
        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const seed_to_soil_maps = try allocParseMaps(allocator, &lines);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const soil_to_fertilizer_maps = try allocParseMaps(allocator, &lines);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const fertilizer_to_water_maps = try allocParseMaps(allocator, &lines);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const water_to_light_maps = try allocParseMaps(allocator, &lines);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const light_to_temperature_maps = try allocParseMaps(allocator, &lines);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const temperature_to_humidity_maps = try allocParseMaps(allocator, &lines);

        _ = lines.next() orelse return ParseAlmanacError.InvalidInput;

        const humidity_to_location_maps = try allocParseMaps(allocator, &lines);

        return .{
            .allocator = allocator,
            .seeds = seeds,
            .seed_to_soil_maps = seed_to_soil_maps,
            .soil_to_fertilizer_maps = soil_to_fertilizer_maps,
            .fertilizer_to_water_maps = fertilizer_to_water_maps,
            .water_to_light_maps = water_to_light_maps,
            .light_to_temperature_maps = light_to_temperature_maps,
            .temperature_to_humidity_maps = temperature_to_humidity_maps,
            .humidity_to_location_maps = humidity_to_location_maps,
        };
    }

    fn deinit(self: *const Self) void {
        self.allocator.free(self.seeds);
        self.allocator.free(self.seed_to_soil_maps);
        self.allocator.free(self.soil_to_fertilizer_maps);
        self.allocator.free(self.fertilizer_to_water_maps);
        self.allocator.free(self.water_to_light_maps);
        self.allocator.free(self.light_to_temperature_maps);
        self.allocator.free(self.temperature_to_humidity_maps);
        self.allocator.free(self.humidity_to_location_maps);
    }

    fn allocParseSeeds(allocator: Allocator, seeds_line: []const u8) ParseAlmanacError![]u64 {
        var seed_strings = std.mem.tokenizeAny(u8, seeds_line, ": ");
        _ = seed_strings.next() orelse return ParseAlmanacError.InvalidInput;

        var seeds_list = std.ArrayList(u64).init(allocator);
        defer seeds_list.deinit();

        while (seed_strings.next()) |seed_string| {
            const seed = std.fmt.parseInt(u64, seed_string, 10) catch
                return ParseAlmanacError.InvalidInput;
            try seeds_list.append(seed);
        }

        return allocator.dupe(u64, seeds_list.items);
    }

    fn allocParseMaps(
        allocator: Allocator,
        lines: *std.mem.SplitIterator(u8, .any),
    ) ParseAlmanacError![]const Map {
        var maps = std.ArrayList(Map).init(allocator);
        defer maps.deinit();

        while (lines.next()) |line| {
            if (line.len == 0) {
                break;
            }

            var value_strings = std.mem.splitAny(u8, line, " ");

            const destination_string = value_strings.next() orelse
                return ParseAlmanacError.InvalidInput;
            const source_string = value_strings.next() orelse
                return ParseAlmanacError.InvalidInput;
            const length_string = value_strings.next() orelse
                return ParseAlmanacError.InvalidInput;

            const destination_range_start = std.fmt.parseInt(u64, destination_string, 10) catch
                return ParseAlmanacError.InvalidInput;
            const source_range_start = std.fmt.parseInt(u64, source_string, 10) catch
                return ParseAlmanacError.InvalidInput;
            const range_length = std.fmt.parseInt(u64, length_string, 10) catch
                return ParseAlmanacError.InvalidInput;

            try maps.append(.{
                .destination_range_start = destination_range_start,
                .source_range_start = source_range_start,
                .range_length = range_length,
            });
        }

        return allocator.dupe(Map, maps.items);
    }
};

const Map = struct {
    destination_range_start: u64,
    source_range_start: u64,
    range_length: u64,
};

test "works for example input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/example-input.txt");

    try testing.expectEqual(
        35,
        lowestInitialSeedLocationNumber(testing.allocator, input),
    );
}

test "works for input" {
    const testing = std.testing;

    const input = @embedFile("aoc-input/input.txt");

    try testing.expectEqual(
        825516882,
        lowestInitialSeedLocationNumber(testing.allocator, input),
    );
}
