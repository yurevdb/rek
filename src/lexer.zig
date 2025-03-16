const std = @import("std");
const mem = @import("std").mem;
const print = std.debug.print;
const assert = std.debug.assert;

const TokenType = enum { VALUE, ADD, SUBTRACT, MULTIPLY, DIVIDE, POWER, L_BRACKET, R_BRACKET };

const Token = struct {
    type: TokenType,
    value: []const u8,

    pub fn init(token_type: TokenType, value: []const u8) Token {
        return Token{ .type = token_type, .value = value };
    }
};

const token_list = [_]u8{ '+', '-', '*', '/', '^', '(', '{', '[', ']', '}', ')' };
const token_value_allowed = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' };

pub const LexerError = error{
    InvalidCharacter,
    OutOfMemory,
    OutOfBounds,
};

pub fn lex(alloc: std.mem.Allocator, input: []const u8) LexerError!std.ArrayList(Token) {
    var tokens = std.ArrayList(Token).init(alloc);
    var index: u16 = 0;
    while (index < input.len) : (index += 1) {
        // NOTE: best way I found to 'cast' a character to a string
        const c = input[index .. index + 1];

        // No need for now to look at white spaces
        if (c[0] == ' ') continue;

        const token = switch (c[0]) {
            '+' => Token.init(TokenType.ADD, c),
            '-' => Token.init(TokenType.SUBTRACT, c),
            '*' => Token.init(TokenType.MULTIPLY, c),
            '/' => Token.init(TokenType.DIVIDE, c),
            '^' => Token.init(TokenType.POWER, c),
            '(', '{', '[' => Token.init(TokenType.L_BRACKET, c),
            ')', '}', ']' => Token.init(TokenType.R_BRACKET, c),
            else => blk: {
                const start = index;
                defer index -= 1;

                // Get the index of the next token
                while (index < input.len) : (index += 1) {
                    const next_c = input[index];
                    if (contains(u8, &token_list, next_c)) {
                        break;
                    }
                }

                const val = remove_trailing_whitespaces(input[start..index]);
                for (val) |char| {
                    if (!contains(u8, &token_value_allowed, char)) {
                        return LexerError.InvalidCharacter;
                    }
                }

                break :blk Token.init(TokenType.VALUE, input[start..index]);
            },
        };

        try tokens.append(token);
    }
    return tokens;
}

fn remove_trailing_whitespaces(input: []const u8) []const u8 {
    var i: usize = input.len;

    // Case for len = 0
    if (i == 0) {
        return "";
    }

    // Case for len = 1
    if (i == 1) {
        if (input[0] == ' ') {
            return "";
        } else {
            return &[1]u8{input[0]};
        }
    }

    assert(i > 1);
    // Length to index
    i -= 1;

    // Case for len > 1
    var idx_last_char: usize = 0;
    while (i > 0) : (i -= 1) {
        const c = input[i];
        if (c == ' ') continue;
        idx_last_char = i;
        break;
    }
    return input[0..idx_last_char];
}

fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |thing| {
        if (thing == needle) {
            return true;
        }
    }
    return false;
}

test "expect no error for '1-1'" {
    const input = "1-1";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) std.testing.expect(false) catch @panic("Test Failed");
    }
    const tokens = try lex(ally, input);
    tokens.deinit();
}

test "expect no error for '1 - 1'" {
    const input = "1 - 1";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) std.testing.expect(false) catch @panic("Test Failed");
    }
    const tokens = try lex(ally, input);
    tokens.deinit();
}

test "expect error for '1 1 - 1'" {
    const input = "1 1 - 1";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) std.testing.expect(false) catch @panic("Test Failed");
    }
    const actual = lex(ally, input);
    _ = try std.testing.expectError(LexerError.InvalidCharacter, actual);
}

test "expect error for '1e1 - 1'" {
    const input = "1e1 - 1";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) std.testing.expect(false) catch @panic("Test Failed");
    }
    const actual = lex(ally, input);
    _ = try std.testing.expectError(LexerError.InvalidCharacter, actual);
}

test "expect no error for '1.1 - 1'" {
    const input = "1.1 - 1";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) std.testing.expect(false) catch @panic("Test Failed");
    }
    const tokens = try lex(ally, input);
    tokens.deinit();
}

test "expect no error for '123.123 + 123.456 * 123.321'" {
    const input = "123.123 + 123.456 * 123.321";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) std.testing.expect(false) catch @panic("Test Failed");
    }
    const tokens = try lex(ally, input);
    tokens.deinit();
}
