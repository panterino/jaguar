import 'package:flutter/material.dart';

import '../settings.dart';
import '../theme.dart';

/// Jaguar's guide, inside the app so it works without internet. One tab for
/// students and one for teachers; it opens on the tab of the chosen
/// profile. Each topic explains how it's done on this device (phone or
/// computer) and, when it can, takes you there.
class GuideScreen extends StatelessWidget {
  const GuideScreen({
    super.key,
    this.teacher = false,
    this.onOpenChallenges,
    this.onDeskCheck,
    this.onPlan,
    this.onOpenClasses,
    this.onOpenTeacher,
  });

  /// Opens on the Profe tab.
  final bool teacher;
  final VoidCallback? onOpenChallenges;
  final VoidCallback? onDeskCheck;
  final VoidCallback? onPlan;
  final VoidCallback? onOpenClasses;
  final VoidCallback? onOpenTeacher;

  @override
  Widget build(BuildContext context) {
    final desktop = useDesktopLayout(context);
    // The guide closes and then the action runs, on the main screen.
    VoidCallback? go(VoidCallback? action) => action == null
        ? null
        : () {
            Navigator.pop(context);
            action();
          };

    return DefaultTabController(
      length: 2,
      initialIndex: teacher ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guía de Jaguar'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.backpack_outlined), text: 'Alumno'),
              Tab(icon: Icon(Icons.school_outlined), text: 'Profe'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Page(
              greeting: desktop
                  ? '¡Hola! Aquí está lo que puedes hacer en Jaguar. Toca un tema para ver cómo se hace en la computadora.'
                  : '¡Hola! Aquí está lo que puedes hacer en Jaguar. Toca un tema para ver cómo se hace en tu celular.',
              topics: _studentTopics(desktop: desktop, go: go),
              extra: [
                const _Heading('Si algo no sale'),
                for (final (q, a) in _problems(desktop: desktop)) _Problem(question: q, answer: a),
                if (desktop) ...[const _Heading('Atajos de teclado'), const _Shortcuts()],
              ],
            ),
            _Page(
              greeting:
                  'Jaguar es una herramienta: tú pones los ejercicios, el ritmo y la calificación. '
                  'Así lo usas con tu grupo.',
              topics: _teacherTopics(desktop: desktop, go: go),
              extra: const [
                SizedBox(height: 8),
                _Note(
                  'Tus alumnos ven su propia guía en la pestaña Alumno. Si quieres explicarles algo, '
                  'ábrela con ellos en el proyector.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_Topic> _studentTopics({required bool desktop, required VoidCallback? Function(VoidCallback?) go}) => [
    _Topic(
      icon: Icons.play_arrow_rounded,
      title: 'Tu primer programa',
      summary: 'Escribe, ejecuta y ve qué pasa',
      steps: [
        'Escribe entre Algoritmo y FinAlgoritmo, como en PSeInt: Escribir, Leer, Si, Mientras...',
        desktop
            ? 'Presiona Ejecutar (${shortcutLabel('Enter')} o F9). Lo que muestra tu programa sale en la consola.'
            : 'Toca el botón redondo de reproducir, arriba a la derecha. Jaguar cambia a la Consola y ahí ves lo que muestra.',
        'Si tu programa usa Leer, escribe el dato en la consola y presiona Enter.',
        if (!desktop)
          'La barra de teclas de abajo trae los símbolos y las palabras que más usas: <- " " ( ) Escribir...',
      ],
    ),
    _Topic(
      icon: Icons.account_tree_outlined,
      title: 'Código y diagrama',
      summary: 'El mismo programa, de dos formas',
      steps: [
        desktop
            ? 'Arriba eliges Pseudocódigo, Diagrama o los dos lado a lado.'
            : 'El botón de diagrama, arriba, cambia entre el código y el diagrama de flujo.',
        'Para dibujar: elige una figura (Lectura, Asignación, Salida, Si...) y toca el signo + de una flecha.',
        desktop
            ? 'Doble clic en un bloque para cambiarlo; clic derecho para eliminarlo.'
            : 'Mantén presionado un bloque para editarlo o eliminarlo.',
        'Lo que cambias en el diagrama aparece en el código, y al revés.',
      ],
    ),
    _Topic(
      icon: Icons.error_outline,
      title: 'Cuando hay un error',
      summary: 'Jaguar te dice dónde y cómo arreglarlo',
      steps: [
        desktop
            ? 'La línea se subraya en rojo y la explicación aparece al final de esa línea.'
            : 'La línea se subraya en rojo y la explicación aparece debajo del código. Tócala para ir a la línea.',
        'Lee la sugerencia: casi siempre dice qué escribir. Por ejemplo, los textos van entre comillas.',
      ],
    ),
    _Topic(
      icon: Icons.flag_outlined,
      title: 'Retos',
      summary: 'Diez ejercicios para practicar por tu cuenta',
      steps: [
        'Van en orden: variables, operadores, Si, Según, Mientras, Para y Repetir.',
        'Si te atoras, el botón del foco te da pistas, de una idea a un ejemplo, sin darte la respuesta.',
        'Probar revisa tu programa. Cuando pasa todo, sigue con Siguiente reto.',
      ],
      action: ('Ver los retos', go(onOpenChallenges)),
    ),
    _Topic(
      icon: Icons.edit_note,
      title: 'Planteamiento',
      summary: 'Piensa el problema antes de programar',
      steps: [
        'Escribe qué datos entran, qué haces con ellos y qué sale.',
        desktop ? 'Está en el menú Archivo, en Planteamiento.' : 'Está en el menú de tres puntos, en Planteamiento.',
        'Se guarda como comentario al inicio del programa, así que tu profe también lo ve.',
      ],
      action: ('Escribir el planteamiento', go(onPlan)),
    ),
    _Topic(
      icon: Icons.table_chart_outlined,
      title: 'Prueba de escritorio',
      summary: 'La tabla de variables, paso a paso',
      steps: [
        desktop
            ? 'Está en el menú Ejecutar, en Prueba de escritorio.'
            : 'Está en el menú de tres puntos, en Prueba de escritorio.',
        'Escribe los datos de entrada separados por comas y toca Hacer la tabla.',
        'Con Practicar la llenas tú y Revisar te marca qué valores están bien.',
      ],
      action: ('Hacer la prueba de escritorio', go(onDeskCheck)),
    ),
    if (desktop)
      const _Topic(
        icon: Icons.directions_walk,
        title: 'Paso a paso',
        summary: 'Ve tu programa instrucción por instrucción',
        steps: [
          'F10 (o F7, como en DFD) ejecuta una instrucción a la vez y la ilumina en el código y el diagrama.',
          'Abajo ves cada variable; las que acaban de cambiar se marcan.',
          'F4 ejecuta hasta la línea del cursor.',
        ],
      ),
    _Topic(
      icon: Icons.save_alt,
      title: 'Guardar y compartir',
      summary: 'Tus programas se quedan en este equipo',
      steps: [
        'Se guardan solos, sin cuenta. Los encuentras en el menú de la izquierda.',
        desktop
            ? 'Guardar crea un archivo .psc que abre PSeInt; Abrir lee los .psc.'
            : 'En el menú de tres puntos: Guardar como .psc, Abrir archivo .psc o Enviar .psc por WhatsApp o correo.',
        'El botón de QR arriba te da un código o un enlace para seguir en otro equipo.',
      ],
    ),
    _Topic(
      icon: Icons.groups_outlined,
      title: 'Tu clase',
      summary: 'Únete con el código de tu profe y entrega',
      steps: [
        'Abre Mis clases y toca Unirme con un código. Escribe el código y tu nombre; no necesitas correo.',
        'Abre una tarea, resuélvela y toca Probar: el resultado le llega a tu profe.',
        'En el salón, cuando todo pasa, Mostrar al profesor enseña una pantalla verde con tu nombre y la hora.',
      ],
      action: ('Ir a Mis clases', go(onOpenClasses)),
    ),
    _Topic(
      icon: Icons.wifi_off_outlined,
      title: 'Sin internet',
      summary: 'Programar no necesita datos',
      steps: [
        'Escribir, ejecutar, probar y los retos funcionan sin conexión.',
        'Solo las clases y la comunidad necesitan internet.',
        if (!desktop) 'En el navegador del celular puedes instalar Jaguar: abre el menú de Chrome y toca Instalar app.',
      ],
    ),
  ];

  List<_Topic> _teacherTopics({required bool desktop, required VoidCallback? Function(VoidCallback?) go}) => [
    _Topic(
      icon: Icons.assignment_outlined,
      title: 'Crea un ejercicio',
      summary: 'Tu solución genera las pruebas',
      steps: [
        'Abre Mis ejercicios y toca Nuevo ejercicio. Escribe el título y el enunciado.',
        'Pega o escribe tu solución y toca Generar casos con mi solución: Jaguar propone las pruebas.',
        'Revísalas, cámbialas u ocúltalas para que no programen "para el ejemplo".',
        if (desktop) 'Atajo: con tu solución abierta, menú Profesor, Crear ejercicio con este programa.',
        'La comparación Flexible ignora mayúsculas, acentos y espacios de más; Exacta no.',
      ],
      action: ('Ir a Mis ejercicios', go(onOpenTeacher)),
    ),
    const _Topic(
      icon: Icons.qr_code_2,
      title: 'Compártelo sin internet',
      summary: 'Con un QR en el proyector o un enlace',
      steps: [
        'En Mis ejercicios, Proyectar muestra el QR grande para que tu grupo lo escanee.',
        'También puedes copiar el enlace y mandarlo por WhatsApp.',
        'Cuando un alumno pasa todas las pruebas, te enseña la pantalla verde con su nombre y la hora.',
      ],
    ),
    _Topic(
      icon: Icons.groups_outlined,
      title: 'Tu clase en línea',
      summary: 'Un código para tu grupo',
      steps: [
        'Entra en línea como Profesor con tu correo, para no perder tus clases si cambias de equipo.',
        'En Mis clases toca Nueva clase. Jaguar te da un código como JAG-4K7Q para tu grupo.',
        'Tus alumnos entran con el código y un nombre; no necesitan correo.',
        'Dentro de la clase, Asignar ejercicio elige uno de tus ejercicios.',
      ],
      action: ('Ir a Mis clases', go(onOpenClasses)),
    ),
    const _Topic(
      icon: Icons.fact_check_outlined,
      title: 'Revisa las entregas',
      summary: 'Quién va cómo, en una tabla',
      steps: [
        'Cada vez que un alumno toca Probar, su resultado aparece en la tabla de la clase.',
        'Toca una celda para ver su programa.',
        'Si ves el ícono de portapapeles, pegó muchas líneas de una vez: pídele que te explique su programa.',
        'Jaguar no califica: la calificación y la rúbrica las pones tú.',
      ],
    ),
  ];

  List<(String, String)> _problems({required bool desktop}) => [
    (
      'El programa no termina y la consola espera',
      'Está esperando un dato de Leer. Escríbelo en la consola y presiona Enter.',
    ),
    (
      'Dice "Parece un texto sin comillas"',
      'Los textos van entre comillas: Escribir "Hola". Sin comillas, Jaguar cree que son variables.',
    ),
    (
      'No veo el diagrama',
      desktop
          ? 'Arriba, elige Diagrama o los dos lado a lado.'
          : 'Toca el botón de diagrama arriba. Para volver al código, tócalo otra vez.',
    ),
    (
      'No encuentro mi programa',
      'Abre el menú de la izquierda: ahí están todos los programas de este equipo, el más reciente arriba.',
    ),
    ('No aparece Mis clases', 'Las clases necesitan internet. Conéctate y vuelve a abrir Jaguar.'),
  ];
}

class _Topic {
  const _Topic({required this.icon, required this.title, required this.summary, required this.steps, this.action});

  final IconData icon;
  final String title;
  final String summary;
  final List<String> steps;

  /// A button that takes you there; hidden when the action isn't available.
  final (String, VoidCallback?)? action;
}

class _Page extends StatelessWidget {
  const _Page({required this.greeting, required this.topics, this.extra = const []});

  final String greeting;
  final List<_Topic> topics;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Card(
              color: scheme.primaryContainer,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset('assets/images/mascota.png', width: 56, height: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        greeting,
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final topic in topics) _TopicCard(topic: topic),
            ...extra,
            const SizedBox(height: 16),
            Text(
              'El manual con imágenes está en pseudocodigo-jaguar.web.app/manual',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final action = topic.action;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: jaguarYellow.withValues(alpha: 0.3),
          foregroundColor: scheme.onSurface,
          child: Icon(topic.icon),
        ),
        title: Text(topic.title, style: theme.textTheme.titleMedium),
        subtitle: Text(topic.summary),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, step) in topic.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(step, style: theme.textTheme.bodyLarge)),
                ],
              ),
            ),
          if (action != null && action.$2 != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: FilledButton.tonalIcon(
                onPressed: action.$2,
                icon: const Icon(Icons.arrow_forward),
                label: Text(action.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _Problem extends StatelessWidget {
  const _Problem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      shape: const Border(),
      leading: const Icon(Icons.help_outline),
      title: Text(question),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(answer, style: Theme.of(context).textTheme.bodyLarge)],
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(color: scheme.onSecondaryContainer)),
            ),
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
          children: [
            for (final (action, keys) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
