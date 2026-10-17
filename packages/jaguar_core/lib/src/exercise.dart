import 'dart:collection';
import 'dart:math' as math;

import 'errors.dart';
import 'interpreter.dart';
import 'parser.dart';
import 'runner.dart';
import 'text.dart';

/// How a program's output is compared with the expected output.
enum MatchMode {
  /// Expected lines must appear in order inside the output, ignoring case,
  /// accents and extra spaces. Students can word their own prompts
  /// ("Dame un número:") without failing.
  flexible,

  /// The whole output must match line by line (trailing spaces ignored).
  exact,
}

/// "If the program gets these inputs, it must show this."
final class TestCase {
  const TestCase({this.name = '', this.inputs = const [], required this.expected, this.hidden = false});

  factory TestCase.fromJson(Map<String, Object?> json) => TestCase(
    name: json['n'] as String? ?? '',
    inputs: [for (final input in (json['i'] as List?) ?? const []) '$input'],
    expected: json['o'] as String? ?? '',
    hidden: json['h'] == true,
  );

  /// Optional, like "Número par". Unnamed tests show as "Prueba 1".
  final String name;

  /// One line per `Leer`.
  final List<String> inputs;
  final String expected;

  /// Hidden cases don't show their data to the student, so the solution
  /// can't be written just for the visible examples.
  final bool hidden;

  // Short keys keep shared links (and their QR codes) small.
  Map<String, Object?> toJson() => {if (name.isNotEmpty) 'n': name, 'i': inputs, 'o': expected, if (hidden) 'h': true};
}

final class Exercise {
  const Exercise({
    required this.id,
    required this.title,
    this.statement = '',
    this.cases = const [],
    this.mode = MatchMode.flexible,
    this.revision = 1,
  });

  factory Exercise.fromJson(Map<String, Object?> json) => Exercise(
    id: json['id']! as String,
    title: json['t'] as String? ?? 'Ejercicio',
    statement: json['s'] as String? ?? '',
    mode: json['m'] == 'exacta' ? MatchMode.exact : MatchMode.flexible,
    revision: (json['r'] as num?)?.toInt() ?? 1,
    cases: [for (final c in (json['c'] as List?) ?? const []) TestCase.fromJson((c as Map).cast<String, Object?>())],
  );

  final String id;
  final String title;
  final String statement;
  final List<TestCase> cases;
  final MatchMode mode;

  /// Goes up each time the teacher edits the exercise. Opening a newer
  /// revision updates the tests and keeps the student's code.
  final int revision;

  Map<String, Object?> toJson() => {
    'v': 1,
    'id': id,
    if (revision > 1) 'r': revision,
    't': title,
    if (statement.isNotEmpty) 's': statement,
    if (mode == MatchMode.exact) 'm': 'exacta',
    'c': [for (final c in cases) c.toJson()],
  };
}

/// Why a test failed, so it can be explained in words.
enum CaseFailure {
  /// The program ran but showed something else.
  wrongOutput,

  /// It used `Leer` more times than the test has inputs.
  missingInput,

  /// It ran out of steps: most likely an endless loop.
  tooSlow,

  /// Another runtime error, like dividing by zero.
  error,
}

final class CaseResult {
  const CaseResult(this.testCase, this.output, this.error, {required this.passed, this.mismatch});

  final TestCase testCase;
  final String output;
  final JaguarError? error;
  final bool passed;

  /// For [CaseFailure.wrongOutput]: the first expected line that is missing
  /// and the line the program showed in its place, if any.
  final OutputMismatch? mismatch;

  CaseFailure? get failure {
    if (passed) return null;
    return switch (error?.cause) {
      null => CaseFailure.wrongOutput,
      ErrorCause.noMoreInput => CaseFailure.missingInput,
      ErrorCause.stepLimit => CaseFailure.tooSlow,
      ErrorCause.other => CaseFailure.error,
    };
  }
}

final class OutputMismatch {
  const OutputMismatch({required this.expectedLine, required this.expected, this.actual});

  /// 0-based, among the non-empty expected lines.
  final int expectedLine;
  final String expected;

  /// What the program showed there, or null if its output ended before.
  final String? actual;
}

final class CheckResult {
  const CheckResult(this.cases, {this.syntaxError});

  final List<CaseResult> cases;

  /// Set when the program doesn't even parse; no case was run.
  final JaguarError? syntaxError;

  int get passedCount => cases.where((c) => c.passed).length;

  bool get passed => syntaxError == null && cases.isNotEmpty && passedCount == cases.length;
}

/// Runs [source] against every case of [exercise].
Future<CheckResult> checkSolution(String source, Exercise exercise, {int maxSteps = 200000}) =>
    runTests(source, exercise.cases, exercise.mode, maxSteps: maxSteps);

/// Runs [source] once per test with its inputs and compares the output.
/// Works the same for a teacher's exercise, a challenge or the student's
/// own tests.
Future<CheckResult> runTests(String source, List<TestCase> tests, MatchMode mode, {int maxSteps = 200000}) async {
  try {
    parse(source);
  } on JaguarError catch (error) {
    return CheckResult(const [], syntaxError: error);
  }
  final results = <CaseResult>[];
  for (var i = 0; i < tests.length; i++) {
    final testCase = tests[i];
    final run = await runProgram(
      source,
      inputs: testCase.inputs,
      // Fixed seed: a case must give the same result every time.
      options: RunOptions(maxSteps: maxSteps, random: math.Random(i)),
    );
    final mismatch = run.error == null ? firstMismatch(run.output, testCase.expected, mode) : null;
    final passed = run.error == null && mismatch == null;
    results.add(CaseResult(testCase, run.output, run.error, passed: passed, mismatch: mismatch));
  }
  return CheckResult(results);
}

