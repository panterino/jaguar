import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../editor/syntax_controller.dart';
import '../exercises/exercise_store.dart';
import '../settings.dart';
import '../theme.dart';
import 'mode_widgets.dart';

/// Same breakpoint as the rooms: from here the settings use two columns.
const _wideWidth = 900.0;

/// Everything that changes how Jaguar looks or who it is for, in one place.
/// Nothing here is new: these controls used to be spread over menus.
///
/// On a phone it is one list; on a computer, cards in two columns centered
/// on the page, so the controls stay close to their labels.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.exercises,
    required this.onChangeName,
    required this.onWelcome,
    required this.onIntro,
    required this.onRepeatTour,
    this.onCommunity,
    this.onAccount,
    required this.onAbout,
  });

  final ViewSettings settings;
  final ExerciseStore exercises;
  final VoidCallback onChangeName;

  /// Asks again how the person uses Jaguar.
  final VoidCallback onWelcome;

  /// Shows the introduction again.
  final VoidCallback onIntro;

  /// Starts over the balloons of the first challenge.
  final VoidCallback onRepeatTour;

  /// Community programs and the online account: null when offline.
  final VoidCallback? onCommunity;
  final VoidCallback? onAccount;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _wideWidth;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: CallbackShortcuts(
        // Esc goes back, as in a dialog.
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.maybePop(context)},
        child: Focus(
          autofocus: true,
          child: ListenableBuilder(
            listenable: Listenable.merge([settings, exercises]),
            builder: (context, _) {
              final profile = _profile(context);
              final look = _look(context);
              final views = _views();
              final you = _you();
              final others = _others();
              if (!wide) {
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _Heading('Modo y perfil'),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: profile),
                    _Heading('Apariencia'),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: look),
                    _Heading('Vistas del programa'),
                    views,
                    _Heading('Tú'),
                    you,
                    _Heading('Otros'),
                    others,
                  ],
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Each column is its own focus group: Tab goes down
                        // the left one and then the right one.
                        Expanded(
                          child: FocusTraversalGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SectionCard(title: 'Modo y perfil', icon: Icons.tune, padded: true, child: profile),
                                const SizedBox(height: 20),
                                _SectionCard(
                                  title: 'Apariencia',
                                  icon: Icons.palette_outlined,
                                  padded: true,
                                  child: look,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: FocusTraversalGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SectionCard(
                                  title: 'Vistas del programa',
                                  icon: Icons.view_quilt_outlined,
                                  child: views,
                                ),
                                const SizedBox(height: 20),
                                _SectionCard(title: 'Tú', icon: Icons.person_outline, child: you),
                                const SizedBox(height: 20),
                                _SectionCard(title: 'Otros', icon: Icons.more_horiz, child: others),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profile(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label('Modo'),
        ModeSwitch(settings: settings, dense: false),
        const SizedBox(height: 6),
        Text(
          settings.isBasic
              ? 'Básico muestra solo lo necesario para escribir, ejecutar y entender tu resultado.'
              : 'Completo muestra todos los menús, atajos y tus propias pruebas.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        const _Label('Perfil'),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Alumno')),
            ButtonSegment(value: true, label: Text('Profesor')),
          ],
          selected: {settings.teacher},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => settings.teacher = selection.single,
        ),
        const SizedBox(height: 6),
        Text(
          settings.teacher
              ? 'Profesor muestra tus ejercicios y las herramientas para tus clases.'
              : 'Alumno esconde las herramientas de profesor.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _look(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label('Tema'),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
            ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
          ],
          selected: {settings.themeMode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => settings.themeMode = selection.single,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: _Label('Tamaño de letra del código')),
            Text('${settings.fontSize.round()} px', style: theme.textTheme.labelLarge),
          ],
        ),
        Slider(
          min: ViewSettings.minFontSize,
          max: ViewSettings.maxFontSize,
          divisions: (ViewSettings.maxFontSize - ViewSettings.minFontSize).round(),
          value: settings.fontSize.clamp(ViewSettings.minFontSize, ViewSettings.maxFontSize),
          label: settings.fontSize.round().toString(),
          semanticFormatterCallback: (value) => '${value.round()} píxeles',
          onChanged: (value) => settings.fontSize = value,
        ),
        _CodePreview(fontSize: settings.fontSize),
      ],
    );
  }

  Widget _views() => SwitchListTile(
    secondary: const Icon(Icons.terminal_rounded),
    title: const Text('Mostrar la vista Python'),
    subtitle: const Text(
      'Tu programa traducido a Python, solo para leer. Se prende sola cuando llegas a esa parte de la Ruta.',
    ),
    value: settings.pythonEnabled,
    onChanged: (value) => settings.pythonEnabled = value,
  );

  Widget _you() => ListTile(
    leading: const Icon(Icons.badge_outlined),
    title: Text(exercises.studentName ?? 'Tu nombre'),
    subtitle: const Text('Aparece al mostrar un ejercicio al profesor'),
    trailing: const Icon(Icons.edit_outlined),
    onTap: onChangeName,
  );

  Widget _others() => Column(
    children: [
      ListTile(
        leading: const Icon(Icons.waving_hand_outlined),
        title: const Text('Volver a ver la bienvenida'),
        onTap: onWelcome,
      ),
      ListTile(
        leading: const Icon(Icons.school_outlined),
        title: const Text('Ver la introducción'),
        subtitle: const Text('Las ideas básicas, en cuatro pantallas'),
        onTap: onIntro,
      ),
      ListTile(
        leading: const Icon(Icons.tips_and_updates_outlined),
        title: const Text('Repetir la guía del Reto 1'),
        onTap: onRepeatTour,
      ),
      if (onCommunity case final community?)
        ListTile(leading: const Icon(Icons.public), title: const Text('Programas de la comunidad'), onTap: community),
      if (onAccount case final account?)
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('Mi cuenta en línea'),
          onTap: account,
        ),
      ListTile(leading: const Icon(Icons.info_outline), title: const Text('Acerca de Jaguar Code'), onTap: onAbout),
    ],
  );
}

/// A group of settings in a card with its title, for the wide layout.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child, this.padded = false});

  final String title;
  final IconData icon;
  final Widget child;

  /// Whether [child] needs padding (controls) or brings its own (list tiles).
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(header: true, child: Text(title, style: theme.textTheme.titleMedium)),
                ),
              ],
            ),
          ),
          if (padded)
            Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), child: child)
          else
            Padding(padding: const EdgeInsets.only(bottom: 8), child: child),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Semantics(header: true, child: Text(text, style: theme.textTheme.titleSmall)),
    );
  }
}

/// The small name above a control.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}

/// A few lines of code at the chosen size, so the slider shows what it does.
class _CodePreview extends StatefulWidget {
  const _CodePreview({required this.fontSize});

  final double fontSize;

  @override
  State<_CodePreview> createState() => _CodePreviewState();
}

class _CodePreviewState extends State<_CodePreview> {
  final _code = SyntaxController(text: 'Algoritmo saludo\n    Escribir "Hola"\nFinAlgoritmo');

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = monoStyle.copyWith(fontSize: widget.fontSize, height: 1.5, letterSpacing: 0, color: scheme.onSurface);
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text.rich(_code.buildTextSpan(context: context, style: style, withComposing: false), softWrap: false),
        ),
      ),
    );
  }
}
