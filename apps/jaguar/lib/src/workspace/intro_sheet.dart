import 'package:flutter/material.dart';

import '../theme.dart';

/// What the introduction asks the workspace to do when it closes.
enum IntroResult { done, openGuide }

/// A short introduction shown once, right after choosing how to start:
/// for someone new to programming, four small ideas with examples; for
/// someone who already programs, how Jaguar works in one screen.
Future<IntroResult?> showIntro(BuildContext context, {required bool beginner}) => showDialog<IntroResult>(
  context: context,
  barrierDismissible: false,
  builder: (context) => _IntroDialog(
    pages: beginner ? _beginnerPages : _expertPages(phone: MediaQuery.sizeOf(context).width < 600),
    beginner: beginner,
  ),
);

class _IntroPage {
  const _IntroPage({required this.icon, required this.title, required this.body, this.code});

  final IconData icon;
  final String title;
  final List<String> body;

  /// A small program that illustrates the page.
  final String? code;
}

const _beginnerPages = [
  _IntroPage(
    icon: Icons.format_list_numbered,
    title: 'Un programa es una lista de instrucciones',
    body: [
      'La computadora hace lo que escribes, una instrucción por línea, de arriba hacia abajo.',
      'Todo va entre Algoritmo y FinAlgoritmo. Escribir muestra algo en la pantalla.',
    ],
    code: 'Algoritmo saludo\n    Escribir "Hola"\nFinAlgoritmo',
  ),
  _IntroPage(
    icon: Icons.inventory_2_outlined,
    title: 'Mostrar, preguntar y guardar',
    body: [
      'Leer le pregunta un dato a quien usa el programa y lo guarda en una variable: una cajita con nombre.',
      'Los textos van entre comillas. Con + los juntas con lo que guardaste.',
    ],
    code: 'Leer nombre\nEscribir "Hola, " + nombre',
  ),
  _IntroPage(
    icon: Icons.account_tree_outlined,
    title: 'Código o diagrama: tú eliges',
    body: [
      'Es el mismo programa, escrito o dibujado como diagrama de flujo.',
      'Cambias de uno a otro con el selector Código | Diagrama, justo debajo de la barra de arriba.',
    ],
  ),
  _IntroPage(
    icon: Icons.fact_check_outlined,
    title: 'Cómo sabes si está bien',
    body: [
      'Toca Ejecutar, el triángulo de arriba, para ver qué hace tu programa. Equivocarte es parte de aprender: Jaguar te dice en qué línea y qué hacer.',
      'En Pruebas, Probar compara tu programa con casos de ejemplo. Si te atoras, el reto trae pistas.',
    ],
  ),
];

List<_IntroPage> _expertPages({required bool phone}) => [
  _IntroPage(
    icon: Icons.travel_explore_outlined,
    title: 'Así funciona Jaguar Code',
    body: [
      'Pseudocódigo en español: Algoritmo … FinAlgoritmo, Definir es opcional, los arreglos empiezan en 1 y la '
          'asignación es <- (o =).',
      if (phone)
        'Toca Ejecutar, el triángulo de arriba. Los símbolos y las instrucciones están en la barra sobre el teclado; '
            'el paso a paso y la prueba de escritorio, en el menú de tres puntos.'
      else
        'Ejecutar con el botón de la barra (Ctrl+Enter o F9). Paso a paso con F10, con tabla de variables, y prueba de '
            'escritorio desde el menú.',
      'Código | Diagrama${phone ? '' : ' | Ambos'}: el diagrama se dibuja del código y también se puede editar desde él.',
      'Retos y ejercicios traen pruebas: Probar compara entrada y salida. Los programas se guardan en este '
          'dispositivo y abre y guarda archivos .psc.',
      'Modo Completo muestra todos los menús y atajos; puedes cambiarlo en Ajustes.',
    ],
  ),
];

class _IntroDialog extends StatefulWidget {
  const _IntroDialog({required this.pages, required this.beginner});

  final List<_IntroPage> pages;
  final bool beginner;

  @override
  State<_IntroDialog> createState() => _IntroDialogState();
}

class _IntroDialogState extends State<_IntroDialog> {
  int _page = 0;

  bool get _last => _page == widget.pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final page = widget.pages[_page];
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(page.icon, size: 32, color: scheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(header: true, child: Text(page.title, style: theme.textTheme.titleLarge)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final paragraph in page.body)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(paragraph, style: theme.textTheme.bodyLarge),
                        ),
                      if (page.code case final code?)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(code, style: monoStyle.copyWith(fontSize: 14, color: scheme.onSurface)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.pages.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.pages.length; i++)
                      AnimatedContainer(
                        duration: motion(context, const Duration(milliseconds: 200)),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? scheme.primary : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              // Stacks the buttons when a big system font leaves no room.
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 4,
                overflowAlignment: OverflowBarAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                    onPressed: () => Navigator.pop(context, IntroResult.done),
                    child: Text(_last ? 'Cerrar' : 'Saltar'),
                  ),
                  if (_last && !widget.beginner)
                    TextButton(
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      onPressed: () => Navigator.pop(context, IntroResult.openGuide),
                      child: const Text('Ver la guía'),
                    ),
                  FilledButton(
                    onPressed: () {
                      if (_last) {
                        Navigator.pop(context, IntroResult.done);
                      } else {
                        setState(() => _page++);
                      }
                    },
                    child: Text(_last ? (widget.beginner ? 'Empezar el reto' : 'Entendido') : 'Siguiente'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
