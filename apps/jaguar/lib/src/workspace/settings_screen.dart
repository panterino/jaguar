import 'package:flutter/material.dart';

import '../exercises/exercise_store.dart';
import '../settings.dart';
import 'mode_widgets.dart';

/// Everything that changes how Jaguar looks or who it is for, in one place.
/// Nothing here is new: these controls used to be spread over menus.
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListenableBuilder(
        listenable: Listenable.merge([settings, exercises]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const _Heading('Modo y perfil'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModeSwitch(settings: settings, dense: false),
                  const SizedBox(height: 6),
                  Text(
                    settings.isBasic
                        ? 'Básico muestra solo lo necesario para escribir, ejecutar y entender tu resultado.'
                        : 'Completo muestra todos los menús, atajos y tus propias pruebas.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Alumno')),
                      ButtonSegment(value: true, label: Text('Profesor')),
                    ],
                    selected: {settings.teacher},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) => settings.teacher = selection.single,
                  ),
                ],
              ),
            ),
            const _Heading('Apariencia'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
                ],
                selected: {settings.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) => settings.themeMode = selection.single,
              ),
            ),
            ListTile(
              title: const Text('Tamaño de letra del código'),
              subtitle: Slider(
                min: ViewSettings.minFontSize,
                max: ViewSettings.maxFontSize,
                divisions: (ViewSettings.maxFontSize - ViewSettings.minFontSize).round(),
                value: settings.fontSize.clamp(ViewSettings.minFontSize, ViewSettings.maxFontSize),
                label: settings.fontSize.round().toString(),
                onChanged: (value) => settings.fontSize = value,
              ),
            ),
            const _Heading('Tú'),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(exercises.studentName ?? 'Tu nombre'),
              subtitle: const Text('Aparece al mostrar un ejercicio al profesor'),
              onTap: onChangeName,
            ),
            const _Heading('Otros'),
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
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('Programas de la comunidad'),
                onTap: community,
              ),
            if (onAccount case final account?)
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Mi cuenta en línea'),
                onTap: account,
              ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de Jaguar Code'),
              onTap: onAbout,
            ),
          ],
        ),
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
