import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'ast.dart';
import 'builtins.dart';
import 'errors.dart';
import 'parser.dart';
import 'text.dart';
import 'values.dart';

/// Where a program reads from and writes to: a terminal, a Flutter console
/// widget, or a buffer when grading.
abstract interface class JaguarIO {
  void write(String text);

  /// Returns the next line typed by the user, or null if there is no more
  /// input (e.g. when grading with a fixed list of inputs).
  Future<String?> read();

  void clear();

  Future<void> waitForKey();

  Future<void> sleep(Duration duration);
}

/// In-memory IO with predefined inputs. Used by tests and the grader.
class BufferedIO implements JaguarIO {
  BufferedIO([Iterable<String> inputs = const []]) : _inputs = Queue.of(inputs);

  final Queue<String> _inputs;
  final StringBuffer _output = StringBuffer();

  String get output => _output.toString();

  @override
  void write(String text) => _output.write(text);

  @override
  Future<String?> read() async => _inputs.isEmpty ? null : _inputs.removeFirst();

  @override
  void clear() {}

  @override
  Future<void> waitForKey() async {}

  @override
  Future<void> sleep(Duration duration) async {}
}

class RunOptions {
  const RunOptions({
    this.maxSteps,
    this.arrayBase = 1,
    this.inferNegativeStep = true,
    this.maxCallDepth = 200,
    this.random,
  });

  /// Stops the program after this many steps. Protects the grader and the UI
  /// from infinite loops.
  final int? maxSteps;

  /// First index of arrays and strings: 1 in PSeInt's flexible profile.
  final int arrayBase;

  /// `Para i <- 5 Hasta 1` counts down when no `Con Paso` is given.
  final bool inferNegativeStep;

  final int maxCallDepth;

  /// Fixed random source, for reproducible `Azar` in tests.
  final math.Random? random;
}

/// Called before each statement runs, with the line it is on (the
/// `Hasta Que` line when a Repetir checks its condition). The future lets a
/// debugger pause.
///
/// Returning null (not a future) costs nothing, so a debugger can stay
/// installed for the whole run and only pause when asked.
typedef StepHook = FutureOr<void> Function(Stmt statement, int line);

class Variable {
  Variable(this.name, {this.type});

  final String name;
  JType? type;
  Object? value;
}

class Interpreter {
  Interpreter(this.program, this.io, {this.options = const RunOptions(), this.onStep})
    : _random = options.random ?? math.Random();

  final Program program;
  final JaguarIO io;
  final RunOptions options;
  final StepHook? onStep;
  final math.Random _random;

  final List<Map<String, Variable>> _frames = [];
  int _steps = 0;
  bool _cancelled = false;

  int get steps => _steps;

  /// Variables of the function currently running, by display name.
  Map<String, Object?> get variables => {
    if (_frames.isNotEmpty)
      for (final variable in _frames.last.values) variable.name: variable.value,
  };

  void cancel() => _cancelled = true;

  /// Runs the program. Throws [JaguarError] on a runtime error and
  /// [RunCancelled] if [cancel] was called.
  Future<void> run() async {
    _frames.add({});
    try {
      await _executeBlock(program.main.body);
    } finally {
      _finalVariables = variables;
      _frames.removeLast();
    }
  }

  Map<String, Object?> _finalVariables = const {};

  /// Evaluates [text] with the variables of the moment, for the
  /// evaluator of the step-by-step mode (DFD's Evaluar).
  Future<Object?> evaluateText(String text) async {
    final Stmt statement;
    try {
      statement = parse('Algoritmo evaluar\n__valor <- $text\nFinAlgoritmo').main.body.single;
    } on JaguarError catch (error) {
      throw JaguarError.syntax(error.message, line: 1, hint: error.hint);
    }
    return _evaluate((statement as AssignStmt).value);
  }

  /// The main program's variables when it ended (or stopped), for a
  /// debugger to show the last state.
  Map<String, Object?> get finalVariables => _finalVariables;

  // -------------------------------------------------------------------------
  // Statements

