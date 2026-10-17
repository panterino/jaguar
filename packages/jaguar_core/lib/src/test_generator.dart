import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'ast.dart';
import 'errors.dart';
import 'exercise.dart';
import 'interpreter.dart';
import 'parser.dart';
import 'text.dart';

/// Proposes test cases for an exercise from the teacher's solution, so the
/// teacher doesn't type them by hand.
///
/// No AI: it reads the program for interesting values (the limits of its
/// comparisons, the divisors of MOD, its texts), runs the solution with
/// many combinations of them and keeps the runs that go through different
/// parts of the program or show something different. Hidden cases are the
/// last ones, usually the edge values.
Future<List<TestCase>> suggestTests(
  String solution, {
  int count = 5,
  int hidden = 1,
  MatchMode mode = MatchMode.flexible,
  int attempts = 60,
}) async {
  final program = parse(solution);
  final values = _InterestingValues.of(program);
  final runs = <_Run>[];
  for (var attempt = 0; attempt < attempts; attempt++) {
    final run = await _run(program, values, math.Random(attempt), attempt);
    if (run != null) runs.add(run);
  }

  // Greedy: first the runs that cover lines not covered yet, then the ones
  // that show something new.
  final chosen = <_Run>[];
  final covered = <int>{};
  final outputs = <String>{};
  final seenInputs = <String>{};
  while (chosen.length < count) {
    _Run? best;
    var bestScore = 0;
    for (final run in runs) {
      if (seenInputs.contains(run.inputs.join('\u0000'))) continue;
      final newLines = run.lines.difference(covered).length;
      final newOutput = outputs.contains(normalize(run.output)) ? 0 : 1;
      // Fewer inputs read first: simpler cases are easier to understand.
      final score = newLines * 10 + newOutput * 5 + (newLines + newOutput > 0 ? 1 : 0);
      if (score > bestScore || (score == bestScore && best != null && run.inputs.length < best.inputs.length)) {
        best = run;
        bestScore = score;
      }
    }
    if (best == null || bestScore == 0) break;
    chosen.add(best);
    covered.addAll(best.lines);
    outputs.add(normalize(best.output));
    seenInputs.add(best.inputs.join('\u0000'));
  }

  final tests = <TestCase>[];
  for (var i = 0; i < chosen.length; i++) {
    final inputs = chosen[i].inputs;
    final expected = await expectedOutputFor(solution, inputs, mode, caseIndex: i);
    if (expected.error != null) continue;
    tests.add(
      TestCase(
        name: inputs.isEmpty ? 'Sin datos' : 'Con ${inputs.join(', ')}',
        inputs: inputs,
        expected: expected.output,
        hidden: chosen.length > hidden + 1 && i >= chosen.length - hidden,
      ),
    );
  }
  return tests;
}

class _Run {
  _Run(this.inputs, this.output, this.lines);

  final List<String> inputs;
  final String output;
  final Set<int> lines;
}

Future<_Run?> _run(Program program, _InterestingValues values, math.Random random, int attempt) async {
  final io = _GeneratingIO(values, random, attempt);
  final lines = <int>{};
  final interpreter = Interpreter(
    program,
    io,
    options: RunOptions(maxSteps: 20000, random: math.Random(attempt)),
    onStep: (statement, line) {
      lines.add(line);
      if (statement is ReadStmt) io.reading(statement);
      return null;
    },
  );
  try {
    await interpreter.run();
  } on JaguarError {
    // An input that breaks the solution (or needs too many) is not a case.
    return null;
  }
  return _Run(io.used, io.output.toString(), lines);
}

/// Answers `Leer` with interesting values of the right kind.
class _GeneratingIO implements JaguarIO {
  _GeneratingIO(this.values, this.random, this.attempt);

  static const _maxInputs = 12;

  final _InterestingValues values;
  final math.Random random;
  final int attempt;
  final StringBuffer output = StringBuffer();
  final List<String> used = [];
  final Queue<String> _targets = Queue();

  void reading(ReadStmt statement) {
    _targets
      ..clear()
      ..addAll([for (final t in statement.targets) normalize(t is IndexExpr ? t.name : (t as VarRef).name)]);
  }

  @override
  Future<String?> read() async {
    if (used.length >= _maxInputs) return null;
    final name = _targets.isEmpty ? '' : _targets.removeFirst();
    final value = values.pick(name, random, attempt, readsSoFar: used.length);
    used.add(value);
    return value;
  }

