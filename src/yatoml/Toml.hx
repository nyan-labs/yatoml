package yatoml;

import yatoml.lexer.Syntax;
import yatoml.lexer.Lexer;
import haxe.macro.ExprTools;

class Toml {
  public static function main() {
    var lexer = new Lexer();
    trace(lexer.read("hi world"));
    // trace(ExprTools.toString(macro yatoml.parser.SyntaxRules.WHITESPACE));
  }
}