  Future<void> _executeBlock(List<Stmt> statements) async {
    for (final statement in statements) {
      await _execute(statement);
    }
  }

  Future<void> _tick(Stmt statement, {int? line}) async {
    if (_cancelled) throw const RunCancelled();
    _steps++;
    final maxSteps = options.maxSteps;
    if (maxSteps != null && _steps > maxSteps) {
      throw _fail(
        statement,
        'El programa se detuvo después de $maxSteps pasos.',
        hint: '¿Hay un ciclo que nunca termina? Revisa que su condición cambie dentro del ciclo.',
        cause: ErrorCause.stepLimit,
      );
    }
    final pause = onStep?.call(statement, line ?? statement.line);
    if (pause is Future) await pause;
    // Yield now and then so a UI stays responsive during long loops.
    if (_steps % 1000 == 0) await Future<void>.delayed(Duration.zero);
  }

  Future<void> _execute(Stmt statement) async {
    await _tick(statement);
    switch (statement) {
      case DefineStmt s:
        _define(s);
      case DimensionStmt s:
        await _dimension(s);
      case AssignStmt s:
        await _assign(s.target, await _evaluate(s.value), s);
      case WriteStmt s:
        final buffer = StringBuffer();
        for (final value in s.values) {
          final result = await _evaluate(value);
          buffer.write(formatValue(result));
        }
        if (s.newline) buffer.write('\n');
        io.write(buffer.toString());
      case ReadStmt s:
        await _read(s);
      case IfStmt s:
        if (await _condition(s.condition, 'Si')) {
          await _executeBlock(s.thenBody);
        } else if (s.elseBody != null) {
          await _executeBlock(s.elseBody!);
        }
      case SwitchStmt s:
        await _switch(s);
      case WhileStmt s:
        while (await _condition(s.condition, 'Mientras')) {
          await _executeBlock(s.body);
          await _tick(s);
        }
      case RepeatStmt s:
        while (true) {
          await _executeBlock(s.body);
          await _tick(s, line: s.condition.line);
          final condition = await _condition(s.condition, s.untilTrue ? 'Hasta Que' : 'Mientras Que');
          if (condition == s.untilTrue) break;
        }
      case ForStmt s:
        await _for(s);
      case ForEachStmt s:
        await _forEach(s);
      case CallStmt s:
        await _call(s.call, asStatement: true);
      case WaitStmt s:
        if (s.amount == null) {
          await io.waitForKey();
        } else {
          final amount = _requireNumber(await _evaluate(s.amount!), s.amount!, 'El tiempo de Esperar');
          if (amount < 0) throw _fail(s, 'El tiempo de Esperar no puede ser negativo.');
          await io.sleep(Duration(milliseconds: (s.millis ? amount : amount * 1000).round()));
        }
      case ClearStmt _:
        io.clear();
    }
  }

  void _define(DefineStmt s) {
    for (final name in s.names) {
      final variable = _findOrCreate(name);
      variable.type = s.type;
      final value = variable.value;
      if (value is ArrayValue) {
        value.elementType = s.type;
      } else if (value != null) {
        variable.value = _coerce(value, s.type, name, s);
      }
    }
  }

  Future<void> _dimension(DimensionStmt s) async {
    for (final decl in s.arrays) {
      final sizes = <int>[];
      for (final size in decl.sizes) {
        final n = _requireInt(await _evaluate(size), size, 'El tamaño del arreglo');
        if (n < 1) throw _fail(size, 'El tamaño del arreglo debe ser al menos 1, pero es $n.');
        sizes.add(n);
      }
      if (sizes.fold(1, (a, b) => a * b) > 10000000) {
        throw _fail(decl, "El arreglo '${decl.name}' es demasiado grande.");
      }
      final variable = _findOrCreate(decl.name);
      if (variable.value is ArrayValue) {
        throw _fail(decl, "El arreglo '${decl.name}' ya fue dimensionado.");
      }
      variable.value = ArrayValue(decl.name, sizes, elementType: variable.type);
    }
  }

