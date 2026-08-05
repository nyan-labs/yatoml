package yatoml.lexer;

import yatoml.lexer.Syntax;
import yatoml.lexer.Token;

@:build(yatoml.lexer.Lexer.build())
class Lexer {
  public function new() {}
  
  @:regen var tokens: Array<Token> = new Array();
  @:regen var pos: Int = 0;
  @:regen var content: String = "";

  @:regen var queue: Array<Token> = new Array();

  public function read(content: String) {
    regen();

    this.content = content;

    while(!is_eof()) {
      var token = tokenize();

      for(token in queue) {
        tokens.push(token);
      }
      queue = new Array();

      if(token != null)
        tokens.push(token);
    }

    return tokens;
  }

  function tokenize(): Null<Token> {
    return switch peek() {
      case Syntax.WHITESPACE.contains(_) => true:
        advance();
        Whitespace;

      case Syntax.COMMENT: 
        advance();
        Comment;

      case Syntax.get_quote_type(_) => quote_type if(quote_type != null):
        var quote_char = peek(); 
        advance();

        var chars = new Array<String>();
        
        //literals should not accept escapes and bla bla
        while(!is_eof()) {
          var char = peek();
          if(char != quote_char)
            break;

          advance();
          chars.push(char);
        };


        String(chars.join(""), quote_type);

      case Syntax.is_digit(_) => true:
        var chars = new Array<String>();
        
        chars.push(peek());
        advance();
        // hexadecimal or octal or binary
        if(peek() == "x" || peek() == "o" || peek() == "b" || Syntax.is_digit(peek())) {
          chars.push(peek());

          advance();
        }

        while(!is_eof()) {
          var char = peek();
          if(!Syntax.is_digit(char))
            break;

          advance();
          chars.push(char);
        };

        Int(Std.parseInt(chars.join("")));


      case Syntax.is_ascii(_) => true:
        var chars = new Array<String>();
        
        while(!is_eof()) {
          var char = peek();
          if(!Syntax.is_alphanumeric(char))
            break;

          advance();
          chars.push(char);
        };


        Identifier(chars.join(""));

      case c: throw 'unknown character $c';
    }
  }

  inline function peek(offset: Int = 0)
    return content.charAt(pos);

  inline function advance(offset: Int = 1)
    pos = pos + offset;

  inline function is_eof()
    return pos >= content.length;
}