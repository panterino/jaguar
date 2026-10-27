// Python traducido debe hacer lo mismo que el pseudocódigo: cada solución de
// los retos y cada ejemplo de las lecciones se corre con python3 (el del equipo
// de desarrollo, solo en pruebas) y su salida se compara con la esperada.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/lessons/lessons.dart';
import 'package:jaguar_core/jaguar_core.dart';

import 'retos_test.dart' as retos;

bool get _hayPython => Process.runSync('python3', ['--version']).exitCode == 0;

/// Lo que imprime [code] en Python con estas [inputs].
Future<String> _corre(String code, List<String> inputs) async {
  final process = await Process.start('python3', ['-I', '-c', code]);
  process.stdin.writeln(inputs.join('\n'));
  await process.stdin.close();
  final out = await process.stdout.transform(utf8.decoder).join();
  final err = await process.stderr.transform(utf8.decoder).join();
  final exit = await process.exitCode;
  if (exit != 0) fail('Python falló:\n$err\n--- código ---\n$code');
  return _normal(out);
}

/// 116.0 y 116 son lo mismo para quien lee la salida; los espacios al final no cuentan.
String _normal(String text) =>
    text.split('\n').map((l) => l.trimRight().replaceAllMapped(RegExp(r'(\d)\.0\b'), (m) => m[1]!)).join('\n').trim();

void main() {
  final python = _hayPython;
  if (!python) {
    test('python3 no está disponible: no se compara la salida', () {}, skip: 'no hay python3');
    return;
  }

  group('las soluciones de los retos hacen lo mismo en Python', () {
    for (final c in everyChallenge) {
      test(c.id, () async {
        final code = toPython(parse(retos.solutions[c.id]!));
        for (final testCase in c.exercise.cases) {
          expect(
            await _corre(code, testCase.inputs),
            _normal(testCase.expected),
            reason: '${c.id} con ${testCase.inputs}\n$code',
          );
        }
      });
    }
  });

  group('los ejemplos de las lecciones hacen lo mismo en Python', () {
    for (final lesson in allLessons) {
      for (final (i, q) in lesson.questions.indexed) {
        if (q is ChoiceQuestion && q.code != null && q.output != null) {
          test('${lesson.id}, pregunta ${i + 1}', () async {
            final source = q.code!.contains('Algoritmo') ? q.code! : 'Algoritmo prueba\n${q.code}\nFinAlgoritmo\n';
            expect(await _corre(toPython(parse(source)), q.inputs), _normal(q.output!), reason: source);
          });
        }
      }
    }
  });
}
