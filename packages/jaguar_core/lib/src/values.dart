import 'ast.dart';

/// A PSeInt array. Values are stored flat in row-major order.
class ArrayValue {
  ArrayValue(this.name, this.dims, {this.elementType})
    : data = List<Object?>.filled(dims.fold(1, (a, b) => a * b), null);

  final String name;
  final List<int> dims;
  final List<Object?> data;
  JType? elementType;
}

final _numberPattern = RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$');

/// Parses user input or text into a number, or null when it is not one.
num? parseNumber(String text) {
  final trimmed = text.trim();
  if (!_numberPattern.hasMatch(trimmed)) return null;
  return num.parse(trimmed);
}

/// Formats a value the way `Escribir` shows it.
String formatValue(Object? value) {
  return switch (value) {
    bool b => b ? 'VERDADERO' : 'FALSO',
    int i => '$i',
    double d => _formatDouble(d),
    String s => s,
    ArrayValue a => '[arreglo ${a.name}]',
    _ => '',
  };
}

String _formatDouble(double value) {
  if (value == value.truncateToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }
  var text = value.toStringAsFixed(10);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  return text.endsWith('.') ? text.substring(0, text.length - 1) : text;
}

/// Describes a value inside an error message, e.g. `el texto "hola"`.
String describeValue(Object? value) {
  return switch (value) {
    null => 'un valor vacío',
    bool b => 'el valor lógico ${formatValue(b)}',
    num n => 'el número ${formatValue(n)}',
    String s => 'el texto "$s"',
    ArrayValue a => "el arreglo '${a.name}'",
    _ => 'un valor desconocido',
  };
}

/// A value as the variables table of the step-by-step mode shows it:
/// texts in quotes and arrays with their contents.
String debugValue(Object? value, {int maxItems = 30}) {
  return switch (value) {
    null => '(sin valor)',
    String s => '"$s"',
    ArrayValue a => _debugArray(a, maxItems),
    _ => formatValue(value),
  };
}

String _debugArray(ArrayValue array, int maxItems) {
  String item(Object? v) => v == null ? '·' : debugValue(v);
  if (array.dims.length == 1) {
    final shown = array.data.take(maxItems).map(item).join(', ');
    return '[$shown${array.data.length > maxItems ? ', …' : ''}]';
  }
  // Rows of a matrix; deeper arrays show their size only.
  if (array.dims.length == 2) {
    final columns = array.dims[1];
    final rows = <String>[];
    for (var r = 0; r < array.dims[0] && rows.length * columns < maxItems; r++) {
      rows.add('[${array.data.skip(r * columns).take(columns).map(item).join(', ')}]');
    }
    return '[${rows.join(', ')}${rows.length < array.dims[0] ? ', …' : ''}]';
  }
  return '[arreglo de ${array.dims.join(' × ')}]';
}
