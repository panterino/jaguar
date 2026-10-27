import 'package:flutter/material.dart';

import '../settings.dart';
import 'challenges.dart';
import '../widgets/mascota.dart';

/// The level 1 challenges, in order, with the ones already solved marked.
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key, required this.settings, required this.onOpen});

  final ViewSettings settings;
  final ValueChanged<Challenge> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Retos')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final done = settings.doneChallenges;
          final solved = challenges.where((c) => done.contains(c.id)).length;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Nivel 1 · lo básico', style: theme.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Un reto por tema, en orden. Cada uno se revisa con pruebas y trae pistas si te atoras. '
                  'Llevas $solved de ${challenges.length}.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(value: solved / challenges.length),
              ),
              const SizedBox(height: 8),
              for (final (index, challenge) in challenges.indexed)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: done.contains(challenge.id)
                        ? Colors.green.shade600
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: done.contains(challenge.id) ? Colors.white : theme.colorScheme.onSurface,
                    child: done.contains(challenge.id) ? const Icon(Icons.check) : Text('${index + 1}'),
                  ),
                  title: Text(challenge.exercise.title.replaceFirst(RegExp(r'^Reto \d+ · '), '')),
                  subtitle: Text(challenge.topic),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    onOpen(challenge);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The hints of a challenge, one at a time.
Future<void> showHints(BuildContext context, Challenge challenge) => showDialog<void>(
  context: context,
  builder: (context) => _HintsDialog(challenge: challenge),
);

class _HintsDialog extends StatefulWidget {
  const _HintsDialog({required this.challenge});

  final Challenge challenge;

  @override
  State<_HintsDialog> createState() => _HintsDialogState();
}

class _HintsDialogState extends State<_HintsDialog> {
  int _shown = 1;

  @override
  Widget build(BuildContext context) {
    final hints = widget.challenge.hints;
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          // Thinking at first; once there is more than one hint, she has the idea.
          Mascota(pose: _shown > 1 ? MascotPose.idea : MascotPose.pensando, size: 56),
          const SizedBox(width: 10),
          const Text('Pistas'),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _shown; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${i + 1}. ${hints[i]}',
                    style: hints[i].contains('\n') || hints[i].contains('<-')
                        ? theme.textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono')
                        : theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (_shown < hints.length)
          TextButton(onPressed: () => setState(() => _shown++), child: const Text('Otra pista')),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('A intentarlo')),
      ],
    );
  }
}