  Future<void> _read(ReadStmt s) async {
    for (final target in s.targets) {
      final input = await io.read();
      if (input == null) {
        throw _fail(
          s,
          'El programa pidió un dato con Leer, pero ya no hay datos de entrada.',
          cause: ErrorCause.noMoreInput,
        );
      }
      final name = target is IndexExpr ? target.name : (target as VarRef).name;
      final type = _typeOfTarget(target);
      await _assign(target, _parseInput(input, type, name, s), s);
    }
  }

  JType? _typeOfTarget(Expr target) {
    if (target is VarRef) return _find(target.name)?.type;
    if (target is IndexExpr) {
      final value = _find(target.name)?.value;
      return value is ArrayValue ? value.elementType : null;
    }
    return null;
  }

  Object _parseInput(String input, JType? type, String name, Node at) {
    final text = input.trim();
    switch (type) {
      case null:
        return parseNumber(text) ?? input;
      case JType.entero:
        final number = parseNumber(text);
        if (number != null && number == number.truncate()) return number.toInt();
        throw _fail(at, "Se esperaba un número entero para '$name', pero se escribió \"$input\".");
      case JType.real:
        final number = parseNumber(text);
        if (number != null) return number.toDouble();
        throw _fail(at, "Se esperaba un número para '$name', pero se escribió \"$input\".");
      case JType.logico:
        final word = normalize(text);
        if (word == 'verdadero' || word == 'v') return true;
        if (word == 'falso' || word == 'f') return false;
        throw _fail(at, "Se esperaba Verdadero o Falso para '$name', pero se escribió \"$input\".");
      case JType.texto:
        return input;
    }
  }

  Future<void> _switch(SwitchStmt s) async {
    final subject = await _evaluate(s.subject);
    for (final option in s.cases) {
      for (final valueExpr in option.values) {
        if (_equals(subject, await _evaluate(valueExpr), valueExpr)) {
          await _executeBlock(option.body);
          return;
        }
      }
    }
    if (s.otherwise != null) await _executeBlock(s.otherwise!);
  }

  Future<void> _for(ForStmt s) async {
    final from = _requireNumber(await _evaluate(s.from), s.from, 'El valor inicial del Para');
    final to = _requireNumber(await _evaluate(s.to), s.to, 'El valor final del Para');
    final num step;
    if (s.step != null) {
      step = _requireNumber(await _evaluate(s.step!), s.step!, 'El paso del Para');
    } else {
      step = options.inferNegativeStep && from > to ? -1 : 1;
    }
    if (step == 0) throw _fail(s.step ?? s, 'El paso del ciclo Para no puede ser 0.');
    final variable = _findOrCreate(s.variable);
    var current = from;
    while (step > 0 ? current <= to : current >= to) {
      variable.value = _coerce(current, variable.type, s.variable, s);
      await _executeBlock(s.body);
      await _tick(s);
      current = _requireNumber(variable.value, s, "La variable '${s.variable}' del Para") + step;
    }
  }

  Future<void> _forEach(ForEachStmt s) async {
    final array = _find(s.arrayName)?.value;
    if (array is! ArrayValue) {
      throw _fail(s, "'${s.arrayName}' no es un arreglo.", hint: 'Créalo antes con: Dimension ${s.arrayName}[tamaño]');
    }
    final element = _findOrCreate(s.variable);
    for (var i = 0; i < array.data.length; i++) {
      element.value = array.data[i];
      await _executeBlock(s.body);
      await _tick(s);
      array.data[i] = _coerce(element.value, array.elementType, s.arrayName, s);
    }
  }

  // -------------------------------------------------------------------------
  // Variables

  Map<String, Variable> get _frame => _frames.last;

  Variable? _find(String name) => _frame[normalize(name)];

  Variable _findOrCreate(String name) => _frame.putIfAbsent(normalize(name), () => Variable(name));

