import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

String py(String body) => toPython(parse('Algoritmo prueba\n$body\nFinAlgoritmo\n'));

void main() {
  test('Escribir y Leer', () {
    expect(py('Definir n Como Entero\nLeer n\nEscribir "n vale ", n'), contains('n = int(input())'));
    expect(py('Escribir "Hola"'), contains('print("Hola")'));
    expect(py('Escribir "a", 1'), contains('print("a", 1, sep="")'));
    expect(py('Escribir Sin Saltar "a"'), contains('print("a", end="")'));
  });

  test('un texto sin Definir se lee como texto y un número como número', () {
    expect(py('Leer nombre\nEscribir "Hola " + nombre'), contains('nombre = input()'));
    expect(py('Leer edad\nSi edad >= 18 Entonces\nEscribir 1\nFinSi'), contains('edad = float(input())'));
    expect(py('Leer x\nEscribir x / 2'), contains('x = float(input())'));
    // Lo que cuenta, indexa o saca residuo es entero.
    expect(py('Leer n\nPara i <- 1 Hasta n Hacer\nEscribir i\nFinPara'), contains('n = int(input())'));
    expect(py('Leer a, b\nEscribir a + b'), contains('a = float(input())'));
  });

  test('unir un texto con un número usa str()', () {
    expect(py('n <- 5\nEscribir "Total: " + n'), contains('print("Total: " + str(n))'));
  });

  test('las decisiones usan elif y las condiciones, and, or y not', () {
    final code = py(
      'Leer n\nSi n < 0 Y NO n = 5 Entonces\nEscribir 1\nSiNo\nSi n = 0 Entonces\nEscribir 2\nSiNo\nEscribir 3\nFinSi\nFinSi',
    );
    expect(code, contains('if n < 0 and not n == 5:'));
    expect(code, contains('elif n == 0:'));
    expect(code, contains('else:'));
  });

  test('los ciclos', () {
    expect(py('Para i <- 1 Hasta 10 Hacer\nEscribir i\nFinPara'), contains('for i in range(1, 11):'));
    expect(py('Para i <- 10 Hasta 1 Hacer\nEscribir i\nFinPara'), contains('for i in range(10, 0, -1):'));
    expect(py('Para i <- 1 Hasta 10 Con Paso 2 Hacer\nEscribir i\nFinPara'), contains('for i in range(1, 11, 2):'));
    expect(py('n <- 3\nMientras n > 0 Hacer\nn <- n - 1\nFinMientras'), contains('while n > 0:'));
    final repeat = py('n <- 3\nRepetir\nn <- n - 1\nHasta Que n = 0');
    expect(repeat, contains('while True:'));
    expect(repeat, contains('if n == 0:\n        break'));
    expect(py('n <- 3\nRepetir\nn <- n - 1\nMientras Que n > 0'), contains('if not (n > 0):'));
  });

  test('los arreglos cuentan desde 0 en Python', () {
    final code = py('Dimension a[3]\na[1] <- 7\nEscribir a[3]');
    expect(code, contains('a = [0] * 3'));
    expect(code, contains('a[0] = 7'));
    expect(code, contains('print(a[2])'));
  });

  test('Segun y las funciones internas', () {
    final code = py('Leer d\nSegun d Hacer\n1, 2: Escribir "a"\nDe Otro Modo: Escribir "b"\nFinSegun');
    expect(code, contains('if d in (1, 2):'));
    expect(code, contains('else:'));
    expect(py('Escribir Raiz(9), Longitud("ab"), Mayusculas("a")'), contains('math.sqrt(9), len("ab"), "a".upper()'));
    expect(py('Escribir Raiz(9)'), startsWith('import math'));
  });

  test('las funciones se vuelven def con return', () {
    final code = toPython(
      parse('Funcion r <- Doble(x)\n r <- x * 2\nFinFuncion\nAlgoritmo a\n Escribir Doble(4)\nFinAlgoritmo\n'),
    );
    expect(code, contains('def Doble(x):'));
    expect(code, contains('    r = x * 2'));
    expect(code, contains('    return r'));
    expect(code, contains('print(Doble(4))'));
  });

  test('un cuerpo vacío lleva pass y los nombres de Python se protegen', () {
    expect(py('Si 1 = 1 Entonces\nFinSi'), contains('    pass'));
    expect(py('print <- 3\nEscribir print'), contains('print_ = 3'));
  });

  test('lo que se compara con < o > para hallar el mayor se lee como número', () {
    final code = py('Leer a, b\nmayor <- a\nSi b > mayor Entonces\nmayor <- b\nFinSi\nEscribir mayor');
    expect(code, contains('a = float(input())'));
    expect(code, contains('b = float(input())'));
    // Un texto declarado como tal sigue siendo texto.
    expect(py('Definir p Como Texto\nLeer p\nSi p > "m" Entonces\nEscribir p\nFinSi'), contains('p = input()'));
  });
}