/// Runs the teacher's solution for one case and returns what a student's
/// program must show.
///
/// In [MatchMode.flexible] the prompts that ask for each input (the line
/// shown right before every `Leer`, like "Escribe un número:") are left out:
/// each student words them differently, so they must not be required.
Future<({String output, JaguarError? error})> expectedOutputFor(
  String source,
  List<String> inputs,
  MatchMode mode, {
  int caseIndex = 0,
}) async {
  final io = _PromptTrackingIO(inputs);
  try {
    final options = RunOptions(maxSteps: 1000000, random: math.Random(caseIndex));
    await Interpreter(parse(source), io, options: options).run();
  } on JaguarError catch (error) {
    return (output: io.output, error: error);
  }
  final output = mode == MatchMode.flexible ? io.outputWithoutPrompts : io.output;
  return (output: output.trimRight(), error: null);
}

/// Records which part of the output was a prompt: the last line written
/// before each read.
class _PromptTrackingIO implements JaguarIO {
  _PromptTrackingIO(List<String> inputs) : _inputs = Queue.of(inputs);

  final Queue<String> _inputs;
  final StringBuffer _buffer = StringBuffer();
  final List<(int, int)> _prompts = [];
  int _lastRead = 0;

  String get output => _buffer.toString();

  String get outputWithoutPrompts {
    final text = output;
    final result = StringBuffer();
    var position = 0;
    for (final (start, end) in _prompts) {
      result.write(text.substring(position, start));
      position = end;
    }
    result.write(text.substring(position));
    return result.toString();
  }

  @override
  void write(String text) => _buffer.write(text);

  @override
  Future<String?> read() async {
    final text = output;
    final end = text.length;
    if (end > _lastRead) {
      // The prompt is the last line, with or without its newline
      // (`Escribir Sin Saltar "Número: "`).
      final searchFrom = text.endsWith('\n') ? end - 2 : end - 1;
      var start = searchFrom < 0 ? 0 : text.lastIndexOf('\n', searchFrom) + 1;
      if (start < _lastRead) start = _lastRead;
      if (text.substring(start, end).trim().isNotEmpty) _prompts.add((start, end));
    }
    _lastRead = end;
    return _inputs.isEmpty ? null : _inputs.removeFirst();
  }

  @override
  void clear() {}

  @override
  Future<void> waitForKey() async {}

  @override
  Future<void> sleep(Duration duration) async {}
}

bool outputMatches(String actual, String expected, MatchMode mode) => firstMismatch(actual, expected, mode) == null;

/// Where [actual] stops matching [expected], or null when it matches.
OutputMismatch? firstMismatch(String actual, String expected, MatchMode mode) {
  switch (mode) {
    case MatchMode.exact:
      final got = _exact(actual).split('\n');
      final wanted = _exact(expected).split('\n');
      for (var i = 0; i < math.max(got.length, wanted.length); i++) {
        final want = i < wanted.length ? wanted[i] : null;
        final have = i < got.length ? got[i] : null;
        if (want == have) continue;
        // Extra output after everything expected.
        if (want == null) return OutputMismatch(expectedLine: i, expected: '(nada más)', actual: have);
        return OutputMismatch(expectedLine: i, expected: want, actual: have);
      }
      return null;
    case MatchMode.flexible:
      final gotRaw = _nonEmptyLines(actual);
      final got = [for (final line in gotRaw) _loose(line)];
      final wantedRaw = _nonEmptyLines(expected);
      var from = 0;
      for (var i = 0; i < wantedRaw.length; i++) {
        final index = _indexOfLine(got, _loose(wantedRaw[i]), from);
        if (index < 0) {
          return OutputMismatch(
            expectedLine: i,
            expected: wantedRaw[i].trim(),
            actual: from < gotRaw.length ? gotRaw[from].trim() : null,
          );
        }
        from = index + 1;
      }
      return null;
  }
}

String _exact(String text) =>
    text.replaceAll('\r\n', '\n').split('\n').map((line) => line.trimRight()).join('\n').trimRight();

final _spaces = RegExp(r'\s+');

List<String> _nonEmptyLines(String text) => [
  for (final line in text.split(RegExp(r'\r?\n')))
    if (line.trim().isNotEmpty) line,
];

String _loose(String line) => normalize(line).replaceAll(_spaces, ' ').trim();

int _indexOfLine(List<String> lines, String wanted, int from) {
  for (var i = from; i < lines.length; i++) {
    if (_containsWhole(lines[i], wanted)) return i;
  }
  return -1;
}

final _wordChar = RegExp(r'[a-z0-9ñ_]');

/// Like `contains`, but the match can't start or end inside a word or
/// number, so "8 es par" doesn't match "18 es par".
bool _containsWhole(String haystack, String needle) {
  var start = haystack.indexOf(needle);
  while (start >= 0) {
    final end = start + needle.length;
    final before = start == 0 ? '' : haystack[start - 1];
    final after = end >= haystack.length ? '' : haystack[end];
    final startsClean = before.isEmpty || !_wordChar.hasMatch(before) || !_wordChar.hasMatch(needle[0]);
    final endsClean = after.isEmpty || !_wordChar.hasMatch(after) || !_wordChar.hasMatch(needle[needle.length - 1]);
    if (startsClean && endsClean) return true;
    start = haystack.indexOf(needle, start + 1);
  }
  return false;
}
