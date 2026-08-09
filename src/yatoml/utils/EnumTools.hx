package yatoml.utils;

import haxe.macro.Expr;
import haxe.macro.Context;
import yatoml.lexer.Token;

class EnumTools {
  // inline public static function expect(token: TokenPos, @:inline to_expect: Token) {
  //   return if(Type.enumEq(token, to_expect))
  //     token.token;
  //   else
  //     throw 'expected $to_expect, got ${token.token} at ${token.pos.line}:${token.pos.column}';
  // }


  public static macro function extract(value: ExprOf<EnumValue>, pattern: Expr): Expr {
    switch (pattern) {
      case macro $a => $b:
        return macro switch ($value) {
          case $a: $b;
          default: throw "no match";
        }
      default:
        throw new Error("Invalid enum value extraction pattern", pattern.pos);
    }
  }
}