package generic_test;

import yatoml.Toml;
import sys.io.File;

class GenericTest {
  public function new() {
    var file = File.getContent("./tests/generic_test/test.toml");

    var parsed = Toml.parse(file);

    trace("parsed:", parsed);
  }
}