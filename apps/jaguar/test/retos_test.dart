// Cada reto tiene una solución de referencia que debe pasar todas sus pruebas:
// así se comprueba que las pruebas y las fórmulas de los retos son correctas.
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar_core/jaguar_core.dart';

const solutions = {
  'reto-1-01': 'Algoritmo s\n Definir nombre Como Texto\n Leer nombre\n Escribir "Hola, ", nombre\nFinAlgoritmo',
  'reto-1-02': 'Algoritmo s\n Leer base, altura\n area <- base * altura\n Escribir "Área: ", area\nFinAlgoritmo',
  'reto-1-03':
      'Algoritmo s\n Leer precio\n iva <- 0.16\n total <- precio + precio * iva\n Escribir "Total: ", total\nFinAlgoritmo',
  'reto-1-04':
      'Algoritmo s\n Leer minutos\n horas <- trunc(minutos / 60)\n resto <- minutos MOD 60\n Escribir horas, " horas y ", resto, " minutos"\nFinAlgoritmo',
  'reto-1-05':
      'Algoritmo s\n Leer c\n Si c >= 6 Entonces\n  Escribir "Aprobado"\n SiNo\n  Escribir "Reprobado"\n FinSi\nFinAlgoritmo',
  'reto-1-06':
      'Algoritmo s\n Leer n\n Si n >= 1 Y n <= 10 Entonces\n  Escribir "Dentro"\n SiNo\n  Escribir "Fuera"\n FinSi\nFinAlgoritmo',
  'reto-1-07':
      'Algoritmo s\n Leer d\n Segun d Hacer\n  1: Escribir "Lunes"\n  2: Escribir "Martes"\n  3: Escribir "Miércoles"\n  4: Escribir "Jueves"\n  5: Escribir "Viernes"\n  6: Escribir "Sábado"\n  7: Escribir "Domingo"\n  De Otro Modo: Escribir "No existe"\n FinSegun\nFinAlgoritmo',
  'reto-1-08':
      'Algoritmo s\n suma <- 0\n Leer n\n Mientras n <> 0 Hacer\n  suma <- suma + n\n  Leer n\n FinMientras\n Escribir "Suma: ", suma\nFinAlgoritmo',
  'reto-1-09':
      'Algoritmo s\n Leer n\n Para i <- 1 Hasta 10 Hacer\n  Escribir n, " x ", i, " = ", n * i\n FinPara\nFinAlgoritmo',
  'reto-1-10':
      'Algoritmo s\n Definir clave Como Texto\n intentos <- 0\n Repetir\n  Leer clave\n  intentos <- intentos + 1\n Hasta Que clave = "jaguar"\n Escribir "Entraste en ", intentos, " intentos"\nFinAlgoritmo',
  'reto-1-11': 'Algoritmo s\n Definir texto Como Texto\n Leer texto\n Escribir Mayusculas(texto) + "!"\nFinAlgoritmo',
  'reto-1-12':
      'Algoritmo s\n Definir palabra Como Texto\n Leer palabra\n Escribir "Letras: ", Longitud(palabra)\nFinAlgoritmo',
  'reto-0-01': 'Algoritmo s\n Leer palabra\n Escribir palabra\n Escribir palabra\nFinAlgoritmo',
  'reto-0-02': 'Algoritmo s\n Leer a, b\n Escribir a + b\nFinAlgoritmo',
  'reto-0-03':
      'Algoritmo s\n Leer edad\n Si edad >= 18 Entonces\n  Escribir "Mayor"\n SiNo\n  Escribir "Menor"\n FinSi\nFinAlgoritmo',
};

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
