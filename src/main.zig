const std = @import("std");

pub fn main() !void {
    const prompt = "R > ";

    while (true) {
        try print(prompt, .{});
        const input = try read();
        try print("{s}\n", .{input});
    }
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
