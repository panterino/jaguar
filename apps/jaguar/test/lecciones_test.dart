import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/lessons/lessons.dart';
import 'package:jaguar_core/jaguar_core.dart';

/// Una lección que enseña un resultado equivocado es peor que no tener
/// lección: aquí cada ejemplo se ejecuta con el intérprete de Jaguar.
Future<String> _run(String source, List<String> inputs) async {
  final program = source.contains('Algoritmo') ? source : 'Algoritmo prueba\n$source\nFinAlgoritmo\n';
  final result = await runProgram(
    program,
    inputs: inputs,
    options: RunOptions(maxSteps: 100000, random: Random(1)),
  );
  if (result.error != null) fail(result.error!.format(program));
  return result.output.trimRight();
}

void main() {
  test('las lecciones tienen forma: 5 preguntas, opciones distintas y una respuesta válida', () {
    expect(allLessons.map((l) => l.id).toSet(), hasLength(allLessons.length));
    for (final lesson in allLessons) {
      expect(lesson.questions.length, greaterThanOrEqualTo(5), reason: lesson.id);
      for (final q in lesson.questions) {
        expect(q.prompt, isNotEmpty);
        expect(q.right, isNotEmpty);
        expect(q.wrong, isNotEmpty, reason: q.prompt);
        switch (q) {
          case ChoiceQuestion():
            expect(q.options.toSet(), hasLength(q.options.length), reason: q.prompt);
            expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: q.prompt);
          case OrderQuestion():
            expect(
              q.lines.map((l) => l.trim()).toSet(),
              hasLength(q.lines.length),
              reason: 'líneas repetidas: ${q.prompt}',
            );
            expect(q.lines.length, greaterThanOrEqualTo(3));
          case FigureQuestion():
            break;
          case FindErrorQuestion():
            expect(q.lines.length, greaterThanOrEqualTo(3));
            expect(q.errorLine, inInclusiveRange(0, q.lines.length - 1));
            expect(q.fixed, isNot(q.lines[q.errorLine]));
        }
      }
    }
  });

  group('los resultados de los ejemplos son los que ejecuta Jaguar', () {
    for (final lesson in allLessons) {
      for (final (i, q) in lesson.questions.indexed) {
        if (q is ChoiceQuestion && q.code != null && q.output != null) {
          test('${lesson.id}, pregunta ${i + 1}', () async {
            final salida = await _run(q.code!, q.inputs);
            expect(salida, q.output);
            // La opción correcta es lo que sale: en una línea, o "Nada".
            final esperada = salida.isEmpty ? 'Nada' : salida.split('\n').join(', ');
            expect(q.options[q.answer], esperada);
          });
        }
        if (q is ChoiceQuestion && q.fillOutput != null) {
          test('${lesson.id}, pregunta ${i + 1}: solo una opción completa bien el código', () async {
            for (final (k, option) in q.options.indexed) {
              final source = q.code!.replaceFirst(RegExp(r'_{3,}'), option);
              final program = 'Algoritmo prueba\n$source\nFinAlgoritmo\n';
              final result = await runProgram(program, inputs: q.inputs, options: RunOptions(maxSteps: 100000));
              final worked = result.error == null && result.output.trimRight() == q.fillOutput;
              expect(worked, k == q.answer, reason: 'opción "$option"');
            }
          });
        }
        if (q is FindErrorQuestion) {
          test('${lesson.id}, pregunta ${i + 1}: con la línea mala falla y con la corrección corre', () async {
            final broken = 'Algoritmo prueba\n${q.lines.skip(1).take(q.lines.length - 2).join('\n')}\nFinAlgoritmo\n';
            final fixedLines = [...q.lines]..[q.errorLine] = q.fixed;
            final fixed = fixedLines.join('\n');
            final bad = await runProgram(q.lines.join('\n'), inputs: q.inputs, options: RunOptions(maxSteps: 100000));
            expect(bad.error, isNotNull, reason: 'el programa con el error debe fallar');
            await _run(fixed, q.inputs);
            expect(broken, isNotEmpty);
          });
        }
        if (q is OrderQuestion) {
          test('${lesson.id}, pregunta ${i + 1}: el programa ordenado corre', () async {
            await _run(q.lines.join('\n'), q.inputs);
          });
        }
      }
    }
  });

  group('la ruta', () {
    test('cada lección y cada reto aparece una sola vez', () {
      final ids = routeSteps.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.where((id) => id.startsWith('reto-')).length, challenges.length + blockChallenges.length);
      expect(ids.where((id) => id.startsWith('leccion-')).length, allLessons.length);
    });

    test('los retos de la ruta son todos los retos, una sola vez', () {
      final retos = routeSteps.whereType<ChallengeStep>().map((s) => s.id).toList();
      expect(retos.toSet(), [...challenges, ...blockChallenges].map((c) => c.id).toSet());
      expect(retos, hasLength(challenges.length + blockChallenges.length));
    });

    test('el siguiente reto sigue el orden de la ruta, no el de la lista', () {
      // Los textos van después de Operaciones, antes de las decisiones.
      expect(nextChallenge('reto-1-04')!.id, 'reto-1-11');
      expect(nextChallenge('reto-1-12')!.id, 'reto-1-05');
      expect(nextChallenge('reto-1-10'), isNull);
    });

    test('el siguiente paso es el primero sin hacer, y es nulo al terminar', () {
      expect(nextStep(lessons: {}, challenges: {})!.id, lessonFirstProgram.id);
      expect(nextStep(lessons: {lessonFirstProgram.id}, challenges: {})!.id, 'reto-1-01');
      expect(nextStep(lessons: {lessonFirstProgram.id}, challenges: {'reto-1-01'})!.id, lessonOperations.id);
      expect(
        nextStep(
          lessons: allLessons.map((l) => l.id).toSet(),
          challenges: [...challenges, ...blockChallenges].map((c) => c.id).toSet(),
        ),
        isNull,
      );
    });

    test('saltarse un paso no lo da por hecho', () {
      // Hizo el reto 1 sin la lección: la lección sigue pendiente.
      expect(nextStep(lessons: {}, challenges: {'reto-1-01'})!.id, lessonFirstProgram.id);
    });
  });
}
