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

  Colon;
  Assign;
}

enum Token {
  Whitespace;
  Newline;

  Comment;
  Identifier(i: String);
  
  Int(i: Int);
  Float(i: Float);
  String(i: String, type: QuoteType);
  Bool(i: String);
  Date(date: String);

  Operator(op: Operator);
  
  Table(name: String);
}