// Cada reto tiene una solución de referencia que debe pasar todas sus pruebas:
// así se comprueba que las pruebas y las fórmulas de los retos son correctas.
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/challenges/soluciones.dart';
import 'package:jaguar_core/jaguar_core.dart';

const solutions = soluciones;

/// Soluciones casi correctas que las pruebas deben rechazar (los bordes).
const wrong = {
  'reto-1-05':
      'Algoritmo s\n Leer c\n Si c > 6 Entonces\n  Escribir "Aprobado"\n SiNo\n  Escribir "Reprobado"\n FinSi\nFinAlgoritmo',
  'reto-1-06':
      'Algoritmo s\n Leer n\n Si n > 1 Y n <= 10 Entonces\n  Escribir "Dentro"\n SiNo\n  Escribir "Fuera"\n FinSi\nFinAlgoritmo',
  // El 18 también es mayor de edad.
  'reto-0-03':
      'Algoritmo s\n Leer edad\n Si edad > 18 Entonces\n  Escribir "Mayor"\n SiNo\n  Escribir "Menor"\n FinSi\nFinAlgoritmo',
  // Cuenta una letra de más (la longitud más uno).
  'reto-1-12':
      'Algoritmo s\n Definir palabra Como Texto\n Leer palabra\n Escribir "Letras: ", Longitud(palabra) + 1\nFinAlgoritmo',
};

void main() {
  for (final entry in wrong.entries) {
    test('${entry.key}: una solución con el borde mal no pasa', () async {
      final c = challengeById(entry.key)!;
      expect((await checkSolution(entry.value, c.exercise)).passed, isFalse);
    });
  }
  for (final c in [...challenges, ...blockChallenges]) {
    test(c.id, () async {
      final r = await checkSolution(solutions[c.id]!, c.exercise);
      for (final cs in r.cases) {
        expect(
          cs.passed,
          isTrue,
          reason: '${c.id} ${cs.testCase.inputs} esperado "${cs.testCase.expected}" salio "${cs.output}" ${cs.error}',
        );
      }
      expect(r.syntaxError, isNull);
    });
  }
}
