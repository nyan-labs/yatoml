package yatoml;

import haxe.Json;
import yatoml.parser.Parser;
import sys.io.File;
import yatoml.lexer.Syntax;
import yatoml.lexer.Lexer;

class Toml {
  static public function parse(content: String) {
    var lexer = new Lexer();
    var tokens = lexer.read(content);

    var parser = new Parser();
    var parsed = parser.read(tokens);

    return parsed;
  }
}