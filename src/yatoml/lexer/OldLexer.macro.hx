package yatoml.lexer;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

@:deprecated
class OldLexer {
  public static function build(): Array<Field> {
    var fields = Context.getBuildFields();

    var regenerative_fields = new Array<Expr>();

    for(field in fields) {
      var regen = field.meta.find(meta -> meta.name == ":regen");

      if(regen != null) {
        var expr = switch field.kind {
          case FVar(t, e): e;
          case FProp(get, set, t, e): e;

          case FFun(f): throw "functions can't be regenerative";
        }

        if(expr == null) 
          throw "regenerative expression can't be null";

        regenerative_fields.push(macro $i{field.name} = $expr);
      }
    }

    fields.push({
      name: "regen",
      pos: Context.currentPos(),
      kind: FFun({
        args: [],
        expr: macro $b{regenerative_fields}
      })
    });

    return fields;
  }
}