  Object? _readVariable(VarRef ref, {bool allowArray = false}) {
    final variable = _find(ref.name);
    if (variable == null) {
      if (normalize(ref.name) == 'pi') return math.pi;
      final suggestion = closestMatch(ref.name, _frame.values.map((v) => v.name));
      throw _fail(
        ref,
        "La variable '${ref.name}' no existe.",
        hint: suggestion != null
            ? "¿Quisiste decir '$suggestion'?"
            : "Dale un valor antes de usarla, por ejemplo '${ref.name} <- 0' o 'Leer ${ref.name}'.",
      );
    }
    final value = variable.value;
    if (value == null) {
      throw _fail(
        ref,
        "La variable '${ref.name}' todavía no tiene valor.",
        hint: "Asígnale un valor con '${ref.name} <- ...' o 'Leer ${ref.name}' antes de usarla.",
      );
    }
    if (value is ArrayValue && !allowArray) {
      throw _fail(ref, "'${ref.name}' es un arreglo; indica una posición, por ejemplo ${ref.name}[1].");
    }
    return value;
  }

  Future<void> _assign(Expr target, Object? value, Node at) async {
    if (value is ArrayValue) {
      throw _fail(at, 'No se puede asignar un arreglo completo; copia sus elementos uno por uno.');
    }
    switch (target) {
      case VarRef ref:
        final variable = _findOrCreate(ref.name);
        if (variable.value is ArrayValue) {
          throw _fail(at, "'${ref.name}' es un arreglo; indica la posición, por ejemplo ${ref.name}[1] <- ...");
        }
        variable.value = _coerce(value, variable.type, ref.name, at);
      case IndexExpr index:
        final (array, offset) = await _locate(index);
        array.data[offset] = _coerce(value, array.elementType, index.name, at);
      default:
        throw _fail(at, 'Solo se puede asignar a una variable o a una posición de un arreglo.');
    }
  }

  /// Converts [value] to the declared [type] of a variable, or fails.
  Object? _coerce(Object? value, JType? type, String name, Node at) {
    if (type == null || value == null) return value;
    switch (type) {
      case JType.entero:
        if (value is int) return value;
        if (value is double && value == value.truncateToDouble()) return value.toInt();
        throw _fail(
          at,
          "No se puede guardar ${describeValue(value)} en '$name' porque es de tipo Entero.",
          hint: value is double ? 'Usa Trunc() o Redon(), o define la variable como Real.' : null,
        );
      case JType.real:
        if (value is num) return value.toDouble();
      case JType.logico:
        if (value is bool) return value;
      case JType.texto:
        if (value is String) return value;
    }
    throw _fail(
      at,
      "No se puede guardar ${describeValue(value)} en '$name' porque es de tipo ${type.label}.",
      hint: type == JType.texto && value is num ? 'Usa ConvertirATexto() para convertir un número en texto.' : null,
    );
  }

  Future<(ArrayValue, int)> _locate(IndexExpr index) async {
    final variable = _find(index.name);
    final array = variable?.value;
    if (array is! ArrayValue) {
      throw _fail(
        index,
        variable == null ? "El arreglo '${index.name}' no existe." : "'${index.name}' no es un arreglo.",
        hint: 'Créalo antes con: Dimension ${index.name}[tamaño]',
      );
    }
    if (index.indices.length != array.dims.length) {
      throw _fail(
        index,
        "El arreglo '${index.name}' tiene ${array.dims.length} dimensión(es), "
        'pero se usaron ${index.indices.length} índice(s).',
      );
    }
    final base = options.arrayBase;
    var offset = 0;
    for (var i = 0; i < array.dims.length; i++) {
      final indexExpr = index.indices[i];
      final raw = _requireInt(await _evaluate(indexExpr), indexExpr, 'El índice');
      final position = raw - base;
      if (position < 0 || position >= array.dims[i]) {
        throw _fail(
          indexExpr,
          "La posición $raw está fuera del arreglo '${index.name}'.",
          hint: 'Las posiciones válidas van de $base a ${array.dims[i] - 1 + base}.',
        );
      }
      offset = offset * array.dims[i] + position;
    }
    return (array, offset);
  }

  // -------------------------------------------------------------------------
  // Expressions

