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
  // Olvida que los años de siglo no son bisiestos (1900).
  'reto-2-01':
      'Algoritmo s\n Leer a\n Si a MOD 4 = 0 Entonces\n  Escribir "Bisiesto"\n SiNo\n  Escribir "No bisiesto"\n FinSi\nFinAlgoritmo',
  // Empieza el mayor en 0: los negativos nunca lo superan.
  'reto-2-07':
      'Algoritmo s\n mayor <- 0\n Leer n\n Mientras n <> 0 Hacer\n  Si n > mayor Entonces\n   mayor <- n\n  FinSi\n  Leer n\n FinMientras\n Escribir "Mayor: ", mayor\nFinAlgoritmo',
  // Un Para de 1 hasta 0 cuenta hacia atrás: el factorial de 0 sale 0.
  'reto-2-09':
      'Algoritmo s\n Leer n\n f <- 1\n Para i <- 1 Hasta n Hacer\n  f <- f * i\n FinPara\n Escribir "Factorial: ", f\nFinAlgoritmo',
  // Divide sin revisar que haya datos.
  'reto-2-06':
      'Algoritmo s\n suma <- 0\n cuenta <- 0\n Leer c\n Mientras c <> -1 Hacer\n  suma <- suma + c\n  cuenta <- cuenta + 1\n  Leer c\n FinMientras\n Escribir "Promedio: ", suma / cuenta\nFinAlgoritmo',
};

void main() {
  for (final entry in wrong.entries) {
    test('${entry.key}: una solución con el borde mal no pasa', () async {
      final c = challengeById(entry.key)!;
      expect((await checkSolution(entry.value, c.exercise)).passed, isFalse);
    });
  }
  for (final c in everyChallenge) {
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
