import 'package:flutter/material.dart';

import '../settings.dart';
import '../theme.dart';

/// A short guide to Jaguar: what each part does, in the order people
/// usually need it. Opens with F1 and from Ayuda.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final run = shortcutLabel('Enter');
    final sections = <_Section>[
      _Section(Icons.edit_note, 'Escribe o dibuja tu algoritmo', [
        'En Pseudocódigo escribes como en PSeInt: Algoritmo, Leer, Escribir, Si, Mientras, Para…',
        'En Diagrama dibujas como en DFD: elige un objeto de la paleta y toca un ＋ en una flecha. '
            'Doble clic en un bloque para cambiarlo.',
        'Las dos vistas son el mismo programa: lo que cambias en una aparece en la otra. '
            'El botón de la barra de arriba muestra una, la otra o ambas.',
        'Jaguar cierra solo los paréntesis, las comillas y los bloques (FinSi, FinMientras…), y '
            'subraya en rojo los errores mientras escribes, con su explicación al final de la línea.',
      ]),
      _Section(Icons.play_arrow, 'Ejecuta', [
        'Presiona Ejecutar ($run o F9). Lo que muestra tu programa aparece en la consola, abajo.',
        'Cuando el programa usa Leer, escribe el dato en la consola y presiona Enter.',
        'Si hay un error, Jaguar te dice en qué línea, qué pasó y cómo arreglarlo.',
      ]),
      _Section(Icons.directions_walk, 'Ve paso a paso', [
        'F10 (o F7, como en DFD) ejecuta una instrucción a la vez: se ilumina en el código y en el diagrama.',
        'Abajo verás cada variable y su valor; las que acaban de cambiar se marcan.',
        'F4 ejecuta hasta la línea donde está el cursor. En pausa puedes evaluar cualquier expresión.',
      ]),
      _Section(Icons.fact_check_outlined, 'Resuelve ejercicios', [
        'Un ejercicio llega con un enlace, un QR o desde tu clase. Arriba ves el enunciado.',
        'Probar revisa tu programa con las pruebas del profesor y te explica cuál falla y por qué.',
        'Cuando todo está bien, Mostrar al profesor enseña una pantalla verde con tu nombre y la hora.',
      ]),
      _Section(Icons.save_alt, 'Guarda y lleva tu trabajo', [
        'Tus programas se guardan solos en este dispositivo, sin cuenta.',
        'Guardar crea un archivo .psc que abre PSeInt; Abrir lee los .psc de PSeInt.',
        'Compartir genera un QR o un enlace: ábrelo en otro equipo o en tu celular y sigues ahí.',
      ]),
      _Section(Icons.groups_outlined, 'Clases (profesores y alumnos)', [
        'Profesor: entra con tu correo, crea una clase y dale el código a tu grupo (como JAG-4K7Q).',
        'Escribe tu solución y elige Profesor → Crear ejercicio con este programa: Jaguar genera las '
            'pruebas solas. Después asígnalo a tu clase.',
        'En tu clase ves una tabla con el avance de cada alumno; toca una celda para ver su programa.',
        'Alumno: Mis clases → Unirme con un código. Al resolver una tarea, cada Probar le llega a tu profesor.',
      ]),
      _Section(Icons.public, 'Comunidad', [
        'Programas y ejercicios que comparten otras personas: ábrelos, pruébalos y haz tu versión.',
        'Archivo → Publicar en la comunidad comparte tu programa con tu alias, dando crédito a quien remezcles.',
        'Si algo no está bien, repórtalo: una persona lo revisa.',
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Guía rápida')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [for (final section in sections) section, const SizedBox(height: 8), const _Shortcuts()],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.icon, this.title, this.points);

  final IconData icon;
  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            for (final point in points)
              Padding(padding: const EdgeInsets.only(left: 34, top: 4), child: Text('• $point')),
          ],
        ),
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = [
      ('Ejecutar', '${shortcutLabel('Enter')} · F9'),
      ('Paso a paso / siguiente paso', 'F10 · F7'),
      ('Ejecutar hasta el cursor', 'F4'),
      ('Probar un ejercicio', shortcutLabel('Enter', shift: true)),
      ('Guardar como .psc', shortcutLabel('S')),
      ('Buscar · reemplazar', '${shortcutLabel('F')} · ${shortcutLabel('H')}'),
      ('Comentar líneas', shortcutLabel('/')),
      ('Mover · duplicar línea', 'Alt+↑/↓ · Shift+Alt+↓'),
      ('Ordenar sangría', 'Shift+Alt+F'),
      ('Renombrar variable', 'F2'),
      ('Sugerencias', 'Ctrl+Espacio'),
      ('Ver pseudocódigo · diagrama · ambos', '${shortcutLabel('Alt+1')} · 2 · 3'),
      ('Esta guía', 'F1'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.keyboard_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text('Atajos de teclado', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            for (final (action, keys) in rows)
              Padding(
                padding: const EdgeInsets.only(left: 34, top: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(action)),
                    Text(keys, style: monoStyle.copyWith(fontSize: 13, letterSpacing: 0)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
