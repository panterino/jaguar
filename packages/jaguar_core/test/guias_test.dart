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

  test('la analítica es la misma en la landing y en la app, y cada página la carga', () {
    final landing = File('../../sitio/analitica.js').readAsStringSync();
    expect(
      File('../../apps/jaguar/web/analitica.js').readAsStringSync(),
      landing,
      reason: 'Copia sitio/analitica.js a apps/jaguar/web/',
    );
    expect(landing, contains('G-1T1QH5RR0E'));
    // Nada de Google se pide antes de aceptar: el script solo se agrega en cargar().
    expect(landing, isNot(contains("<script src=\"https://www.googletagmanager")));
    final paginas = Directory(
      '../../sitio',
    ).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.html')).toList();
    expect(paginas, isNotEmpty);
    for (final f in paginas) {
      expect(f.readAsStringSync(), contains('analitica.js'), reason: f.path);
    }
    expect(File('../../apps/jaguar/web/index.html').readAsStringSync(), contains('analitica.js'));
    expect(File('../../apps/jaguar/web/privacidad.html').readAsStringSync(), contains('analitica.js'));
  });

  test('el generador de diagramas tiene su página y su núcleo compilado', () {
    final html = File('../../sitio/herramientas/diagrama-de-flujo-online.html').readAsStringSync();
    expect(html, contains('id="bajar-svg"'));
    expect(html, contains('<svg'));
    expect(File('../../sitio/herramientas/diagrama-nucleo.js').readAsStringSync(), contains('jaguarDiagrama'));
  });

  test('la herramienta de prueba de escritorio tiene su página y su núcleo compilado', () {
    final pagina = File('../../sitio/herramientas/prueba-de-escritorio.html');
    expect(pagina.existsSync(), isTrue);
    final html = pagina.readAsStringSync();
    expect(html, contains('id="generar"'));
    expect(html, contains('/herramientas/herramienta.js'));
    // La tabla de ejemplo ya viene hecha: sirve sin JavaScript.
    expect(html, contains('<td class="instr">Leer a, b</td>'));
    final nucleo = File('../../sitio/herramientas/prueba-nucleo.js');
    expect(nucleo.existsSync(), isTrue);
    expect(nucleo.readAsStringSync(), contains('jaguarPruebaDeEscritorio'));
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
