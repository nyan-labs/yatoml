package yatoml;

import haxe.Json;
import yatoml.parser.Parser;
import sys.io.File;
import yatoml.lexer.Syntax;
import yatoml.lexer.Lexer;

class TOML {
  public static final test_toml = TOMLMacro.load("./test.toml");

  public static function main() {
    // var lexer = new Lexer();
    // var tokens = lexer.read(File.getContent("./test.toml"));
    // trace(tokens.join("\n"));

    // var parser = new Parser();
    // var parsed = parser.read(tokens);
    // trace(parsed);
    // trace(untyped parsed.test);
    // trace(untyped parsed.cool.stuff);

    // trace(Json.stringify(parsed));
    // trace(ExprTools.toString(macro yatoml.parser.SyntaxRules.WHITESPACE));

    trace(test_toml.test.pawjob.sticky.value);
  }
}