// El núcleo del generador de diagramas para la página web: se compila a
// JavaScript (tool/publicar_sitio.sh) y la página lo llama con el código. Corre
// en el navegador de quien la usa: nada se envía a ningún servidor.
import 'dart:convert';
import 'dart:js_interop';

import 'package:jaguar_core/jaguar_core.dart';

@JS('jaguarDiagrama')
external set _diagrama(JSFunction function);

/// Devuelve un JSON con un diagrama por Algoritmo, SubProceso o Funcion (el
/// principal primero) o, si el código tiene un error, el error con su línea.
String generar(String fuente) {
  // Un fragmento sin Algoritmo se envuelve para que se dibuje igual.
  final completo = RegExp(r'\b(algoritmo|proceso)\b', caseSensitive: false).hasMatch(fuente)
      ? fuente
      : 'Algoritmo programa\n$fuente\nFinAlgoritmo\n';
  try {
    final charts = flowchartsFor(parse(completo), metrics: const FlowMetrics(charWidth: 7.6, margin: 16));
    return jsonEncode({
      'diagramas': [
        for (final chart in charts)
          {
            'titulo': chart.title,
            'svg': flowchartSvg(chart, title: 'Diagrama de flujo de ${chart.title}'),
            'archivo': flowchartSvg(chart, title: 'Diagrama de flujo de ${chart.title}', standalone: true),
            'ancho': chart.width,
            'alto': chart.height,
          },
      ],
      'error': null,
    });
  } on JaguarError catch (error) {
    return jsonEncode({
      'diagramas': <Object>[],
      'error': {'title': error.title, 'line': error.line, 'message': error.message, 'hint': error.hint},
    });
  }
}

void main() {
  _diagrama = ((JSString fuente) => generar(fuente.toDart).toJS).toJS;
}
