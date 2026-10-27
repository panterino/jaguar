// El núcleo de la prueba de escritorio para la página web: se compila a
// JavaScript (tool/compilar_prueba_web.sh) y la página lo llama con el código y
// los datos de entrada. Corre en el navegador de quien la usa: nada se envía a
// ningún servidor.
import 'dart:convert';
import 'dart:js_interop';

import 'package:jaguar_core/jaguar_core.dart';

@JS('jaguarPruebaDeEscritorio')
external set _pruebaDeEscritorio(JSFunction function);

/// Devuelve un JSON con la tabla: variables, filas y, si el programa falló,
/// el error con su línea y su sugerencia.
Future<String> generar(String fuente, String entradas) async {
  // Un fragmento sin Algoritmo se envuelve para que corra igual.
  final completo = RegExp(r'\b(algoritmo|proceso)\b', caseSensitive: false).hasMatch(fuente)
      ? fuente
      : 'Algoritmo programa\n$fuente\nFinAlgoritmo\n';
  final lineas = entradas.replaceAll('\r', '').split('\n');
  while (lineas.isNotEmpty && lineas.last.trim().isEmpty) {
    lineas.removeLast();
  }
  final check = await deskCheck(completo, inputs: lineas);
  final error = check.error;
  return jsonEncode({
    'variables': check.variables,
    'truncated': check.truncated,
    'rows': [
      for (final row in check.rows)
        {'line': row.line, 'instruction': row.instruction, 'values': row.values, 'output': row.output},
    ],
    'error': error == null
        ? null
        : {'title': error.title, 'line': error.line, 'message': error.message, 'hint': error.hint},
  });
}

void main() {
  _pruebaDeEscritorio = ((JSString fuente, JSString entradas) => generar(
    fuente.toDart,
    entradas.toDart,
  ).then((s) => s.toJS).toJS).toJS;
}
