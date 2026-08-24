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

class Parser {
  public function new() {}

  var pos: Int = 0;
  
  var tokens: Array<TokenPos> = new Array();

  var data: DynamicAccess<Dynamic> = {};
  // funny dot.path 
  var structure: Map<String, TableType> = new Map();

  var current_dot_path: Array<String> = new Array();

  public function read(tokens: Array<TokenPos>) {
    this.pos = 0;
    this.tokens = new Array();
    this.data = {};
    this.structure = new Map();
    this.current_dot_path = new Array();
    
    this.errors = new Array();

    this.tokens = tokens;
    
    while(!is_eof())
      parse();

    if(errors.length != 0)
      throw errors.join("\n");

    return data;
  }

  function parse() {
    var token = peek();
    if(token == null)
      return;

    // trace("> ", token);
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

        current_dot_path = table_name_pack;

        var table_name_concat = current_dot_path.join(".");

        var expected_table_type = structure.get(table_name_concat);

        if(!structure.exists(table_name_concat))
          structure.set(table_name_concat, table_type);

        else if(expected_table_type != table_type)
          throw 'expected $expected_table_type, got $table_type';

        
        // there is a reason its here yea
        if(table_name_pack.length == 0) {
          error("invalid table name");
          return;
        }

      case Identifier(s), String(s, Basic), String(s, Literal):
        parse_key_and_value();

      case _: throw 'you likely forgot to parse this ${token.token} at ${token.pos.line}:${token.pos.column}';
    }
  }

  function parse_key_and_value() {
    var key = parse_value();
    // for dotpath, we should just make(or use if it exists) a new table here for each key after THIS key so its like $key = { $key1: { $key2: $value } }

    var path = new Array<String>();
    path.push(key);

    while(!is_eof() && check(Operator(Dot))) {
      advance();

      path.push(parse_value());
    }

    key = path.pop();

    // trace(path, key);
    var table = if(path.length > 0) 
      get_table(current_dot_path.concat(path));
    else 
      get_table(current_dot_path);

    // trace(table, current_dot_path);

    switch peek().token {
      case Operator(Assign):
        advance();

      case token:
        throw 'assign expected, got $token';
    }
    
    var value = parse_value();

    table.set(key, value);
  }

  function get_table(path: Array<String>) {
    var path_name = path.join("."); 

    var length = path.length - 1;
    // if(type == null)
    //   structure.set(path_name, type = Dict);
    
    var parent: DynamicAccess<Dynamic> = data;
    for(i => name in path) {
      var path_name = path.slice(0, i + 1).join(".");
      
      var type = structure.get(path_name);

      if(type == null)
        structure.set(path_name, type = /*i == length ? Array :*/Dict);

      // trace(path_name, name, parent, parent.get(name), type);
      parent = switch type {
        case Dict: 
          parent.get(name) ?? parent.set(name, {});
        case Array:
          var array = cast parent.get(name) ?? parent.set(name, new Array());
  
          // check if its the last "key" in the path (ex: `path.to.key`)
          final is_toplevel = i == length;
          
          // we get the latest table in the array cuz thats how toml works lol
          var table = array[array.length - 1];
  
          if(table == null || is_toplevel) {
            table = {};
  
            array.push(table);
          };
  
  
          table;
      };
    }

    return parent;
  }

  function parse_value(): Dynamic {
    return switch peek().token {
      case Identifier("nan"):
        advance();
        Math.NaN;
      case Identifier("inf"):
        advance();
        Math.POSITIVE_INFINITY;

      case Operator(LeftCurly):
        advance();
        
        var table: DynamicAccess<Dynamic> = {};

        while(!is_eof()) {
          skip_newline();
          if(check(Operator(RightCurly)))
            break;

          var key = parse_value();

          switch peek().token {
            case Operator(Assign):
              advance();

            case token:
              throw 'assign expected, got $token';
          }

          var value = parse_value();

          table.set(key, value);

          // mandatory til last line
          if(check(Operator(Comma)))
            advance();
        }

        expect(Operator(RightCurly));
        advance();

        table;

      case Identifier(i):
        advance();
        i;

      case String(s, type):
        advance();
        s;

      case Operator(Plus):
        advance();
        var number = parse_value();
        --number;

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

  var errors: Array<String> = new Array();
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
    return peek() != null && peek().token == Eof;
}