  Future<Object?> _evaluate(Expr expr) async {
    return switch (expr) {
      NumberLit e => e.value,
      StringLit e => e.value,
      BoolLit e => e.value,
      VarRef e => _readVariable(e),
      IndexExpr e => await _readIndex(e),
      UnaryExpr e => await _unary(e),
      BinaryExpr e => await _binary(e),
      CallExpr e => await _call(e),
    };
  }

  Future<Object?> _readIndex(IndexExpr index) async {
    final (array, offset) = await _locate(index);
    final value = array.data[offset];
    if (value == null) {
      throw _fail(index, "Esa posición del arreglo '${index.name}' todavía no tiene valor.");
    }
    return value;
  }

  Future<Object?> _unary(UnaryExpr e) async {
    final value = await _evaluate(e.operand);
    if (e.op == '-') return -_requireNumber(value, e, "El signo '-'");
    return !_requireBool(value, e, "'No'");
  }

  Future<Object?> _binary(BinaryExpr e) async {
    if (e.op == 'y' || e.op == 'o') {
      final label = e.op == 'y' ? "'Y'" : "'O'";
      final left = _requireBool(await _evaluate(e.left), e, label);
      if (e.op == 'y' && !left) return false;
      if (e.op == 'o' && left) return true;
      return _requireBool(await _evaluate(e.right), e, label);
    }
    final left = await _evaluate(e.left);
    final right = await _evaluate(e.right);
    switch (e.op) {
      case '+':
        if (left is num && right is num) return _finite(left + right, e);
        // A text with a number or a Verdadero/Falso joins them, as in "Hola " + nombre.
        if ((left is String && (right is String || right is num || right is bool)) ||
            (right is String && (left is num || left is bool))) {
          return formatValue(left) + formatValue(right);
        }
        throw _fail(
          e,
          'No se puede sumar ${describeValue(left)} con ${describeValue(right)}.',
          hint: left is String || right is String
              ? 'Para unir textos con valores usa +, o comas en Escribir: Escribir "Total: ", x'
              : null,
        );
      case '-':
        return _finite(_requireNumber(left, e, "La resta '-'") - _requireNumber(right, e, "La resta '-'"), e);
      case '*':
        return _finite(
          _requireNumber(left, e, "La multiplicación '*'") * _requireNumber(right, e, "La multiplicación '*'"),
          e,
        );
      case '/':
        final dividend = _requireNumber(left, e, "La división '/'");
        final divisor = _requireNumber(right, e, "La división '/'");
        if (divisor == 0) throw _fail(e, 'No se puede dividir entre cero.');
        return _finite(dividend / divisor, e);
      case 'mod':
        final dividend = _requireInt(left, e, 'MOD');
        final divisor = _requireInt(right, e, 'MOD');
        if (divisor == 0) throw _fail(e, 'No se puede calcular MOD entre cero.');
        return dividend.remainder(divisor);
      case '^':
        return _finite(
          math.pow(_requireNumber(left, e, "La potencia '^'"), _requireNumber(right, e, "La potencia '^'")),
          e,
        );
      case '=':
        return _equals(left, right, e);
      case '<>':
        return !_equals(left, right, e);
      default:
        final comparison = _compare(left, right, e);
        return switch (e.op) {
          '<' => comparison < 0,
          '>' => comparison > 0,
          '<=' => comparison <= 0,
          _ => comparison >= 0,
        };
    }
  }

  bool _equals(Object? left, Object? right, Node at) {
    if (left is num && right is num) return left == right;
    if (left.runtimeType == right.runtimeType) return left == right;
    throw _fail(at, 'No se puede comparar ${describeValue(left)} con ${describeValue(right)}.');
  }

  int _compare(Object? left, Object? right, Node at) {
    if (left is num && right is num) return left.compareTo(right);
    if (left is String && right is String) return left.compareTo(right);
    throw _fail(at, 'No se puede comparar ${describeValue(left)} con ${describeValue(right)}.');
  }

