import 'package:flutter/material.dart';

import '../challenges/challenges.dart';
import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../programs/program_store.dart';
import '../settings.dart';

/// The side menu on phones: where to start, then the person's programs, and
/// what is used less often folded under "Más".
class ProgramsDrawer extends StatelessWidget {
  const ProgramsDrawer({
    super.key,
    required this.store,
    required this.exercises,
    required this.settings,
    required this.onSelect,
    required this.onNew,
    required this.onHome,
    required this.onSettings,
    this.onScan,
    required this.cloud,
    required this.onOpenCommunity,
    required this.onOpenChallenges,
    required this.onOpenClasses,
    required this.onAccount,
    required this.onGuide,
    required this.onAbout,
    this.onOpenTeacher,
  });

  final ProgramStore store;
  final ExerciseStore exercises;
  final ViewSettings settings;
  final ValueChanged<SavedProgram> onSelect;
  final VoidCallback onNew;
  final VoidCallback onHome;
  final VoidCallback onSettings;

  /// Opens the camera to read an exercise's QR (phone apps, Completo mode).
  final VoidCallback? onScan;
  final Cloud? cloud;
  final VoidCallback onOpenCommunity;
  final VoidCallback onOpenChallenges;
  final VoidCallback onOpenClasses;
  final VoidCallback onAccount;
  final VoidCallback onGuide;
  final VoidCallback onAbout;

  /// Teachers only.
  final VoidCallback? onOpenTeacher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Closes the menu, then does [action].
    VoidCallback close(VoidCallback action) => () {
      Navigator.pop(context);
      action();
    };
    return Drawer(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([store, exercises, settings, ?cloud]),
          builder: (context, _) {
            final programs = store.programs;
            final solved = challenges.where((c) => settings.doneChallenges.contains(c.id)).length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Image.asset('assets/images/mascota.png', width: 48, height: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jaguar', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                            Text('Tus programas en este dispositivo', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Inicio'), onTap: close(onHome)),
                if (onOpenTeacher case final openTeacher?)
                  ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: const Text('Mis ejercicios'),
                    subtitle: const Text('Pruebas que se generan solas'),
                    onTap: close(openTeacher),
                  ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Retos'),
                  subtitle: Text('Llevas $solved de ${challenges.length}'),
                  tileColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  onTap: close(onOpenChallenges),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Guía'),
                  subtitle: const Text('Cómo funciona todo, paso a paso'),
                  tileColor: settings.isBasic ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5) : null,
                  onTap: close(onGuide),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: FilledButton.tonalIcon(
                    onPressed: close(onNew),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo programa'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text('Mis programas', style: theme.textTheme.labelLarge),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final program in programs)
                        ListTile(
                          leading: Icon(
                            program.exerciseId == null ? Icons.description_outlined : Icons.assignment_outlined,
                          ),
                          title: Text(program.name, overflow: TextOverflow.ellipsis),
                          subtitle: Text(timeAgo(program.updatedAt)),
                          selected: identical(program, store.current),
                          onTap: () {
                            Navigator.pop(context);
                            onSelect(program);
                          },
                          trailing: IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => confirmDeleteProgram(context, store, program, onSelect),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Ajustes'),
                  onTap: close(onSettings),
                ),
                ExpansionTile(
                  leading: const Icon(Icons.more_horiz),
                  title: const Text('Más'),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  initiallyExpanded: !settings.isBasic && !settings.firstRunDone,
                  children: [
                    if (onScan case final scan?)
                      ListTile(
                        leading: const Icon(Icons.qr_code_scanner),
                        title: const Text('Escanear QR del ejercicio'),
                        onTap: close(scan),
                      ),
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: const Text('Comunidad'),
                      subtitle: const Text('Programas, ejercicios y ejemplos'),
                      onTap: close(onOpenCommunity),
                    ),
                    if (cloud != null) ...[
                      ListTile(
                        leading: const Icon(Icons.groups_outlined),
                        title: const Text('Mis clases'),
                        onTap: close(onOpenClasses),
                      ),
                      ListTile(
                        leading: Icon(cloud!.signedIn ? Icons.account_circle : Icons.login),
                        title: Text(cloud!.user?.alias ?? 'Entrar en línea'),
                        onTap: close(onAccount),
                      ),
                    ],
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Acerca de'),
                      onTap: close(onAbout),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Asks before deleting [program] (not when it is still blank) and offers
/// Deshacer afterwards. [onSelect] receives the program shown instead, or the
/// blank stand-in when it was the last one and the start panel takes over.
Future<void> confirmDeleteProgram(
  BuildContext context,
  ProgramStore store,
  SavedProgram program,
  ValueChanged<SavedProgram> onSelect,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final scaffold = Scaffold.maybeOf(context);
  if (!ProgramStore.isBlank(program)) {
    final only = store.programs.length == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar "${program.name}"?'),
        content: Text(
          only
              ? 'Es tu único programa. Después verás el inicio para empezar otro. Las copias guardadas no cambian.'
              : 'Se borra de este dispositivo. Las copias que compartiste o guardaste como archivo no cambian.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
  }
  final wasCurrent = identical(program, store.current);
  store.delete(program);
  if (wasCurrent) onSelect(store.current);
  // With nothing left the start panel is the answer: show it.
  if (store.isEmpty) scaffold?.closeDrawer();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: const Text('Programa eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            store.restore(program);
            onSelect(program);
          },
        ),
      ),
    );
}

String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'hace un momento';
  if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'hace ${diff.inHours} h';
  if (diff.inDays == 1) return 'ayer';
  if (diff.inDays < 30) return 'hace ${diff.inDays} días';
  return '${time.day}/${time.month}/${time.year}';
}
