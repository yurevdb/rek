const std = @import("std");
const mem = @import("std").mem;

const TokenType = enum {
    VALUE,
    ADD,
    SUBTRACT,
    MULTIPLY,
    DIVIDE,
    POWER,
    BRACKET_OPEN,
    BRACKET_CLOSE,
};

const Token = struct {
    type: TokenType,
    value: u8,
};

const exit_codes = [_][]const u8{ "q", "quit", "exit" };
const prompt = "R > ";

pub fn main() !void {
    while (true) {
        try print(prompt, .{});
        const input = try read();

        if (is_exit_code(input)) {
            return;
        }

        const tokens = lex(input);
        for (tokens) |token| {
            try print("{c} => {any}\n", .{ token.value, token.type });
        }
    }
}

pub fn lex(input: []const u8) []Token {
    var tokens: [512]Token = undefined;
    var counter: u16 = 0;
    for (input) |c| {
        // No need for now to look at white spaces
        if (c == ' ') continue;
        tokens[counter] = switch (c) {
            '+' => Token{ .type = TokenType.ADD, .value = c },
            '-' => Token{ .type = TokenType.SUBTRACT, .value = c },
            '*' => Token{ .type = TokenType.MULTIPLY, .value = c },
            '/' => Token{ .type = TokenType.DIVIDE, .value = c },
            '^' => Token{ .type = TokenType.POWER, .value = c },
            '(', '{', '[' => Token{ .type = TokenType.BRACKET_OPEN, .value = c },
            ')', '}', ']' => Token{ .type = TokenType.BRACKET_CLOSE, .value = c },
            else => Token{ .type = TokenType.VALUE, .value = c },
        };
        counter += 1;
    }
    return tokens[0..counter];
}

pub fn is_exit_code(input: []const u8) bool {
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
    return input[0..bytes_read.len];
}

/// Prints a line to stdout
pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    try stdout.print(format, args);
    try bw.flush(); // Don't forget to flush!
}