  Future<Object?> _call(CallExpr call, {bool asStatement = false}) async {
    final key = normalize(call.name);
    final function = program.functions[key];
    if (function != null) return _callUser(function, call, asStatement: asStatement);
    final builtin = builtins[key];
    if (builtin == null) throw _fail(call, "No existe la función '${call.name}'.");
    final args = [for (final arg in call.args) await _evaluate(arg)];
    final result = builtin.run(BuiltinArgs(builtin, args, call, random: _random, arrayBase: options.arrayBase));
    return result is num ? _finite(result, call) : result;
  }

  Future<Object?> _callUser(Subprogram function, CallExpr call, {required bool asStatement}) async {
    if (_frames.length >= options.maxCallDepth) {
      throw _fail(
        call,
        'Demasiadas llamadas a funciones, una dentro de otra.',
        hint: '¿Una función recursiva que nunca llega a su caso base?',
      );
    }
    final frame = <String, Variable>{};
    final writeBacks = <void Function()>[];
    for (var i = 0; i < function.params.length; i++) {
      final param = function.params[i];
      final arg = call.args[i];
      final key = normalize(param.name);
      if (!param.byRef) {
        final value = arg is VarRef ? _readVariable(arg, allowArray: true) : await _evaluate(arg);
        frame[key] = Variable(param.name)..value = value;
      } else if (arg is VarRef) {
        // Same Variable object: changes inside the function are visible outside.
        frame[key] = _findOrCreate(arg.name);
      } else if (arg is IndexExpr) {
        final (array, offset) = await _locate(arg);
        final temp = Variable(param.name, type: array.elementType)..value = array.data[offset];
        frame[key] = temp;
        writeBacks.add(() => array.data[offset] = temp.value);
      } else {
        throw _fail(
          arg,
          "El parámetro '${param.name}' de '${function.name}' es Por Referencia, "
          'así que necesita una variable, no un valor.',
        );
      }
    }
    final returnVar = function.returnVar;
    final result = returnVar == null ? null : frame.putIfAbsent(normalize(returnVar), () => Variable(returnVar));

    _frames.add(frame);
    // Async calls that never suspend keep growing the native stack; yielding
    // to the event loop every few levels resets it so deep recursion is safe.
    if (_frames.length % 32 == 0) await Future<void>.delayed(Duration.zero);
    try {
      await _executeBlock(function.body);
    } finally {
      _frames.removeLast();
    }
    for (final writeBack in writeBacks) {
      writeBack();
    }

    if (asStatement || result == null) return null;
    if (result.value == null) {
      throw _fail(call, "La función '${function.name}' terminó sin darle un valor a '$returnVar'.");
    }
    return result.value;
  }

  // -------------------------------------------------------------------------
  // Helpers

  JaguarError _fail(Node at, String message, {String? hint, ErrorCause cause = ErrorCause.other}) =>
      JaguarError.runtime(message, line: at.line, column: at.column, hint: hint, cause: cause);

  Future<bool> _condition(Expr condition, String statement) async {
    final value = await _evaluate(condition);
    if (value is bool) return value;
    throw _fail(
      condition,
      "La condición del '$statement' debe ser Verdadero o Falso, pero es ${describeValue(value)}.",
      hint: 'Usa una comparación, por ejemplo: x > 0',
    );
  }

  num _requireNumber(Object? value, Node at, String what) {
    if (value is num) return value;
    throw _fail(at, '$what necesita números, pero recibió ${describeValue(value)}.');
  }

  int _requireInt(Object? value, Node at, String what) {
    final number = _requireNumber(value, at, what);
    if (number is int) return number;
    if (number == number.truncateToDouble()) return number.toInt();
    throw _fail(at, '$what debe ser un número entero, pero es ${describeValue(value)}.');
  }

  bool _requireBool(Object? value, Node at, String what) {
    if (value is bool) return value;
    throw _fail(at, '$what necesita valores Verdadero o Falso, pero recibió ${describeValue(value)}.');
  }

  num _finite(num value, Node at) {
    if (value is double && !value.isFinite) {
      throw _fail(at, 'El resultado no es un número válido (es demasiado grande o no está definido).');
    }
    return value;
  }
}
