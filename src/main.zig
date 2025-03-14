const std = @import("std");
const mem = @import("std").mem;
const parser = @import("parser.zig");

const print = std.debug.print;
const exit_codes = [_][]const u8{ "q", "quit", "exit" };
const prompt = "R > ";

pub fn read(alloc: std.mem.Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    const line = try stdin.readUntilDelimiterAlloc(alloc, '\n', std.math.maxInt(usize));
    return line;
}

pub fn is_exit_code(input: []const u8) bool {
    for (exit_codes) |code| {
        if (mem.eql(u8, input, code)) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leak", .{});
        }
    }

    while (true) {
        print(prompt, .{});

        const input = try read(ally);
        defer ally.free(input);

        if (is_exit_code(input)) {
            return;
        }

        const tokens = try parser.lex(ally, input);
        defer tokens.deinit();

        for (tokens.items) |token| {
            print("{s} => {?}\n", .{ token.value, token.type });
        }
    }
}
