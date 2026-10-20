import 'dart:math';

import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

Future<String> run(String body, {List<String> inputs = const [], String before = ''}) async {
  final source = '$before\nAlgoritmo prueba\n$body\nFinAlgoritmo\n';
  final result = await runProgram(
    source,
    inputs: inputs,
    options: RunOptions(maxSteps: 100000, random: Random(1)),
  );
  if (result.error != null) fail(result.error!.format(source));
  return result.output;
}

Future<JaguarError> runError(String source, {List<String> inputs = const [], int maxSteps = 100000}) async {
  final result = await runProgram(
    source,
    inputs: inputs,
    options: RunOptions(maxSteps: maxSteps),
  );
  expect(result.error, isNotNull, reason: 'Se esperaba un error, pero el programa terminó bien:\n${result.output}');
  return result.error!;
}

String program(String body) => 'Algoritmo prueba\n$body\nFinAlgoritmo\n';

void main() {
  group('unir con +', () {
    test('texto y variable', () async {
      expect(await run('nombre <- "Ana"\nEscribir "Hola " + nombre'), 'Hola Ana\n');
    });
    test('texto y número', () async {
      expect(await run('x <- 5\nEscribir "Total: " + x'), 'Total: 5\n');
      expect(await run('Escribir 2.5 + " m"'), '2.5 m\n');
    });
    test('de izquierda a derecha', () async {
      expect(await run('Escribir "a" + 1 + 2'), 'a12\n');
      expect(await run('Escribir 1 + 2 + "a"'), '3a\n');
    });
  });

  group('Escribir', () {
    test('hola mundo', () async {
      expect(await run('Escribir "Hola mundo"'), 'Hola mundo\n');
    });

    test('concatena varios valores sin espacios', () async {
      expect(await run('Escribir "a", 1, "b", Verdadero'), 'a1bVERDADERO\n');
    });

    test('Sin Saltar antes o después de los valores', () async {
      expect(await run('Escribir Sin Saltar "a"\nEscribir "b" Sin Saltar\nEscribir "c"'), 'abc\n');
    });

    test('Imprimir y Mostrar son sinónimos', () async {
      expect(await run('Imprimir "a"\nMostrar "b"'), 'a\nb\n');
    });

    test('formato de números', () async {
      expect(
        await run('Escribir 7/2\nEscribir 6/2\nEscribir 1/3\nEscribir 0.1 + 0.2\nEscribir -5'),
        '3.5\n3\n0.3333333333\n0.3\n-5\n',
      );
    });

    test('acepta comillas tipográficas pegadas de Word', () async {
      expect(await run('Escribir “hola”'), 'hola\n');
    });
  });

  group('variables y tipos', () {
    test('asignación con <-, = y :=', () async {
      expect(await run('a <- 1\nb = 2\nc := 3\nEscribir a + b + c'), '6\n');
    });

    test('sin distinguir mayúsculas ni acentos', () async {
      final source =
          'ALGORITMO x\n contador <- 1\n ESCRIBIR Contador\n Según CONTADOR Hacer\n 1: escribir "uno"\n FinSegún\nfinalgoritmo';
      final result = await runProgram(source);
      expect(result.output, '1\nuno\n');
    });

    test('Definir convierte Real a Entero si no tiene decimales', () async {
      expect(await run('Definir n Como Entero\nn <- 6/2\nEscribir n'), '3\n');
    });

    test('Definir Entero rechaza decimales', () async {
      final error = await runError(program('Definir n Como Entero\nn <- 2.5'));
      expect(error.kind, ErrorKind.runtime);
      expect(error.message, contains('Entero'));
      expect(error.hint, contains('Trunc'));
    });

    test('texto sin comillas en Escribir', () async {
      final error = await runError(program('Escribir Dame tu nombre'));
      expect(error.message, contains('sin comillas'));
      expect(error.hint, contains('"Dame tu nombre"'));
      // Variables separadas por comas siguen funcionando.
      expect(await run('a <- 1\nb <- 2\nEscribir a, b'), '12\n');
    });

    test('Definir Texto rechaza números', () async {
      final error = await runError(program('Definir s Como Texto\ns <- 5'));
      expect(error.hint, contains('ConvertirATexto'));
    });

    test('variables separadas por punto y coma en una línea', () async {
      expect(await run('a <- 1; b <- 2; Escribir a + b;'), '3\n');
    });

    test('comentarios', () async {
      expect(await run('// comentario\na <- 1 // otro\nEscribir a'), '1\n');
    });
  });

  group('Leer', () {
    test('lee números y texto', () async {
      expect(await run('Leer a, b\nEscribir a + 1, b', inputs: ['41', 'hola']), '42hola\n');
    });

    test('convierte según el tipo definido', () async {
      expect(
        await run('Definir t Como Texto\nDefinir l Como Logico\nLeer t, l\nEscribir t, l', inputs: ['123', 'v']),
        '123VERDADERO\n',
      );
    });

    test('error si se pide un entero y se escribe texto', () async {
      final error = await runError(program('Definir n Como Entero\nLeer n'), inputs: ['abc']);
      expect(error.message, contains('entero'));
    });

    test('error si se acaban los datos de entrada', () async {
      final error = await runError(program('Leer a'));
      expect(error.message, contains('ya no hay datos'));
      expect(error.line, 2);
    });
  });

  group('condicionales', () {
    test('Si / SiNo', () async {
      const code = 'Leer n\nSi n MOD 2 = 0 Entonces\nEscribir "par"\nSiNo\nEscribir "impar"\nFinSi';
      expect(await run(code, inputs: ['4']), 'par\n');
      expect(await run(code, inputs: ['7']), 'impar\n');
    });

    test('Fin Si con espacio y Entonces opcional', () async {
      expect(await run('Si 1 < 2\nEscribir "ok"\nFin Si'), 'ok\n');
    });

    test('operadores lógicos en palabras y símbolos', () async {
      expect(
        await run('Escribir 1 < 2 Y 3 > 2\nEscribir 1 > 2 O NO Falso\nEscribir (1 > 2) | (2 > 1) & ~Falso'),
        'VERDADERO\nVERDADERO\nVERDADERO\n',
      );
    });

    test('Segun con varias opciones y De Otro Modo', () async {
      const code =
          'Leer d\nSegun d Hacer\n1: Escribir "uno"\n2, 3:\nEscribir "dos o tres"\nDe Otro Modo:\nEscribir "otro"\nFinSegun';
      expect(await run(code, inputs: ['1']), 'uno\n');
      expect(await run(code, inputs: ['3']), 'dos o tres\n');
      expect(await run(code, inputs: ['9']), 'otro\n');
    });

    test('Segun con texto', () async {
      expect(await run('Segun "b" Hacer\n"a": Escribir 1\n"b": Escribir 2\nFinSegun'), '2\n');
    });

    test('la condición debe ser lógica', () async {
      final error = await runError(program('Si 5 Entonces\nEscribir 1\nFinSi'));
      expect(error.message, contains('Verdadero o Falso'));
    });
  });

  group('ciclos', () {
    test('Para suma de 1 a 10', () async {
      expect(await run('s <- 0\nPara i <- 1 Hasta 10 Hacer\ns <- s + i\nFinPara\nEscribir s'), '55\n');
    });

    test('Para con paso', () async {
      expect(await run('Para i <- 0 Hasta 10 Con Paso 5 Hacer\nEscribir Sin Saltar i, " "\nFinPara'), '0 5 10 ');
    });

    test('Para cuenta hacia atrás sin paso explícito', () async {
      expect(await run('Para i <- 3 Hasta 1\nEscribir Sin Saltar i\nFinPara'), '321');
    });

    test('Mientras', () async {
      expect(await run('i <- 3\nMientras i > 0 Hacer\nEscribir Sin Saltar i\ni <- i - 1\nFinMientras'), '321');
    });

    test('Repetir Hasta Que y Mientras Que', () async {
      expect(await run('i <- 0\nRepetir\ni <- i + 1\nHasta Que i = 3\nEscribir i'), '3\n');
      expect(await run('i <- 0\nRepetir\ni <- i + 1\nMientras Que i < 5\nEscribir i'), '5\n');
    });

    test('Mientras anidado dentro de Repetir', () async {
      expect(
        await run(
          'i <- 0\nRepetir\nj <- 0\nMientras j < 2 Hacer\nj <- j + 1\nFinMientras\ni <- i + j\nHasta Que i >= 4\nEscribir i',
        ),
        '4\n',
      );
    });

    test('ciclo infinito se detiene con un mensaje claro', () async {
      final error = await runError(
        program('i <- 0\nMientras i < 10 Hacer\nEscribir Sin Saltar ""\nFinMientras'),
        maxSteps: 500,
      );
      expect(error.message, contains('500 pasos'));
      expect(error.hint, contains('ciclo'));
    });

    test('ciclo infinito vacío también se detiene', () async {
      final error = await runError(program('Mientras Verdadero Hacer\nFinMientras'), maxSteps: 500);
      expect(error.message, contains('pasos'));
    });
  });

  group('arreglos', () {
    test('base 1, lectura y escritura', () async {
      expect(
        await run('Dimension a[3]\nPara i <- 1 Hasta 3\na[i] <- i * 10\nFinPara\nEscribir a[1], ",", a[3]'),
        '10,30\n',
      );
    });

    test('dos dimensiones', () async {
      expect(await run('Dimension m[2, 3]\nm[2, 3] <- 7\nm[1, 1] <- 1\nEscribir m[2,3] + m[1,1]'), '8\n');
    });

    test('Para Cada modifica los elementos', () async {
      expect(
        await run(
          'Dimension a[3]\nPara i <- 1 Hasta 3\na[i] <- i\nFinPara\nPara Cada x de a\nx <- x * 2\nFinPara\nEscribir a[1], a[2], a[3]',
        ),
        '246\n',
      );
    });

    test('índice fuera de rango', () async {
      final error = await runError(program('Dimension a[10]\na[11] <- 1'));
      expect(error.message, contains('11'));
      expect(error.hint, contains('1 a 10'));
    });

    test('posición sin valor', () async {
      final error = await runError(program('Dimension a[2]\nEscribir a[1]'));
      expect(error.message, contains('no tiene valor'));
    });
  });

  group('funciones', () {
    test('función con valor de retorno definida después del algoritmo', () async {
      const source = 'Algoritmo p\nEscribir Doble(21)\nFinAlgoritmo\n\nFuncion r <- Doble(x)\nr <- x * 2\nFinFuncion\n';
      expect((await runProgram(source)).output, '42\n');
    });

    test('recursión', () async {
      expect(
        await run(
          'Escribir Factorial(5)',
          before:
              'Funcion f <- Factorial(n)\nSi n <= 1 Entonces\nf <- 1\nSiNo\nf <- n * Factorial(n - 1)\nFinSi\nFinFuncion',
        ),
        '120\n',
      );
    });

    test('parámetros por referencia', () async {
      expect(
        await run(
          'a <- 1\nb <- 2\nCambiar(a, b)\nEscribir a, b',
          before:
              'SubProceso Cambiar(x Por Referencia, y1 Por Referencia)\naux <- x\nx <- y1\ny1 <- aux\nFinSubProceso',
        ),
        '21\n',
      );
    });

    test('por referencia con posición de arreglo', () async {
      expect(
        await run(
          'Dimension a[2]\na[1] <- 5\nIncrementar(a[1])\nEscribir a[1]',
          before: 'SubProceso Incrementar(n Por Referencia)\nn <- n + 1\nFinSubProceso',
        ),
        '6\n',
      );
    });

    test('los arreglos se comparten con la función', () async {
      expect(
        await run(
          'Dimension a[2]\nLlenar(a)\nEscribir a[1], a[2]',
          before: 'SubProceso Llenar(v)\nv[1] <- 3\nv[2] <- 4\nFinSubProceso',
        ),
        '34\n',
      );
    });

    test('cada función tiene sus propias variables', () async {
      final error = await runError(
        'SubProceso Saludar\nEscribir x\nFinSubProceso\nAlgoritmo p\nx <- 1\nSaludar\nFinAlgoritmo',
      );
      expect(error.message, contains("'x' no existe"));
    });

    test('número incorrecto de argumentos', () async {
      final error = await runError(
        'Funcion r <- f(a, b)\nr <- a\nFinFuncion\nAlgoritmo p\nEscribir f(1)\nFinAlgoritmo',
      );
      expect(error.kind, ErrorKind.syntax);
      expect(error.message, contains('recibe 2 valores'));
    });

    test('recursión profunda legítima', () async {
      expect(
        await run(
          'Escribir Suma(190)',
          before: 'Funcion s <- Suma(n)\nSi n = 0 Entonces\ns <- 0\nSiNo\ns <- n + Suma(n - 1)\nFinSi\nFinFuncion',
        ),
        '18145\n',
      );
    });

    test('recursión infinita', () async {
      final error = await runError(
        'Funcion r <- f(n)\nr <- f(n + 1)\nFinFuncion\nAlgoritmo p\nEscribir f(1)\nFinAlgoritmo',
      );
      expect(error.hint, contains('caso base'));
    });
  });

  group('funciones internas', () {
    test('matemáticas', () async {
      expect(
        await run(
          'Escribir Raiz(16), " ", RC(9), " ", Abs(-3), " ", Trunc(3.9), " ", Redon(3.5), " ", 2^10, " ", 7 MOD 3, " ", 7 % 3',
        ),
        '4 3 3 3 4 1024 1 1\n',
      );
    });

    test('texto', () async {
      expect(
        await run(
          's <- "Jaguar"\nEscribir Longitud(s), Mayusculas(s), Minusculas(s), Subcadena(s, 1, 3), Concatenar("a", "b")',
        ),
        '6JAGUARjaguarJagab\n',
      );
    });

    test('conversiones', () async {
      expect(await run('Escribir ConvertirANumero("12") + 1, ConvertirATexto(5) + "!"'), '135!\n');
    });

    test('PI', () async {
      expect(await run('Escribir Redon(PI * 100)'), '314\n');
    });

    test('Aleatorio dentro del rango', () async {
      expect(await run('x <- Aleatorio(1, 6)\nEscribir x >= 1 Y x <= 6'), 'VERDADERO\n');
    });

    test('raíz de negativo', () async {
      final error = await runError(program('Escribir Raiz(-4)'));
      expect(error.message, contains('negativo'));
    });
  });

  group('errores didácticos', () {
    test('falta FinSi menciona la línea del Si', () async {
      final error = await runError(program('Si 1 < 2 Entonces\nEscribir 1'));
      expect(error.kind, ErrorKind.syntax);
      expect(error.message, contains("falta 'FinSi'"));
      expect(error.message, contains('línea 2'));
    });

    test('cierre equivocado', () async {
      final error = await runError(program('Mientras Verdadero Hacer\nFinPara'));
      expect(error.message, contains("'FinPara'"));
      expect(error.message, contains('FinMientras'));
    });

    test('instrucción mal escrita sugiere la correcta', () async {
      final error = await runError(program('Escrivir "hola"'));
      expect(error.hint, contains("'Escribir'"));
    });

    test('instrucción mal escrita sola en la línea', () async {
      final error = await runError(program('Escrivir'));
      expect(error.hint, contains("'Escribir'"));
    });

    test('variable mal escrita sugiere la correcta', () async {
      final error = await runError(program('contador <- 1\nEscribir contdor'));
      expect(error.message, contains("'contdor'"));
      expect(error.hint, contains("'contador'"));
    });

    test('variable sin valor', () async {
      final error = await runError(program('Definir x Como Entero\nEscribir x'));
      expect(error.message, contains('todavía no tiene valor'));
    });

    test('restar un texto sigue siendo un error', () async {
      final error = await runError(program('Escribir "5" - 1'));
      expect(error.message, contains('resta'));
    });

    test('división entre cero', () async {
      final error = await runError(program('Escribir 1 / 0'));
      expect(error.message, contains('cero'));
    });

    test('función inexistente sugiere la correcta', () async {
      final error = await runError(program('Escribir Raizz(4)'));
      expect(error.hint, contains("'Raiz'"));
    });

    test('tipo de dato mal escrito', () async {
      final error = await runError(program('Definir x Como Enteroo'));
      expect(error.hint, contains("'Entero'"));
    });

    test('texto sin cerrar', () async {
      final error = await runError(program('Escribir "hola'));
      expect(error.message, contains('comillas'));
    });

    test('código fuera de Algoritmo', () async {
      final error = await runError('Escribir "hola"');
      expect(error.hint, contains('Algoritmo'));
    });

    test('Para sin Hasta', () async {
      final error = await runError(program('Para i <- 1 10 Hacer\nFinPara'));
      expect(error.message, contains("'Hasta'"));
    });

    test('format muestra la línea y la sugerencia', () async {
      final source = program('Escrivir "hola"');
      final error = await runError(source);
      expect(
        error.format(source),
        'Error de sintaxis en la línea 2: No entiendo la instrucción \'Escrivir\'.\n'
        '2 | Escrivir "hola"\n'
        '    ^\n'
        "Sugerencia: ¿Quisiste decir 'Escribir'?",
      );
    });
  });

  group('compatibilidad', () {
    test('Proceso / FinProceso', () async {
      expect((await runProgram('Proceso p\nEscribir 1\nFinProceso')).output, '1\n');
    });

    test('archivo en Latin-1 como los que guarda PSeInt en Windows', () {
      final bytes = [...'Algoritmo a\nEscribir "'.codeUnits, 0xF1, ...'"\nFinAlgoritmo'.codeUnits]; // ñ en Latin-1
      expect(decodeSource(bytes), contains('ñ'));
    });

    test('BOM de UTF-8 al inicio', () async {
      expect((await runProgram('﻿Algoritmo p\nEscribir 1\nFinAlgoritmo')).output, '1\n');
    });

    test('Esperar y Borrar Pantalla', () async {
      expect(await run('Esperar 1 Segundo\nEsperar Tecla\nBorrar Pantalla\nLimpiar Pantalla\nEscribir "ok"'), 'ok\n');
    });
  });
}