  @override
  void write(String text) => output.write(text);

  @override
  void clear() {}

  @override
  Future<void> waitForKey() async {}

  @override
  Future<void> sleep(Duration duration) async {}
}

enum _Kind { number, integer, text, logic }

/// Values worth trying, read from the program itself.
class _InterestingValues {
  _InterestingValues(this.numbers, this.texts, this.kinds);

  factory _InterestingValues.of(Program program) {
    final numbers = <num>{0, 1, -1, 2, 3, 5, 7, 10, 12, 100};
    final texts = <String>{'Ana', 'hola', 'si', 'no'};
    final kinds = <String, _Kind>{};
    void expr(Expr e, {bool inComparison = false}) {
      switch (e) {
        case NumberLit(:final value):
          if (inComparison) numbers.addAll([value - 1, value, value + 1]);
          numbers.add(value);
        case StringLit(:final value):
          if (value.trim().isNotEmpty && value.length <= 20) texts.add(value);
        case BinaryExpr(:final op, :final left, :final right):
          final comparison = const {'=', '<>', '<', '>', '<=', '>='}.contains(op);
          if (op == 'mod' && right is NumberLit) {
            final k = right.value;
            numbers.addAll([k, k + 1, 2 * k, 2 * k + 1]);
          }
          // A variable compared with a text is read as text.
          for (final (a, b) in [(left, right), (right, left)]) {
            if (a is VarRef && b is StringLit) kinds.putIfAbsent(normalize(a.name), () => _Kind.text);
          }
          expr(left, inComparison: comparison);
          expr(right, inComparison: comparison);
        case UnaryExpr(:final operand):
          expr(operand, inComparison: inComparison);
        case CallExpr(:final args) || IndexExpr(indices: final args):
          for (final a in args) {
            expr(a);
          }
        case VarRef() || BoolLit():
          break;
      }
    }

    void visit(List<Stmt> statements) {
      for (final s in statements) {
        switch (s) {
          case DefineStmt(:final names, :final type):
            for (final n in names) {
              kinds[normalize(n)] = switch (type) {
                JType.entero => _Kind.integer,
                JType.real => _Kind.number,
                JType.logico => _Kind.logic,
                JType.texto => _Kind.text,
              };
            }
          case AssignStmt(:final value):
            expr(value);
          case WriteStmt(:final values):
            values.forEach(expr);
          case IfStmt(:final condition, :final thenBody, :final elseBody):
            expr(condition);
            visit(thenBody);
            visit(elseBody ?? const []);
          case SwitchStmt(:final subject, :final cases, :final otherwise):
            expr(subject);
            for (final c in cases) {
              for (final v in c.values) {
                expr(v, inComparison: true);
              }
              visit(c.body);
            }
            visit(otherwise ?? const []);
          case WhileStmt(:final condition, :final body) || RepeatStmt(:final condition, :final body):
            expr(condition);
            visit(body);
          case ForStmt(:final from, :final to, :final body):
            expr(from);
            expr(to);
            visit(body);
          case ForEachStmt(:final body):
            visit(body);
          default:
            break;
        }
      }
    }

    for (final sub in [program.main, ...program.functions.values]) {
      visit(sub.body);
    }
    // Large values make loops long and outputs hard to read.
    numbers.removeWhere((n) => n.abs() > 1000);
    return _InterestingValues(numbers.toList()..sort(), texts.toList(), kinds);
  }

  final List<num> numbers;
  final List<String> texts;
  final Map<String, _Kind> kinds;

  String pick(String name, math.Random random, int attempt, {required int readsSoFar}) {
    // After several reads, offer values that usually end a loop that reads
    // until a sentinel (0, -1, "no").
    final ending = readsSoFar >= 6;
    switch (kinds[name] ?? _Kind.number) {
      case _Kind.text:
        if (ending) return 'no';
        return texts[random.nextInt(texts.length)];
      case _Kind.logic:
        return random.nextBool() ? 'Verdadero' : 'Falso';
      case _Kind.integer || _Kind.number:
        if (ending) return readsSoFar.isEven ? '0' : '-1';
        // The first attempts walk the list in order so every value is tried.
        final value = attempt < numbers.length && readsSoFar == 0
            ? numbers[attempt]
            : numbers[random.nextInt(numbers.length)];
        final isInteger = kinds[name] == _Kind.integer || value == value.truncate();
        return isInteger ? '${value.toInt()}' : '$value';
    }
  }
}
