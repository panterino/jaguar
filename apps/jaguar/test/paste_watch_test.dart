import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/editor/paste_watch.dart';

TextEditingValue _v(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void main() {
  const start = 'Algoritmo a\n    \nFinAlgoritmo\n';
  const pasted = 'Leer n\nSi n > 0 Entonces\n    Escribir "positivo"\nSiNo\n    Escribir "no"\nFinSi\n';

  test('pegar varias líneas de golpe avisa cuántas', () {
    final seen = <int>[];
    final watch = PasteWatch(seen.add);
    watch.formatEditUpdate(_v(start), _v(start.replaceFirst('    \n', '    $pasted')));
    expect(seen, [6]);
  });

  test('escribir línea por línea no avisa', () {
    final seen = <int>[];
    final watch = PasteWatch(seen.add);
    var text = start;
    for (final line in pasted.split('\n')) {
      final next = text.replaceFirst('FinAlgoritmo', '$line\nFinAlgoritmo');
      watch.formatEditUpdate(_v(text), _v(next));
      text = next;
    }
    expect(seen, isEmpty);
  });

  test('cortar y pegar dentro del mismo programa no cuenta', () {
    final seen = <int>[];
    final watch = PasteWatch(seen.add);
    final full = start.replaceFirst('    \n', '    $pasted');
    watch.formatEditUpdate(_v(full), _v(start)); // cortar
    watch.formatEditUpdate(_v(start), _v(full)); // pegar de nuevo
    expect(seen, isEmpty);
  });
}
