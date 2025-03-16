const std = @import("std");
const mem = @import("std").mem;
const lexer = @import("lexer.zig");
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

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    const ally = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leak", .{});
        }
    }

    while (true) {
        print(prompt, .{});

        const input = read(ally) catch |err| switch (err) {
            else => {
                print("Could not read input.\n", .{});
                continue;
            },
        };
        defer ally.free(input);

        if (is_exit_code(input)) {
            return;
        }

        const tokens = lexer.lex(ally, input) catch |err| switch (err) {
            lexer.LexerError.InvalidCharacter => {
                print("Found an invalid character.\n", .{});
                continue;
            },
            lexer.LexerError.OutOfBounds => {
                print("Went out of bounds.\n", .{});
                continue;
            },
            lexer.LexerError.OutOfMemory => {
                print("Out of Memory.\n", .{});
                continue;
            },
        };
        defer tokens.deinit();

        const expressions = parser.parse(ally, tokens) catch |err| switch (err) {
            parser.ParserError.InvalidExpressionOrder => {
                print("Order of expressions is not valid.\n", .{});
                continue;
            },
            parser.ParserError.TokenNotYetImplemented => {
                print("Token in input has not been implemented yet.\n", .{});
                continue;
            },
            parser.ParserError.OutOfMemory => {
                print("Out of Memory.\n", .{});
                continue;
            },
        };
        defer expressions.deinit();

        for (expressions.items) |expr| {
            print("Expression => LHS: '{s}' - Operator: '{s}' - RHS: '{s}'\n", .{ expr.LHS.value, expr.Operator.value, expr.RHS.value });
        }
    }
}
