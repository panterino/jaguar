import 'dart:convert';

import 'errors.dart';
import 'interpreter.dart';
import 'parser.dart';

class RunResult {
  const RunResult(this.output, this.error, this.steps);

  final String output;
  final JaguarError? error;
  final int steps;

  bool get ok => error == null;
}

/// Parses and runs [source] with fixed [inputs], capturing the output.
/// Never throws for errors in the program: they come back in [RunResult.error].
Future<RunResult> runProgram(
  String source, {
  List<String> inputs = const [],
  RunOptions options = const RunOptions(maxSteps: 1000000),
}) async {
  final io = BufferedIO(inputs);
  Interpreter? interpreter;
  try {
    interpreter = Interpreter(parse(source), io, options: options);
    await interpreter.run();
    return RunResult(io.output, null, interpreter.steps);
  } on JaguarError catch (error) {
    return RunResult(io.output, error, interpreter?.steps ?? 0);
  }
}

/// Decodes a `.psc` file. PSeInt on Windows usually saves in Latin-1, newer
/// files and other editors use UTF-8.
String decodeSource(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}
