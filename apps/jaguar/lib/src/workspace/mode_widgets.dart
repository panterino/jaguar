import 'package:flutter/material.dart';

import '../settings.dart';

/// What the person answered the first time Jaguar opened.
enum WelcomeChoice { learning, programmer, teacher }

/// The question Jaguar asks on its first launch, and again whenever the
/// person wants to change how they use it ([again]). It sets the mode and
/// whether the teacher tools show.
Future<WelcomeChoice?> showWelcome(BuildContext context, {bool again = false}) => showDialog<WelcomeChoice>(
  context: context,
  barrierDismissible: again,
  builder: (context) => _WelcomeDialog(again: again),
);

class _WelcomeDialog extends StatelessWidget {
  const _WelcomeDialog({this.again = false});

  final bool again;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/mascota.png', height: 80),
              const SizedBox(height: 12),
              Text(
                again ? '¿Cómo usas Jaguar?' : '¡Hola! ¿Cómo quieres empezar?',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const _WelcomeOption(
                choice: WelcomeChoice.learning,
                icon: Icons.emoji_objects_outlined,
                title: 'Estoy aprendiendo',
                subtitle: 'Solo lo necesario para escribir y ejecutar tus programas',
              ),
              const _WelcomeOption(
                choice: WelcomeChoice.programmer,
                icon: Icons.terminal,
                title: 'Ya sé programar',
                subtitle: 'Todos los menús, atajos y opciones',
              ),
              const _WelcomeOption(
                choice: WelcomeChoice.teacher,
                icon: Icons.school_outlined,
                title: 'Soy profesor',
                subtitle: 'Crea ejercicios con pruebas para tu grupo',
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes cambiarlo cuando quieras.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeOption extends StatelessWidget {
  const _WelcomeOption({required this.choice, required this.icon, required this.title, required this.subtitle});

  final WelcomeChoice choice;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pop(context, choice),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 28, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `Básico | Completo`, always at hand.
class ModeSwitch extends StatelessWidget {
  const ModeSwitch({super.key, required this.settings, this.dense = true});

  final ViewSettings settings;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: settings.isBasic
          ? 'Básico: solo lo necesario para empezar'
          : 'Completo: todos los menús, atajos y tus propias pruebas',
      child: SegmentedButton<AppMode>(
        segments: const [
          ButtonSegment(value: AppMode.basic, label: Text('Básico')),
          ButtonSegment(value: AppMode.full, label: Text('Completo')),
        ],
        selected: {settings.mode},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => settings.mode = selection.single,
        style: dense
            ? SegmentedButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                textStyle: const TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              )
            : null,
      ),
    );
  }
}
