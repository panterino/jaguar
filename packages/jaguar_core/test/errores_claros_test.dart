import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

/// Los errores que más ve quien empieza: todos dicen qué pasó, dónde y qué
/// hacer. Una prueba por error para que ninguno vuelva a quedar sin pista.
Future<JaguarError> _error(String body, {List<String> inputs = const []}) async {
  final source = 'Algoritmo prueba\n$body\nFinAlgoritmo\n';
  final result = await runProgram(source, inputs: inputs, options: RunOptions(maxSteps: 500));
  expect(result.error, isNotNull, reason: body);
  return result.error!;
}

void main() {
  test('falta cerrar un bloque: dice cuál y cómo cerrarlo', () async {
    final result = await runProgram('Algoritmo a\nSi 1 > 0 Entonces\nEscribir 1\nFinAlgoritmo\n');
    final error = result.error!;
    expect(error.message, contains("antes falta 'FinSi'"));
    expect(error.hint, contains("Cierra primero el 'Si'"));
    // Mientras se escribe no se muestra como error.
    expect(error.unfinished, isTrue);
  });

  test('un cierre fuera de lugar nombra el que falta', () async {
    final result = await runProgram('Algoritmo a\nMientras 1 > 0 Hacer\nSi 1 > 0 Entonces\nFinMientras\nFinAlgoritmo\n');
    final error = result.error!;
    expect(error.message, contains("pero antes falta 'FinSi'"));
    expect(error.hint, contains("Cierra primero el 'Si'"));
  });

  test('variable sin valor: dice dónde darle uno', () async {
    final error = await _error('Escribir x');
    expect(error.message, contains("No encuentro la variable 'x'"));
    expect(error.hint, contains('Leer x'));
    final sinValor = await _error('Definir total Como Entero\nEscribir total');
    expect(sinValor.message, contains('todavía no tiene valor en este punto'));
    expect(sinValor.hint, contains('más arriba'));
  });

  test('texto sin comillas y comilla sin cerrar', () async {
    final sinComillas = await _error('Escribir Hola mundo');
    expect(sinComillas.message, 'Falta poner el texto entre comillas.');
    expect(sinComillas.hint, contains('Escribir "Hola mundo"'));
    final sinCerrar = await _error('Escribir "Hola');
    expect(sinCerrar.message, 'Falta la comilla que cierra este texto.');
  });

  test('división entre cero lleva una pista', () async {
    final error = await _error('d <- 0\nEscribir 5 / d');
    expect(error.message, 'No se puede dividir entre cero.');
    expect(error.hint, contains('Si divisor <> 0'));
    final mod = await _error('d <- 0\nEscribir 5 MOD d');
    expect(mod.hint, contains('MOD'));
  });

  test('ciclo infinito: dice qué debe cambiar', () async {
    final error = await _error('n <- 1\nMientras n > 0 Hacer\nEscribir Sin Saltar ""\nFinMientras');
    expect(error.message, contains('demasiados pasos'));
    expect(error.hint, contains('n <- n - 1'));
  });

  test('palabra reservada como nombre de variable', () async {
    final y = await _error('y <- 3');
    expect(y.message, contains('palabra reservada (el lenguaje ya la usa)'));
    expect(y.hint, contains("'Y' es el operador lógico"));
  });

  test('los títulos no usan jerga', () async {
    final sintaxis = await _error('Escribir "a" "b"');
    expect(sintaxis.title, 'Error de escritura');
    final ejecucion = await _error('Escribir x');
    expect(ejecucion.title, 'Error al ejecutar');
  });
}
