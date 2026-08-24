package yatoml.lexer;

import yatoml.lexer.Syntax;
import yatoml.lexer.Token;

using StringTools;

class Lexer {
  public function new() {}
  
  var tokens: Array<TokenPos> = new Array();
  var pos: Int = 0;
  var line: Int = 1;
  var column: Int = 1;
  var content: String = "";

  var queue: Array<TokenPos> = new Array();

  public function read(content: String) {
    this.tokens = new Array();
    this.pos = 0;
    this.line = 1;
    this.column = 1;

    this.queue = new Array();

    this.content = content;
    this.content.replace(Syntax.NEWLINE_CR + Syntax.NEWLINE_LF, Syntax.NEWLINE_LF);

    while(!is_eof()) {
      var pos = position();
      var token = tokenize();

      for(token in queue) {
        tokens.push(token);
      }
      queue = new Array();

      if(token != null)
        tokens.push({
          token: token,
          pos: pos
        });
    }

    tokens.push({
      token: Eof,
      pos: position()
    });

    return tokens;
  }

  function tokenize(): Null<Token> {
    return switch peek() {
      case Syntax.WHITESPACE.contains(_) => true:
        advance();
        // Whitespace;
        null;

      case Syntax.OP_PLUS:
        advance();
        Operator(Plus);
      case Syntax.OP_MINUS:
        advance();
        Operator(Minus);

      case Syntax.OP_DOT:
        advance();
        Operator(Dot);
      case Syntax.OP_COMMA:
        advance();
        Operator(Comma);

      case Syntax.OP_LEFT_BRACKET:
        advance();
        Operator(LeftBracket);

      case Syntax.OP_RIGHT_BRACKET:
        advance();
        Operator(RightBracket);

      case Syntax.OP_LEFT_CURLY:
        advance();
        Operator(LeftCurly);

      case Syntax.OP_RIGHT_CURLY:
        advance();
        Operator(RightCurly);

      case Syntax.OP_COLON:
        advance();
        Operator(Colon);

      case Syntax.OP_ASSIGN:
        advance();
        Operator(Assign);

      case Syntax.NEWLINE_LF: 
        advance();

        line++;
        column = 1;

        Newline;

      case Syntax.COMMENT: 
        advance();
        
        var content = "";
        while(peek() != Syntax.NEWLINE_LF && !is_eof()) { content += peek(); advance(); };
        
        // Comment(content);
        null;

      case Syntax.OP_QUOTE_BASIC, Syntax.OP_QUOTE_LITERAL:
        var quote_char = peek();
        advance();

        var multi = 
          peek(0) == Syntax.OP_QUOTE_LITERAL && peek(1) == Syntax.OP_QUOTE_LITERAL ||
          peek(0) == Syntax.OP_QUOTE_BASIC && peek(1) == Syntax.OP_QUOTE_BASIC;

        if(multi) {
          advance();
          advance();
        }

        var quote_type: QuoteType = 
          if(quote_char == Syntax.OP_QUOTE_BASIC)
            if(multi) MultiBasic else Basic;
          else if(quote_char == Syntax.OP_QUOTE_LITERAL)
            if(multi) MultiLiteral else Literal;
          else throw "What the fuck";

        var chars = new Array<String>();
        
        // literals should not accept escapes and bla bla
        while(!is_eof()) {
          var char = peek();
          if(char == quote_char) {
            advance();
            if(multi) {
              advance();
              advance();
            }

            break;
          }

          advance();
          chars.push(char);
        };

        String(chars.join(""), quote_type);

      case Syntax.is_digit(_) => true:
        var chars = new Array<String>();
        
        //besttest code evar!
        var mode = null;
        // hexadecimal or octal or binary
        if(peek() == "0" && (peek(1) == "x" || peek(1) == "o" || peek(1) == "b")) {
          chars.push(peek());
          advance();
          
          mode = peek();
          chars.push(mode);

          advance();
        }

        var is_float = false;

        // exponents? idk
        //floats? im lazy
        while(!is_eof()) {
          var char = peek();
          if(char == ".") {
            if(is_float)
              throw "cant't have more than one dot in a float";

            is_float = true; 

            chars.push(char);
            advance();
            
            continue;
          }

          var valid = switch mode {
            case "x": Syntax.is_alphanumeric(char);
            case "o": Syntax.is_octal(char);
            case "b": Syntax.is_binary(char);
            case _: Syntax.is_digit(char);
          }

          if(char == "_" && peek(1) == "_")
            throw "can't do that mate";

          if(char == "_") {
            advance();
            continue;
          }

          if(!valid)
            break;

          advance();
          chars.push(char);
        };

        var joined = chars.join("");
        if(is_float)
          Float(Std.parseFloat(joined))
        else 
          Int(Std.parseInt(joined));

      case Syntax.is_identifier(_) => true:
        var chars = new Array<String>();
        
        while(!is_eof()) {
          var char = peek();
          if(!Syntax.is_identifier(char))
            break;

          advance();
          chars.push(char);
        };

        var name = chars.join("");

        switch name {
          case _.toLowerCase() => "true":
            Bool(true);
          case _.toLowerCase() => "false":
            Bool(false);

          case _: Identifier(name);
        }


      case c: throw 'unknown character `$c` (${c.charCodeAt(0)})';
    }
  }

  inline function position(): Position 
    return {
      line: line,
      column: column
    };

  inline function peek(offset: Int = 0)
    return content.charAt(pos + offset);

  inline function advance(offset: Int = 1) {
    column = column + offset;

    pos = pos + offset;
  }

  inline function is_eof()
    return pos >= content.length;
}