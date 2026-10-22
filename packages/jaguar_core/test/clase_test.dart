import 'dart:math';

import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

/// Programs written the way they are usually taught and shared in class:
/// semicolons after statements, `Definir`, `SubProceso`, several `Leer`
/// variables, `Segun` with many values. Each one must run as is.
Future<String> run(String source, {List<String> inputs = const []}) async {
  final result = await runProgram(source, inputs: inputs, options: RunOptions(maxSteps: 200000, random: Random(1)));
  if (result.error != null) fail(result.error!.format(source));
  return result.output;
}

void main() {
  test('punto y coma, Definir y Leer de varias variables', () async {
    const source = '''
Algoritmo suma;
    Definir a, b, total Como Real;
    Escribir "Dos numeros:";
    Leer a, b;
    total <- a + b;
    Escribir "Suma: ", total;
FinAlgoritmo
''';
    expect(await run(source, inputs: ['2', '3']), 'Dos numeros:\nSuma: 5\n');
  });

  test('Segun con varios valores por caso', () async {
    const source = '''
Algoritmo dias
    Leer d
    Segun d Hacer
        1, 7:
            Escribir "Fin de semana"
        2, 3, 4, 5, 6:
            Escribir "Entre semana"
        De Otro Modo:
            Escribir "No existe"
    FinSegun
FinAlgoritmo
''';
    expect(await run(source, inputs: ['7']), 'Fin de semana\n');
    expect(await run(source, inputs: ['3']), 'Entre semana\n');
    expect(await run(source, inputs: ['9']), 'No existe\n');
  });

  test('diferente con != y <>', () async {
    const source = '''
Algoritmo distinto
    Si 3 != 4 Entonces
        Escribir "a"
    FinSi
    Si 3 <> 3 Entonces
        Escribir "b"
    SiNo
        Escribir "c"
    FinSi
FinAlgoritmo
''';
    expect(await run(source), 'a\nc\n');
  });

  test('SubProceso con retorno y llamada desde el principal', () async {
    const source = '''
SubProceso r <- doble(n)
    Definir r Como Entero;
    r <- n * 2;
FinSubProceso

Algoritmo principal
    Escribir doble(21);
FinAlgoritmo
''';
    expect(await run(source), '42\n');
  });

  test('Funcion con retorno', () async {
    const source = '''
Funcion r <- cuadrado(n)
    r <- n * n
FinFuncion

Algoritmo principal
    Escribir cuadrado(5)
FinAlgoritmo
''';
    expect(await run(source), '25\n');
  });

  test('arreglo y matriz con Para', () async {
    const source = '''
Algoritmo matriz
    Dimension m[2, 3]
    Para i <- 1 Hasta 2 Con Paso 1 Hacer
        Para j <- 1 Hasta 3 Hacer
            m[i, j] <- i * j
        FinPara
    FinPara
    Escribir m[2, 3]
FinAlgoritmo
''';
    expect(await run(source), '6\n');
  });

  test('cadenas: Subcadena, Concatenar, Longitud, Mayusculas', () async {
    const source = '''
Algoritmo texto
    palabra <- "programa"
    Escribir Subcadena(palabra, 1, 3)
    Escribir Concatenar("a", "b")
    Escribir Longitud(palabra)
    Escribir Mayusculas(palabra)
FinAlgoritmo
''';
    expect(await run(source), 'pro\nab\n8\nPROGRAMA\n');
  });

  test('Escribir Sin Saltar y Repetir Hasta Que', () async {
    const source = '''
Algoritmo repite
    i <- 1
    Repetir
        Escribir Sin Saltar i, " "
        i <- i + 1
    Hasta Que i > 3
    Escribir ""
FinAlgoritmo
''';
    expect(await run(source), '1 2 3 \n');
  });

  test('pi, potencia, MOD y operadores logicos', () async {
    const source = '''
Algoritmo mate
    Escribir 2 ^ 3
    Escribir 7 MOD 3
    Si 3 > 2 Y NO (1 > 2) Entonces
        Escribir "ok"
    FinSi
    Escribir Redon(PI)
FinAlgoritmo
''';
    expect(await run(source), '8\n1\nok\n3\n');
  });

  test('Limpiar Pantalla y Esperar no rompen el programa', () async {
    const source = '''
Algoritmo pantalla
    Escribir "a"
    Esperar 1 Segundos
    Limpiar Pantalla
    Escribir "b"
FinAlgoritmo
''';
    final out = await run(source);
    expect(out.endsWith('b\n'), isTrue);
  });
}
