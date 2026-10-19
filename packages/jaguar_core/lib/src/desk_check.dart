import 'errors.dart';
import 'interpreter.dart';
import 'parser.dart';
import 'values.dart';

/// One row of a desk check: an instruction that ran and how the variables
/// were right after it.
class DeskCheckRow {
  const DeskCheckRow({required this.line, required this.instruction, required this.values, required this.output});

  final int line;

  /// The source line, trimmed, as the student wrote it.
  final String instruction;

  /// Variable name → value as text (`debugValue`), only for the variables
  /// that existed at that moment.
  final Map<String, String> values;

  /// What this instruction wrote on the screen, if anything.
  final String output;
}

/// The "prueba de escritorio" (desk check, trace table) of a program for
/// some inputs, the way it is done by hand in class: one row per
/// instruction, one column per variable.
class DeskCheck {
  const DeskCheck({required this.variables, required this.rows, this.error, this.truncated = false});

  /// Column order: in the order variables first got a value.
  final List<String> variables;
  final List<DeskCheckRow> rows;
  final JaguarError? error;

  /// True when the program ran longer than the table can show.
  final bool truncated;

  /// The value a variable had in [row], or '' when it did not exist yet.
  String value(int row, String variable) => rows[row].values[variable] ?? '';

  /// True when [variable] changed in [row] compared to the row before.
  bool changed(int row, String variable) {
    final now = rows[row].values[variable];
    if (now == null) return false;
    return row == 0 || rows[row - 1].values[variable] != now;
  }

  /// Tab-separated, to paste in a spreadsheet or a document.
  String toTsv() {
    final header = ['Paso', 'Línea', 'Instrucción', ...variables, 'Pantalla'];
    final lines = [header.join('\t')];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      lines.add(
        [
          '${i + 1}',
          '${row.line}',
          row.instruction,
          for (final v in variables) value(i, v),
          row.output.replaceAll('\n', ' ').trim(),
        ].join('\t'),
      );
    }
    return lines.join('\n');
  }
}

/// Runs [source] with [inputs] and records its desk check, up to [maxRows]
/// rows. Errors in the program end the table and come back in
/// [DeskCheck.error], like in [runProgram].
Future<DeskCheck> deskCheck(String source, {List<String> inputs = const [], int maxRows = 300}) async {
  final lines = source.split('\n');
  final io = BufferedIO(inputs);
  final rows = <DeskCheckRow>[];
  final variables = <String>[];
  Interpreter? interpreter;
  int? pendingLine;
  var outputSoFar = 0;
  var truncated = false;

  void record(Map<String, Object?> state) {
    final line = pendingLine;
    if (line == null) return;
    pendingLine = null;
    for (final name in state.keys) {
      if (state[name] != null && !variables.contains(name)) variables.add(name);
    }
    final output = io.output.substring(outputSoFar);
    outputSoFar = io.output.length;
    rows.add(
      DeskCheckRow(
        line: line,
        instruction: line - 1 < lines.length ? lines[line - 1].trim() : '',
        values: {
          for (final entry in state.entries)
            if (entry.value != null) entry.key: debugValue(entry.value),
        },
        output: output,
      ),
    );
  }

  JaguarError? error;
  try {
    interpreter = Interpreter(
      parse(source),
      io,
      options: const RunOptions(maxSteps: 100000),
      onStep: (statement, line) {
        // The previous instruction has finished: its row shows the state now.
        record(interpreter!.variables);
        if (rows.length >= maxRows) {
          truncated = true;
          interpreter.cancel();
        }
        pendingLine = line;
      },
    );
    await interpreter.run();
  } on JaguarError catch (e) {
    error = e;
  } on RunCancelled {
    // Reached maxRows.
  }
  if (!truncated) record(interpreter?.finalVariables ?? const {});
  return DeskCheck(variables: variables, rows: rows, error: error, truncated: truncated);
}
