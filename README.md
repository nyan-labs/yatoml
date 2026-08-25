# yatoml
yet another TOML (parser)

this is a TOML parser that is (mostly) up to [spec](https://github.com/toml-lang/toml/blob/1.1.0/toml.abnf) with TOML `v1.1.0`

# example

```haxe
package;

import yatoml.TomlMacro;
import yatoml.Toml;

class Main {
  // this lets you know the fields at compile time!

  static final macro_time = TomlMacro.load("./path/to/config.toml");
  static final parsed = Toml.read("test = 'works!'");
  
  static function main() {
    trace(macro_time);

    trace(parsed.test); // works!
  }
}
```

# contributions
you are more than welcome to contribute