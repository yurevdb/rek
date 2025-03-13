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

    pub fn init(token_type: TokenType, value: u8) Token {
        return Token{ .type = token_type, .value = value };
    }
};

const exit_codes = [_][]const u8{ "q", "quit", "exit" };
const token_list = [_]u8{ '+', '-', '*', '/', '^', '(', '{', '[', ']', '}', ')' };
const prompt = "R > ";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leak", .{});
        }
    }

    while (true) {
        try print(prompt, .{});
        // need to allocate this info
        const input = try read(ally);
        defer ally.free(input);

        if (is_exit_code(input)) {
            return;
        }

        const tokens = try lex(ally, input);
        defer tokens.deinit();

        for (tokens.items) |token| {
            try print("{c} => {any}\n", .{ token.value, token.type });
        }
    }
}

pub fn lex(alloc: std.mem.Allocator, input: []const u8) !std.ArrayList(Token) {
    var tokens = std.ArrayList(Token).init(alloc);
    var index: u16 = 0;
    while (index < input.len) {
        const c = input[index];
        index += 1;

        // No need for now to look at white spaces
        if (c == ' ') continue;

        //const value: []const u8 = &[_]u8{c};

        const token = switch (c) {
            '+' => Token.init(TokenType.ADD, c),
            '-' => Token.init(TokenType.SUBTRACT, c),
            '*' => Token.init(TokenType.MULTIPLY, c),
            '/' => Token.init(TokenType.DIVIDE, c),
            '^' => Token.init(TokenType.POWER, c),
            '(', '{', '[' => Token.init(TokenType.BRACKET_OPEN, c),
            ')', '}', ']' => Token.init(TokenType.BRACKET_CLOSE, c),
            else => Token.init(TokenType.VALUE, c),
            //else => blk: {
            //    // TODO: look further in the input to find a predefined token
            //    var length: u16 = 0;
            //    var is_token: bool = false;
            //    while (!is_token and index < input.len) {
            //        const temp_c = input[index];
            //        if (in_slice(u8, &token_list, temp_c)) {
            //            is_token = true;
            //            index -= 1;
            //        } else {
            //            index += 1;
            //            length += 1;
            //        }
            //    }
            //    break :blk Token.init(TokenType.VALUE, input[index - length .. index]);
            //},
        };
        try tokens.append(token);
    }
    return tokens;
}

pub fn in_slice(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |thing| {
        if (thing == needle) {
            return true;
        }
    }
    return false;
}

pub fn is_exit_code(input: []const u8) bool {
    for (exit_codes) |code| {
        if (mem.eql(u8, input, code)) {
            return true;
        }
    }
    return false;
}

pub fn read(alloc: std.mem.Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    const line = try stdin.readUntilDelimiterAlloc(alloc, '\n', std.math.maxInt(usize));
    return line;
}

/// Prints a line to stdout
pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    try stdout.print(format, args);
    try bw.flush(); // Don't forget to flush!
}
