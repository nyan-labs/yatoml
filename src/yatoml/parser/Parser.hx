package yatoml.parser;

import haxe.PosInfos;
import haxe.ds.Either;
import haxe.EnumTools;
import haxe.DynamicAccess;
import yatoml.lexer.Token;

using yatoml.utils.EnumTools;

enum TableType {
  Array;
  Dict;
}

@:build(yatoml.lexer.Lexer.build())
class Parser {
  public function new() {}

  @:regen var pos: Int = 0;
  
  @:regen var tokens: Array<TokenPos> = new Array();

  // funny dot.path 
  @:regen var structure: Map<String, TableType> = new Map();

  @:regen var current_dot_path: Null<String> = null;
  @:regen var current_table: Null<DynamicAccess<Dynamic>> = null;

  public function read(tokens: Array<TokenPos>) {
    regen();

    this.tokens = tokens;

    var data: DynamicAccess<Dynamic> = {};

    while(!is_eof())
      parse(data);

    if(errors.length != 0)
      throw errors.join("\n");

    return data;
  }

  function parse(data: DynamicAccess<Dynamic>) {
    var token = peek();

    trace("> ", token);
    switch token.token {
      case Newline:
        advance();
        
      // case Comment(content):
      //   advance();
      //   trace(content);
      //   parse();

      // case Whitespace: 
      //   skip_whitespace();
      //   parse();

      case Operator(LeftBracket):
        advance();

        var table_type = switch peek().token {
          case Operator(LeftBracket):
            advance();
            Array;
          case _: 
            Dict;
        };

        var table_name_pack = parse_table_name();

        if(table_type == Array) {
          expect(Operator(RightBracket));
          advance();
        }

        expect(Operator(RightBracket));
        advance();

        var table_name_concat = table_name_pack.join(".");

        var expected_table_type = structure.get(table_name_concat);

        if(!structure.exists(table_name_concat))
          structure.set(table_name_concat, table_type);

        else if(expected_table_type != table_type)
          throw 'expected $expected_table_type, got $table_type';

        current_dot_path = table_name_concat;
        
        // there is a reason its here yea
        if(table_name_pack.length == 0) {
          error("invalid table name");
          return;
        }

        switch table_type {
          case Dict: 
            final table_name_top = table_name_pack.pop();

            var parent = data;
            for(name in table_name_pack) {
              parent = parent.get(name) ?? parent.set(name, {});
            }

            var table: DynamicAccess<Dynamic> = parent.get(table_name_top) ?? {};
            parent.set(table_name_top, table);
            
            current_table = table;

          case Array:
            var array: Array<Dynamic> = new Array(); 

            var length = table_name_pack.length - 1;

            var parent = data;
            for(i => name in table_name_pack) {
              var new_parent = parent.get(name) ?? parent.set(name, 
                if(i == length) 
                  new Array<Dynamic>() 
                else 
                  ({})
              );

              if(i == length) {
                if(new_parent is Array) {
                  array = cast new_parent;
                } else if(i == length) throw 'expected $expected_table_type, got $table_type';

                break;
              } else parent = new_parent;
            }

            var table: DynamicAccess<Dynamic> = {};
            array.push(table);
            
            current_table = table;
            
        }

      case Identifier(s), String(s, Basic), String(s, Literal):
        parse_key_and_value();

      case _: throw 'you likely forgot to parse this ${token.token} at ${token.pos.line}:${token.pos.column}';
    }
  }

  function parse_key_and_value() {
    var key = parse_value();

    switch peek().token {
      case Operator(Assign):
        advance();

      case token:
        throw 'assign expected, got $token';
    }
   
    var value = parse_value();

    current_table.set(key, value);
  }

  function parse_value(): Dynamic {
    return switch peek().token {
      // case Newline:
      //   advance();
      //   parse_value();


      case Identifier(i):
        advance();
        i;

      case String(s, type):
        advance();
        s;

      case Operator(Plus):
        advance();
        var number = parse_value();
        number;

      case Operator(Minus):
        advance();
        var number = parse_value();
        -number;

      case Int(i):
        advance();
        i;
      case Float(f):
        advance();
        f;
      case Bool(b):
        advance();
        b;
      case Date(date):
        advance();
        date;

      case Operator(LeftBracket):
        advance();
        var arr = new Array();
        while(!is_eof()) {
          arr.push(parse_value());

          if(peek().token.equals(Operator(Comma))) 
            advance()
          else
            if(peek().token.equals(Operator(RightBracket))) {
              advance();
              break;
            } else throw "missing comma ";
        }
        arr;

      case token: throw 'buh $token';
    }
  }

  function parse_table_name(): Array<String> {
    var name = new Array<String>();

    var has_dot = true;
    while(!is_eof() && !check(Operator(RightBracket))) {
      switch peek().token {
        case String(s, type):
          if(!has_dot) {
            error("missing dot");
            advance();
            continue;
          }

          name.push(s); 
          advance();

          has_dot = false;

        case Identifier(i):
          if(!has_dot) {
            error("missing dot");
            advance();
            continue;
          }

          name.push(i); 
          advance();

          has_dot = false;           

        case Operator(Dot):
          advance();
          
          has_dot = true;

        case token:
          error('invalid table name, got $token');
          advance();
          continue;
      }
    }

    return name;
  }

  inline function skip_newline() {
    while(!is_eof() && peek().token == Newline) advance();
  }

  // inline function skip_whitespace() {
  //   while(!is_eof() && peek().token == Whitespace) advance();
  // }

  // inline function skip_comment() {
  //   while(!is_eof() && peek().token.match(Comment(_))) advance();
  // }

  inline function expect(what: Token, ?it: TokenPos = null) {
    if(it == null) it = peek();

    if(check(what, it.token))
      return it.token
    else {
      error('expected ${what}, got ${it.token}', it);
      return it.token;
    }
  }

  inline function check(what: Token, ?it: Token = null)
    return Type.enumEq(if(it == null) peek().token else it, what);

  @:regen var errors: Array<String> = new Array();
  inline function error(message: String, ?token: TokenPos = null, ?custom = false, ?pos: PosInfos) {
    if(token == null) token = peek();
 
    errors.push(
      if(custom) message else '${pos.fileName}:${pos.lineNumber}: $message at ${token?.pos?.line}:${token?.pos?.column}' 
    );
  }

  inline function peek(offset: Int = 0)
    return tokens[pos + offset];

  inline function advance(offset: Int = 1)
    pos = pos + offset;

  inline function is_eof()
    return peek().token == Eof;
}