const std = @import("std");
const mem = @import("std").mem;

pub fn main() !void {
    const prompt = "R > ";

    while (true) {
        try print(prompt, .{});
        const input = try read();

        if (is_exit_code(input)) {
            return;
        }

        try print("{s}\n", .{input});
    }
}

pub fn is_exit_code(input: []const u8) bool {
    const exit_codes = [_][]const u8{ "q", "quit", "exit" };

    for (exit_codes) |code| {
        if (mem.eql(u8, input, code)) {
            return true;
        }
    }

    return false;
}

pub fn read() ![]const u8 {
    var input: [1024]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    const bytes_read = try stdin.readUntilDelimiter(&input, '\n');
    return bytes_read;
}

/// Prints a line to stdout
pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);

    try bw.flush(); // Don't forget to flush!
}

test "simple test" {
    try std.testing.expectEqual(1, 1);
}
