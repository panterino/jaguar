import 'dart:io';
import 'dart:math';

import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

/// Los ejemplos de las guías de la página (sitio/guias) se ejecutan de verdad:
/// una guía con un ejemplo que falla confundiría a quien la sigue.
String _desescapa(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#10;', '\n')
    .replaceAll('&amp;', '&');

void main() {
  final carpetas = [Directory('../../sitio/guias'), Directory('../../sitio/retos')];
  final carpeta = carpetas.first;
  final ejemplo = RegExp(r'<pre class="codigo" ([^>]*)><code>(.*?)</code></pre>', dotAll: true);
  final atributo = RegExp(r'data-(entradas|salida)="([^"]*)"');

  test('las guías existen', () {
    expect(carpeta.existsSync(), isTrue);
    expect(carpeta.listSync().whereType<File>().length, greaterThanOrEqualTo(5));
  });

  test('las páginas de retos existen: una por reto más el índice', () {
    expect(carpetas.last.existsSync(), isTrue);
    expect(carpetas.last.listSync().whereType<File>().length, greaterThanOrEqualTo(13));
  });

  final archivos = [
    for (final c in carpetas)
      if (c.existsSync()) ...c.listSync().whereType<File>().where((f) => f.path.endsWith('.html')),
  ];
  for (final archivo in archivos) {
    final nombre = archivo.uri.pathSegments.last;
    final html = archivo.readAsStringSync();
    for (final (i, m) in ejemplo.allMatches(html).indexed) {
      final atributos = {for (final a in atributo.allMatches(m.group(1)!)) a.group(1)!: _desescapa(a.group(2)!)};
      // Sin data-salida es un ejemplo de otro lenguaje o un fragmento.
      if (!atributos.containsKey('salida')) continue;
      test('$nombre, ejemplo ${i + 1}', () async {
        final fuente = _desescapa(m.group(2)!);
        final entradas = (atributos['entradas'] ?? '').isEmpty ? <String>[] : atributos['entradas']!.split('|');
        final resultado = await runProgram(
          fuente,
          inputs: entradas,
          options: RunOptions(maxSteps: 100000, random: Random(1)),
        );
        if (resultado.error != null) fail(resultado.error!.format(fuente));
        expect(resultado.output.trimRight(), atributos['salida']);
      });
    }
  }
}
