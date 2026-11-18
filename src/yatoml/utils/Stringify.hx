package yatoml.utils;

import yatoml.parser.Parser.TomlAccess;

enum Stringification {
  KeyValue(key: String, value: Stringification);
  Value(value: String);

  Array(items: Array<Stringification>);
  Table(name: String, entries: Array<Stringification>);
}

class Stringify {
  static function to_value(key: Any, value: Any): Stringification {
    return switch Type.typeof(value) {
      case TNull: Value('null');
      case TInt: Value('$value');
      case TInt64: Value('$value');
      case TFloat: Value('$value');
      case TBool: Value(value ? "true" : "false");
      case TObject: Stringify.to_table(key, value);

      case TClass(_) if(value is String): 
        var str: String = value;
        var is_multiline = str.indexOf("\n") == -1;

        Value(if(is_multiline) '"$value"' else '"""$value"""');
      case TClass(_) if(value is Array):
        var array: Array<Any> = value; 

        Array([
          for(v in array) Stringify.to_value("", v)
        ]);

      case t:
        Value('null');
    }
  }

  static function to_table(name: String, data: TomlAccess): Stringification {
    return Table(name, [for(key => value in data) {
      var value = Stringify.to_value(key, value);

      KeyValue(key, value);
    }]);
  }

  static function inline_to_string(s: Stringification) {
    var output = new Array<String>();

    switch s {
      case Table(_, entries): for(entry in entries) {
        switch entry {
          case KeyValue(key, var value): 
            switch value {
              case Value(v):
                output.push('$key = $v');

              case Table(_, _):
                output.push(
                  '$key = ' +
                  Stringify.inline_to_string(s)
                );

              case _: throw 'invalid value $s';
            }

            case _: throw 'invalid entry $s';
          }
        }

      case Array(items):
        var array = [for(item in items) switch item {
          case Value(v): v;

          case Table(_, _): Stringify.inline_to_string(item);

          case Array(_): Stringify.inline_to_string(item);

          case _: throw 'invalid item $s';
        }];

        return '[${array.join(", ")}]';

      case _: throw 'expected table, got $s';
    }

    return '{${output.join(',\n')}}';
  }
  
  static public function to_string(s: Stringification) {
    var output = new Array<String>();
    
    switch s {
      case Table(name, entries): 
        output.push('[$name]');

        // stupidly solves the issue of 
        // [table]
        // key = "something"
        // [table.more]
        // key = "something more"
        // key2 = "im actually supposed to be part of the [table]"

        var buffer = new Array<String>();

        for(entry in entries) switch entry {
          case KeyValue(key, var value): switch value {
            case Value(v): output.push('$key = $v');

            case Table(n, e): 
              buffer.push(
                Stringify.to_string(Table(name.length == 0 ? n : '$name.$n', e))
              );

            // lots of work..
            case Array(items):
              var items = Stringify.inline_to_string(value);
              
              output.push('$key = $items');

            case _: throw 'expected value, got $s';
          }

          case _: throw 'expected entry, got $s';
        }

        for(b in buffer) 
          output.push(b);

      case s: throw 'expected table, got $s';
    }

    return output.join('\n');
  }

  static public function stringify(data: TomlAccess) {
    var table = Stringify.to_table("", data);
    
    return Stringify.to_string(table);
  }
}