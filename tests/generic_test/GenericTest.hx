package generic_test;

import yatoml.Toml;
import sys.io.File;

class GenericTest {
  // this is reallyy useless lol
  public function new() {
    var file = File.getContent("./tests/generic_test/test.toml");

    var parsed = Toml.parse(file);

    trace("parsed:", parsed);

    var stringified = Toml.stringify(parsed);

    trace("stringified:", stringified);
  }
}