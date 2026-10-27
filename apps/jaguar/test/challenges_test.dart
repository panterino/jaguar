import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar_core/jaguar_core.dart';

/// A correct solution for each challenge, to know the tests are right.
const _solutions = {
  'reto-1-01': 'Algoritmo a\n Escribir "¿Cómo te llamas?"\n Leer nombre\n Escribir "Hola, ", nombre\nFinAlgoritmo',
  'reto-1-02': 'Algoritmo a\n Leer base, altura\n Escribir "Área: ", base * altura\nFinAlgoritmo',
  'reto-1-03': 'Algoritmo a\n iva <- 0.16\n Leer precio\n Escribir "Total: ", precio + precio * iva\nFinAlgoritmo',
  'reto-1-04': 'Algoritmo a\n Leer m\n Escribir trunc(m / 60), " horas y ", m MOD 60, " minutos"\nFinAlgoritmo',
  'reto-1-05':
      'Algoritmo a\n Leer c\n Si c >= 6 Entonces\n  Escribir "Aprobado"\n SiNo\n  Escribir "Reprobado"\n FinSi\nFinAlgoritmo',
  'reto-1-06':
      'Algoritmo a\n Leer n\n Si n >= 1 Y n <= 10 Entonces\n  Escribir "Dentro"\n SiNo\n  Escribir "Fuera"\n FinSi\nFinAlgoritmo',
  'reto-1-07':
      'Algoritmo a\n Leer d\n Segun d Hacer\n  1: Escribir "Lunes"\n  2: Escribir "Martes"\n  3: Escribir "Miércoles"\n'
      '  4: Escribir "Jueves"\n  5: Escribir "Viernes"\n  6: Escribir "Sábado"\n  7: Escribir "Domingo"\n'
      '  De Otro Modo: Escribir "No existe"\n FinSegun\nFinAlgoritmo',
  'reto-1-08':
      'Algoritmo a\n suma <- 0\n Leer n\n Mientras n <> 0 Hacer\n  suma <- suma + n\n  Leer n\n FinMientras\n'
      ' Escribir "Suma: ", suma\nFinAlgoritmo',
  'reto-1-09':
      'Algoritmo a\n Leer n\n Para i <- 1 Hasta 10 Hacer\n  Escribir n, " x ", i, " = ", n * i\n FinPara\nFinAlgoritmo',
  'reto-1-10':
      'Algoritmo a\n intentos <- 0\n Repetir\n  Leer clave\n  intentos <- intentos + 1\n Hasta Que clave = "jaguar"\n'
      ' Escribir "Entraste en ", intentos, " intentos"\nFinAlgoritmo',
  'reto-1-11': 'Algoritmo a\n Leer texto\n Escribir Mayusculas(texto) + "!"\nFinAlgoritmo',
  'reto-1-12': 'Algoritmo a\n Leer palabra\n Escribir "Letras: ", Longitud(palabra)\nFinAlgoritmo',
};

void main() {
  test('hay doce retos, cada uno con pistas y pruebas ocultas', () {
    expect(challenges, hasLength(12));
    expect({for (final c in challenges) c.id}, hasLength(12));
    for (final c in challenges) {
      expect(c.hints, isNotEmpty, reason: c.id);
      expect(c.exercise.cases.any((t) => t.hidden), isTrue, reason: c.id);
    }
  });

  for (final challenge in challenges) {
    test('${challenge.exercise.title}: la solución pasa y un programa vacío no', () async {
      final good = await checkSolution(_solutions[challenge.id]!, challenge.exercise);
      expect(good.passed, isTrue, reason: good.cases.map((c) => c.failure?.toString()).join('\n'));
      final empty = await checkSolution('Algoritmo a\nFinAlgoritmo', challenge.exercise);
      expect(empty.passed, isFalse);
    });
  }
}
