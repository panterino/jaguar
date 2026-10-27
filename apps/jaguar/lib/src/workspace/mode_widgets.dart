import 'package:flutter/material.dart';

import '../settings.dart';
import '../widgets/mascota.dart';

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

  Future<void> _askTeacher(BuildContext context) async {
    final activate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modo profesor'),
        content: const Text(
          'Crea ejercicios con pruebas para tu grupo y revisa lo que entregan. '
          'Se activa en este dispositivo y lo cambias en Ajustes.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Activar modo profesor')),
        ],
      ),
    );
    if ((activate ?? false) && context.mounted) Navigator.pop(context, WelcomeChoice.teacher);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Mascota(pose: MascotPose.guino, size: 64),
              const SizedBox(height: 8),
              Text(
                again ? '¿Cómo usas Jaguar Code?' : '¡Hola! Esto es Jaguar Code',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (!again) ...[
                const SizedBox(height: 8),
                Text(
                  'Aprende a programar paso a paso, en español y sin internet. ¿Cómo quieres empezar?',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              const _WelcomeOption(
                choice: WelcomeChoice.learning,
                icon: Icons.emoji_objects_outlined,
                title: 'Empezar desde cero',
                subtitle: 'Una lección corta y luego tu primer programa.',
                highlighted: true,
              ),
              const _WelcomeOption(
                choice: WelcomeChoice.programmer,
                icon: Icons.terminal,
                title: 'Ya sé algo de programar',
                subtitle: 'Abre un programa listo para ejecutar.',
              ),
              const SizedBox(height: 4),
              Text(
                'Puedes cambiarlo en Ajustes.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => _askTeacher(context),
                  child: const Text('Soy profesor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeOption extends StatelessWidget {
  const _WelcomeOption({
    required this.choice,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlighted = false,
  });

  final WelcomeChoice choice;
  final IconData icon;
  final String title;
  final String subtitle;

  /// The way most people should take: the only filled card.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = highlighted ? scheme.onPrimaryContainer : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: highlighted ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: highlighted ? scheme.primary : scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pop(context, choice),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 28, color: highlighted ? foreground : scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: foreground)),
                        Text(subtitle, style: TextStyle(color: highlighted ? foreground : scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: highlighted ? foreground : scheme.onSurfaceVariant),
                ],
              ),
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
