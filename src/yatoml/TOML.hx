package yatoml;

import yatoml.parser.Parser;
import sys.io.File;
import yatoml.lexer.Syntax;
import yatoml.lexer.Lexer;
import haxe.macro.ExprTools;

class TOML {
  public static final test_toml = File.getContent("./test.toml");

  public static function main() {
    var lexer = new Lexer();
    var tokens = lexer.read(test_toml);
    trace(tokens.join("\n"));

    var parser = new Parser();
    trace(parser.read(tokens));
    // trace(ExprTools.toString(macro yatoml.parser.SyntaxRules.WHITESPACE));
  }
}