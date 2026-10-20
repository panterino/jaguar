import 'package:flutter/material.dart';

import '../challenges/challenges.dart';
import '../programs/examples.dart';
import '../programs/program_store.dart';
import '../settings.dart';
import '../theme.dart';
import 'programs_drawer.dart';

/// What the content area shows when there is no program open: quick actions
/// and recent programs, like the welcome tab of a code editor. Beginners get
/// the challenges first; people who already program get New and Open.
class StartPanel extends StatelessWidget {
  const StartPanel({
    super.key,
    required this.settings,
    required this.store,
    required this.onNew,
    required this.onOpenFile,
    required this.onOpenSource,
    required this.onOpenLink,
    required this.onOpenChallenges,
    required this.onContinueChallenge,
    required this.onSelect,
    this.onScan,
    this.onOpenTeacher,
    required this.onOpenGuide,
    required this.onOpenSettings,
  });

  final ViewSettings settings;
  final ProgramStore store;
  final VoidCallback onNew;
  final VoidCallback onOpenFile;
  final ValueChanged<String> onOpenSource;
  final VoidCallback onOpenLink;
  final VoidCallback onOpenChallenges;

  /// Opens the next challenge to solve.
  final ValueChanged<Challenge> onContinueChallenge;
  final ValueChanged<SavedProgram> onSelect;

  /// The camera, on phones.
  final VoidCallback? onScan;

  /// Teachers only.
  final VoidCallback? onOpenTeacher;

  /// The user guide: how everything in Jaguar works.
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([settings, store]),
      builder: (context, _) {
        final basic = settings.isBasic && onOpenTeacher == null;
        final done = settings.doneChallenges;
        final solved = challenges.where((c) => done.contains(c.id)).length;
        final next = challenges.where((c) => !done.contains(c.id)).firstOrNull;
        final recent = store.programs.take(3).toList();

        final challengesCard = _ChallengesCard(
          solved: solved,
          total: challenges.length,
          compact: !basic,
          onTap: () => next == null ? onOpenChallenges() : onContinueChallenge(next),
          onSeeAll: onOpenChallenges,
        );
        final actions = <Widget>[
          _ActionTile(icon: Icons.add, label: 'Nuevo programa', onTap: onNew),
          _ActionTile(
            icon: Icons.folder_open_outlined,
            label: 'Abrir archivo',
            tooltip: 'También abre archivos de otros programas de pseudocódigo',
            onTap: onOpenFile,
          ),
          _ActionTile(icon: Icons.lightbulb_outline, label: 'Ejemplos', onTap: () => _showExamples(context)),
          _ActionTile(
            icon: Icons.menu_book_outlined,
            label: 'Guía: cómo funciona todo',
            onTap: onOpenGuide,
          ),
          _ActionTile(
            icon: onScan == null ? Icons.link : Icons.qr_code_scanner,
            label: onScan == null ? 'Abrir enlace' : 'Escanear QR o abrir enlace',
            onTap: onScan == null ? onOpenLink : () => _scanOrLink(context),
          ),
          _ActionTile(icon: Icons.settings_outlined, label: 'Ajustes', onTap: onOpenSettings),
        ];

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/mascota.png', width: 56, height: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(basic ? '¿Qué quieres hacer?' : 'Inicio', style: theme.textTheme.headlineSmall),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (onOpenTeacher case final openTeacher?) ...[
                  _TeacherCard(onTap: openTeacher),
                  const SizedBox(height: 12),
                ],
                if (basic) ...[challengesCard, const SizedBox(height: 12)],
                // One size for every tile: same width in a grid, same height
                // (growing with the system font size).
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Six tiles: two columns on a phone, three when there is room.
                    final columns = constraints.maxWidth >= 480 ? 3 : 2;
                    final height = 96 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
                    return Column(
                      children: [
                        for (var start = 0; start < actions.length; start += columns)
                          Padding(
                            padding: EdgeInsets.only(top: start == 0 ? 0 : 8),
                            child: SizedBox(
                              height: height,
                              child: Row(
                                children: [
                                  for (var i = start; i < start + columns; i++) ...[
                                    if (i > start) const SizedBox(width: 8),
                                    Expanded(child: i < actions.length ? actions[i] : const SizedBox.shrink()),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (!basic) ...[const SizedBox(height: 12), challengesCard],
                const SizedBox(height: 24),
                Text('Recientes', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                if (recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aún no tienes programas. Empieza con un reto o uno nuevo.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  for (final program in recent)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 8,
                      leading: Icon(program.exerciseId == null ? Icons.description_outlined : Icons.assignment_outlined),
                      title: Text(program.name, overflow: TextOverflow.ellipsis),
                      subtitle: Text(timeAgo(program.updatedAt)),
                      onTap: () => onSelect(program),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExamples(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final (title, source) in examples)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(title),
                onTap: () {
                  Navigator.pop(context);
                  onOpenSource(source);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _scanOrLink(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Escanear QR'),
              onTap: () {
                Navigator.pop(context);
                onScan?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Abrir enlace'),
              onTap: () {
                Navigator.pop(context);
                onOpenLink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengesCard extends StatelessWidget {
  const _ChallengesCard({
    required this.solved,
    required this.total,
    required this.compact,
    required this.onTap,
    required this.onSeeAll,
  });

  final int solved;
  final int total;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = solved >= total ? 'Repetir' : (solved == 0 ? 'Empezar' : 'Continuar');
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: compact ? scheme.surfaceContainerHighest : scheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: compact ? 24 : 32, color: compact ? scheme.primary : scheme.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retos',
                      style: theme.textTheme.titleMedium?.copyWith(color: compact ? null : scheme.onPrimaryContainer),
                    ),
                    Text(
                      'Llevas $solved de $total',
                      style: TextStyle(color: compact ? scheme.onSurfaceVariant : scheme.onPrimaryContainer),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: total == 0 ? 0 : solved / total),
                          duration: motion(context, const Duration(milliseconds: 400)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: onTap, child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(Icons.school_outlined, color: scheme.onPrimaryContainer),
        title: Text('Mis ejercicios', style: TextStyle(color: scheme.onPrimaryContainer)),
        subtitle: Text('Pruebas que se generan solas', style: TextStyle(color: scheme.onPrimaryContainer)),
        trailing: Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
        onTap: onTap,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.tooltip});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tile = Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? tile : Tooltip(message: tooltip, child: tile);
  }
}
