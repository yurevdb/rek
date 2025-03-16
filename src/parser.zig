const std = @import("std");
const lexer = @import("lexer.zig");
const print = std.debug.print;
const assert = std.debug.assert;

pub const ParserError = error{
    InvalidExpressionOrder,
    TokenNotYetImplemented,
    OutOfMemory,
};

pub const Expression = struct {
    LHS: lexer.Token,
    Operator: lexer.Token,
    RHS: lexer.Token,
};

pub const AST = struct {};

pub fn parse(alloc: std.mem.Allocator, tokens: std.ArrayList(lexer.Token)) ParserError!std.ArrayList(Expression) {
    var exprs = std.ArrayList(Expression).init(alloc);

    var index: u16 = 0;
    while (index < tokens.items.len - 1) {
        const lhs_token = tokens.items[index];
        if (lhs_token.type != lexer.TokenType.VALUE) {
            return ParserError.InvalidExpressionOrder;
        }

        index += 1;
        const operator = tokens.items[index];
        if (operator.type == lexer.TokenType.VALUE) {
            return ParserError.InvalidExpressionOrder;
        }
        if (operator.type == lexer.TokenType.L_BRACKET) {
            return ParserError.TokenNotYetImplemented;
        }
        if (operator.type == lexer.TokenType.R_BRACKET) {
            return ParserError.TokenNotYetImplemented;
        }

        index += 1;
        const rhs_token = tokens.items[index];
        if (rhs_token.type != lexer.TokenType.VALUE) {
            return ParserError.InvalidExpressionOrder;
        }

        try exprs.append(.{ .LHS = lhs_token, .Operator = operator, .RHS = rhs_token });
    }

    return exprs;
}
