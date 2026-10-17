enum TokenType { word, number, string, symbol, newline, eof }

class Token {
  Token(this.type, this.lexeme, this.line, this.column, {String? norm, this.value}) : norm = norm ?? lexeme;

  final TokenType type;

  /// Text as written by the user.
  final String lexeme;

  /// Normalized form used for comparisons (lowercase, no accents for words).
  final String norm;

  /// Parsed value for numbers and strings.
  final Object? value;

  final int line;
  final int column;

  /// How the token is named in error messages.
  String describe() => switch (type) {
    TokenType.newline => 'el fin de la línea',
    TokenType.eof => 'el fin del archivo',
    TokenType.string => 'el texto "$value"',
    _ => "'$lexeme'",
  };
}
