package yatoml.lexer;

enum QuoteType {
  /** single-quote, no escaping **/
  Literal; 
  /** multiline, 3 single-quotes, no escaping **/
  MultiLiteral;
  /** double-quote, escaped **/
  Basic;
  /** multiline, 3 double-quotes, escaped **/
  MultiBasic;
}

enum Operator {
  Quote(type: QuoteType);

  LeftBracket;
  RightBracket;

  LeftCurly;
  RightCurly;

  Colon;
  Assign;
  Comma;
  Dot;
  Minus;
  Plus;

  Delimiter(char: String);
}

enum Token {
  Eof;


  // Whitespace;
  Newline;

  // Comment(content: String);
  Identifier(i: String);
  
  Int(i: Int);
  Float(f: Float);
  String(s: String, type: QuoteType);
  Bool(b: Bool);
  Date(date: String);

  Operator(op: Operator);
  
  Table(name: String);
}

typedef Position = {
  line: Int,
  column: Int,
}

typedef TokenPos = {
  token: Token,
  pos: Position
}