import 'dart:math' as math;

import 'ast.dart';
import 'errors.dart';
import 'text.dart';
import 'values.dart';

typedef BuiltinFunction = Object Function(BuiltinArgs args);

final class Builtin {
  const Builtin(this.name, this.arity, this.run);

  final String name;
  final int arity;
  final BuiltinFunction run;
}

/// Arguments of a builtin call, with typed accessors that fail with
/// student-friendly messages.
final class BuiltinArgs {
  BuiltinArgs(this.builtin, this.values, this.call, {required this.random, required this.arrayBase});

  final Builtin builtin;
  final List<Object?> values;
  final CallExpr call;
  final math.Random random;
  final int arrayBase;

  JaguarError fail(String message, {String? hint}) =>
      JaguarError.runtime(message, line: call.line, column: call.column, hint: hint);

  num number(int index) {
    final value = values[index];
    if (value is num) return value;
    throw fail('${builtin.name} necesita un número, pero recibió ${describeValue(value)}.');
  }

  int integer(int index) {
    final value = number(index);
    if (value is int) return value;
    if (value == value.truncateToDouble()) return value.toInt();
    throw fail('${builtin.name} necesita un número entero, pero recibió ${describeValue(value)}.');
  }

  String text(int index) {
    final value = values[index];
    if (value is String) return value;
    throw fail(
      '${builtin.name} necesita un texto, pero recibió ${describeValue(value)}.',
      hint: value is num ? 'Usa ConvertirATexto() para convertir un número en texto.' : null,
    );
  }
}

/// Builtins keyed by normalized name.
final Map<String, Builtin> builtins = {for (final builtin in _all) normalize(builtin.name): builtin};

Iterable<String> get builtinNames => _all.map((b) => b.name);

final List<Builtin> _all = [
  Builtin('Raiz', 1, _sqrt),
  Builtin('RC', 1, _sqrt),
  Builtin('Abs', 1, (a) => a.number(0).abs()),
  Builtin('Ln', 1, (a) {
    final x = a.number(0);
    if (x <= 0) throw a.fail('Ln solo funciona con números mayores que cero.');
    return math.log(x);
  }),
  Builtin('Exp', 1, (a) => math.exp(a.number(0))),
  Builtin('Sen', 1, (a) => math.sin(a.number(0))),
  Builtin('Cos', 1, (a) => math.cos(a.number(0))),
  Builtin('Tan', 1, (a) => math.tan(a.number(0))),
  Builtin('ASen', 1, (a) => math.asin(_unitRange(a))),
  Builtin('ACos', 1, (a) => math.acos(_unitRange(a))),
  Builtin('ATan', 1, (a) => math.atan(a.number(0))),
  Builtin('Trunc', 1, (a) => a.number(0).truncate()),
  Builtin('Redon', 1, (a) => a.number(0).round()),
  Builtin('Azar', 1, (a) {
    final n = a.integer(0);
    if (n <= 0) throw a.fail('Azar necesita un número mayor que cero.');
    return a.random.nextInt(n);
  }),
  Builtin('Aleatorio', 2, (a) {
    final low = a.integer(0), high = a.integer(1);
    if (low > high) throw a.fail('En Aleatorio(a, b) el primer número no puede ser mayor que el segundo.');
    return low + a.random.nextInt(high - low + 1);
  }),
  Builtin('Longitud', 1, (a) => a.text(0).length),
  Builtin('Mayusculas', 1, (a) => a.text(0).toUpperCase()),
  Builtin('Minusculas', 1, (a) => a.text(0).toLowerCase()),
  Builtin('Subcadena', 3, _substring),
  Builtin('Concatenar', 2, (a) => a.text(0) + a.text(1)),
  Builtin('ConvertirANumero', 1, (a) {
    final number = parseNumber(a.text(0));
    if (number == null) throw a.fail('"${a.text(0)}" no es un número.');
    return number;
  }),
  Builtin('ConvertirATexto', 1, (a) => formatValue(a.number(0))),
];

Object _sqrt(BuiltinArgs a) {
  final x = a.number(0);
  if (x < 0) throw a.fail('No se puede sacar la raíz cuadrada de un número negativo (${formatValue(x)}).');
  return math.sqrt(x);
}

num _unitRange(BuiltinArgs a) {
  final x = a.number(0);
  if (x < -1 || x > 1) throw a.fail('${a.builtin.name} solo funciona con valores entre -1 y 1.');
  return x;
}

/// `Subcadena(s, desde, hasta)`, both ends included. Positions use the same
/// base as arrays, like PSeInt.
Object _substring(BuiltinArgs a) {
  final text = a.text(0);
  final from = a.integer(1) - a.arrayBase;
  final to = a.integer(2) - a.arrayBase;
  if (from > to) return '';
  final start = from.clamp(0, text.length);
  final end = (to + 1).clamp(start, text.length);
  return text.substring(start, end);
}
