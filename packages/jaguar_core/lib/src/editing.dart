import 'ast.dart';

/// A place in the flow where a new statement can go: position [index] of
/// [body], a list of statements of the program. Drawn as a ＋ on an arrow.
final class InsertPoint {
  const InsertPoint(this.body, this.index, {required this.headerLine, this.addElseTo});

  final List<Stmt> body;
  final int index;

  /// The line that opens [body]: `Algoritmo`, `Si`, `SiNo`, `Mientras`, a
  /// case of `Según`… New statements at index 0 go right under it.
  final int headerLine;

  /// The No side of a Si that has no SiNo yet: inserting writes it.
  final IfStmt? addElseTo;
}

/// The result of an edit: the new source and the line where the edited
/// statement now starts.
typedef SourceEdit = ({String source, int line});

const indentStep = '    ';

final _leading = RegExp(r'^[ \t]*');

String _indentOf(String line) => _leading.stringMatch(line) ?? '';

/// Inserts [statement] (one or more lines, with relative indentation) at
/// [point]. Only new lines are added: comments and formatting stay as the
/// student wrote them.
SourceEdit insertStatement(String source, Program program, InsertPoint point, String statement) {
  final lines = source.split('\n');
  final spans = program.spans!;
  final addElseTo = point.addElseTo;
  if (addElseTo != null) {
    // Before the FinSi: "SiNo" at the Si's indentation, then the statement.
    final ifIndent = _indentOf(lines[addElseTo.line - 1]);
    final finSi = spans.endLine(addElseTo);
    final newLines = [
      '${ifIndent}SiNo',
      for (final line in statement.split('\n')) line.isEmpty ? line : '$ifIndent$indentStep$line',
    ];
    lines.insertAll(finSi - 1, newLines);
    return (source: lines.join('\n'), line: finSi + 1);
  }
  final int afterLine;
  final String indent;
  if (point.index > 0) {
    final previous = point.body[point.index - 1];
    afterLine = spans.endLine(previous);
    indent = _indentOf(lines[previous.line - 1]);
  } else {
    afterLine = point.headerLine;
    indent = _indentOf(lines[point.headerLine - 1]) + indentStep;
  }
  final newLines = [for (final line in statement.split('\n')) line.isEmpty ? line : '$indent$line'];
  // A new program's blank line inside an empty block is where it goes.
  if (point.body.isEmpty && afterLine < lines.length && lines[afterLine].trim().isEmpty) lines.removeAt(afterLine);
  lines.insertAll(afterLine, newLines);
  return (source: lines.join('\n'), line: afterLine + 1);
}

/// Removes [stmt] with everything inside it (a whole `Si … FinSi`).
SourceEdit deleteStatement(String source, Program program, Stmt stmt) {
  final lines = source.split('\n');
  final first = lines[stmt.line - 1];
  final startsLine = stmt.column - 1 <= _indentOf(first).length;
  final end = program.spans!.endLine(stmt);
  if (startsLine) {
    lines.removeRange(stmt.line - 1, end);
  } else {
    // `1: Escribir "uno"`: keep the case label, remove the rest.
    lines[stmt.line - 1] = first.substring(0, stmt.column - 1).trimRight();
    lines.removeRange(stmt.line, end);
  }
  return (source: lines.join('\n'), line: stmt.line);
}

/// Replaces the text of [line] from [column] (1-based) to its end with
/// [text], keeping a `// comment` at the end of the line.
SourceEdit replaceLineFrom(String source, int line, int column, String text) {
  final lines = source.split('\n');
  final current = lines[line - 1];
  final comment = _trailingComment(current, column - 1);
  final head = current.substring(0, column - 1);
  lines[line - 1] = '$head$text${comment == null ? '' : ' $comment'}';
  return (source: lines.join('\n'), line: line);
}

/// Replaces the first line of [stmt] (a whole simple statement, or the
/// header of a block: `Si … Entonces`, `Mientras … Hacer`) with [text].
SourceEdit replaceStatementHead(String source, Stmt stmt, String text) =>
    replaceLineFrom(source, stmt.line, stmt.column, text);

/// Replaces the `Hasta Que …` / `Mientras Que …` line of a Repetir.
SourceEdit replaceRepeatCondition(String source, Program program, RepeatStmt stmt, String text) {
  final line = program.spans!.endLine(stmt);
  final current = source.split('\n')[line - 1];
  return replaceLineFrom(source, line, _indentOf(current).length + 1, text);
}

/// Where a `//` comment starts after [from], skipping texts in quotes.
String? _trailingComment(String line, int from) {
  String? quote;
  for (var i = from; i < line.length; i++) {
    final char = line[i];
    if (quote != null) {
      if (char == quote || (quote == '"' && char == '”')) quote = null;
    } else if (char == '"' || char == "'" || char == '“') {
      quote = char == '“' ? '"' : char;
    } else if (line.startsWith('//', i)) {
      return line.substring(i);
    }
  }
  return null;
}
