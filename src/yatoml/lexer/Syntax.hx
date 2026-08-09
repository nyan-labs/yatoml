package yatoml.lexer;

import yatoml.lexer.Token.QuoteType;

@:publicFields
class Syntax {
  static final WHITESPACE = [
    String.fromCharCode(0x20), // space
    String.fromCharCode(0x09) // horizontal tab
  ];
  
  static final NEWLINE_CR = "\r";
  static final NEWLINE_LF = "\n";
  static final COMMENT = "#";

  static final OP_LEFT_BRACKET = "[";
  static final OP_RIGHT_BRACKET = "]";
  static final OP_LEFT_CURLY = "{";
  static final OP_RIGHT_CURLY = "}";

  static final OP_PLUS = "+";
  static final OP_MINUS = "-";
  static final OP_DOT = ".";
  static final OP_COMMA = ",";
  static final OP_COLON = ":";
  static final OP_ASSIGN = "=";

  static final OP_QUOTE_LITERAL = "'";
  static final OP_QUOTE_MULTILITERAL = "'''";
  static final OP_QUOTE_BASIC = '"';
  static final OP_QUOTE_MULTIBASIC = '"""';
  
  // static inline function get_quote_type(c: String): QuoteType {
  //   return switch c {
  //     case OP_QUOTE_LITERAL: Literal;
  //     case OP_QUOTE_MULTILITERAL: MultiLiteral;
  //     case OP_QUOTE_BASIC: Basic;
  //     case OP_QUOTE_MULTIBASIC: MultiBasic;

  //     case _: null;
  //   }
  // }

  static inline function is_ascii(c: String)
    return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z");

  static inline function is_digit(c: String)
    return c >= "0" && c <= "9";

  static inline function is_octal(c: String)
    return c >= "0" && c <= "7";

  static inline function is_binary(c: String)
    return c == "0" || c == "1";

  static inline function is_alphanumeric(c: String)
    return is_ascii(c) || is_digit(c);

  static inline function is_identifier(c: String)
    return is_alphanumeric(c) || c == "_" || c == "-";
}