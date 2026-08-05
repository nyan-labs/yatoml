package yatoml.lexer;

import yatoml.lexer.Token.QuoteType;

@:publicFields
class Syntax {
  // public static final literals = [
  //   Whitespace => [
  //     String.fromCharCode(0x20), // space
  //     String.fromCharCode(0x09) // horizontal tab
  //   ],

  //   Comment => [
  //     "#"
  //   ],

  //   Operator(Quote(Literal)) => ["'"],
  //   Operator(Quote(MultiLiteral)) => ["'''"],
  //   Operator(Quote(Basic)) => ['"'],
  //   Operator(Quote(MultiBasic)) => ['"""']
  // ];

  static final WHITESPACE = [
    String.fromCharCode(0x20), // space
    String.fromCharCode(0x09) // horizontal tab
  ];

  static final COMMENT = "#";

  static final OP_QUOTE_LITERAL = "'";
  static final OP_QUOTE_MULTILITERAL = "'''";
  static final OP_QUOTE_BASIC = '"';
  static final OP_QUOTE_MULTIBASIC = '"""';
  
  static inline function get_quote_type(c: String): QuoteType {
    return switch c {
      case OP_QUOTE_LITERAL: Literal;
      case OP_QUOTE_MULTILITERAL: MultiLiteral;
      case OP_QUOTE_BASIC: Basic;
      case OP_QUOTE_MULTIBASIC: MultiBasic;

      case _: null;
    }
  }

  static inline function is_ascii(c: String)
    return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z");

  static inline function is_digit(c: String)
    return c >= "0" && c <= "9";

  static inline function is_alphanumeric(c: String)
    return is_ascii(c) || is_digit(c);
}