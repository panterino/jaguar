enum ErrorKind { syntax, runtime }

/// Why a run stopped, when it matters for explaining a failed test.
enum ErrorCause {
  other,

  /// Too many steps: most likely a loop that never ends.
  stepLimit,

  /// `Leer` ran out of the inputs a test provides.
  noMoreInput,
}

/// An error meant to be read by a student: the message and hint are in
/// Spanish and point to the line that caused it.
class JaguarError implements Exception {
  JaguarError(this.kind, this.message, {required this.line, this.column = 0, this.hint, this.cause = ErrorCause.other});

  JaguarError.syntax(String message, {required int line, int column = 0, String? hint})
    : this(ErrorKind.syntax, message, line: line, column: column, hint: hint);

  JaguarError.runtime(
    String message, {
    required int line,
    int column = 0,
    String? hint,
    ErrorCause cause = ErrorCause.other,
  }) : this(ErrorKind.runtime, message, line: line, column: column, hint: hint, cause: cause);

  final ErrorKind kind;
  final String message;
  final int line;
  final int column;
  final String? hint;
  final ErrorCause cause;

  /// A block that is still open ("Falta 'FinSi'…"): while typing that is not
  /// a mistake yet, so the editor waits for the program to run.
  bool get unfinished =>
      kind == ErrorKind.syntax && (message.startsWith("Falta '") || RegExp(r"^Encontré '\w+', pero antes falta '").hasMatch(message));

  String get title => kind == ErrorKind.syntax ? 'Error de escritura' : 'Error al ejecutar';

  /// Renders the error with the offending source line and a caret.
  String format(String source) {
    final lines = source.split(RegExp(r'\r?\n'));
    final buffer = StringBuffer('$title en la línea $line: $message');
    if (line >= 1 && line <= lines.length) {
      final code = lines[line - 1];
      final gutter = '$line | ';
      buffer
        ..writeln()
        ..write('$gutter$code');
      if (column >= 1 && column <= code.length + 1) {
        final padding = StringBuffer(' ' * gutter.length);
        for (var i = 0; i < column - 1; i++) {
          padding.write(code[i] == '\t' ? '\t' : ' ');
        }
        buffer
          ..writeln()
          ..write('$padding^');
      }
    }
    if (hint != null) {
      buffer
        ..writeln()
        ..write('Sugerencia: $hint');
    }
    return buffer.toString();
  }

  @override
  String toString() => '$title (línea $line): $message';
}

/// Thrown when the host stops a running program (e.g. the user pressed stop).
class RunCancelled implements Exception {
  const RunCancelled();
}
