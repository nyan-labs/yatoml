package yatoml;

import yatoml.parser.Parser;
import sys.io.File;
import yatoml.lexer.Syntax;
import yatoml.lexer.Lexer;

class TOMLMacro {
  // macro static public function read(content: String) {
  //   var lexer = new Lexer();
  //   var tokens = lexer.read(content);

  //   var parser = new Parser();
  //   var parsed = parser.read(tokens);

  //   return macro $v{parsed};
  // }

  macro static public function load(path: String) {
    haxe.macro.Context.registerModuleDependency(haxe.macro.Context.getLocalModule(), path);
    return try {
      var content = File.getContent(path);

      var lexer = new Lexer();
      var tokens = lexer.read(content);

      var parser = new Parser();
      var parsed = parser.read(tokens);

      macro $v{parsed};
    } catch(e) {
      haxe.macro.Context.error('Failed to load toml: $e', haxe.macro.Context.currentPos());
    }
  }
}