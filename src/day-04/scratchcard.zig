const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Scratchcard = struct {
    allocator: Allocator,
    card_number: u8,
    winning_numbers: []const u8,
    your_numbers: []const u8,

    const Self = @This();

    pub const ParseScratchcardError = error{
        InvalidLine,
    } || Allocator.Error;

    pub fn init(allocator: Allocator, input: []const u8) ParseScratchcardError!Self {
        var parts = std.mem.tokenizeAny(u8, input, ":|");

        const card_number_part = parts.next() orelse
            return ParseScratchcardError.InvalidLine;

        var card_parts = std.mem.tokenizeAny(u8, card_number_part, " ");

        _ = card_parts.next() orelse return ParseScratchcardError.InvalidLine;

        const card_number_string = card_parts.next() orelse
            return ParseScratchcardError.InvalidLine;
        const card_number = std.fmt.parseInt(u8, card_number_string, 10) catch {
            return ParseScratchcardError.InvalidLine;
        };

        const winning_numbers_part = parts.next() orelse
            return ParseScratchcardError.InvalidLine;

        const winning_numbers = try parseNumbers(allocator, winning_numbers_part);
        errdefer allocator.free(winning_numbers);

        const your_numbers_part = parts.next() orelse
            return ParseScratchcardError.InvalidLine;

        const your_numbers = try parseNumbers(allocator, your_numbers_part);

        return .{
            .allocator = allocator,
            .card_number = card_number,
            .winning_numbers = winning_numbers,
            .your_numbers = your_numbers,
        };
    }

    fn parseNumbers(allocator: Allocator, input: []const u8) ParseScratchcardError![]const u8 {
        var numbers_strings = std.mem.tokenizeAny(u8, input, " ");
        var numbers_list = std.ArrayList(u8).init(allocator);
        defer numbers_list.deinit();

        while (numbers_strings.next()) |number_string| {
            const number = std.fmt.parseInt(u8, number_string, 10) catch {
                return ParseScratchcardError.InvalidLine;
            };
            try numbers_list.append(number);
        }

        return try allocator.dupe(u8, numbers_list.items);
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.winning_numbers);
        self.allocator.free(self.your_numbers);
    }
};
