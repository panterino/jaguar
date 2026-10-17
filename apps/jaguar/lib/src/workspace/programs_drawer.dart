import 'package:flutter/material.dart';

import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../programs/program_store.dart';

class ProgramsDrawer extends StatelessWidget {
  const ProgramsDrawer({
    super.key,
    required this.store,
    required this.exercises,
    required this.onSelect,
    required this.onNew,
    required this.cloud,
    required this.onOpenCommunity,
    required this.onOpenClasses,
    required this.onAccount,
    required this.onGuide,
    required this.onAbout,
    required this.onOpenTeacher,
    required this.onChangeName,
    required this.modeSwitch,
  });

  final Widget modeSwitch;

  final ProgramStore store;
  final ExerciseStore exercises;
  final ValueChanged<SavedProgram> onSelect;
  final VoidCallback onNew;
  final Cloud? cloud;
  final VoidCallback onOpenCommunity;
  final VoidCallback onOpenClasses;
  final VoidCallback onAccount;
  final VoidCallback onGuide;
  final VoidCallback onAbout;
  final VoidCallback onOpenTeacher;
  final VoidCallback onChangeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([store, exercises, ?cloud]),
          builder: (context, _) {
            final programs = store.programs;
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
                Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 4), child: modeSwitch),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.pop(context);
                      onNew();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo programa'),
                  ),
                ),
                const Divider(),
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
                  leading: const Icon(Icons.public),
                  title: const Text('Comunidad'),
                  subtitle: const Text('Programas, ejercicios y ejemplos'),
                  onTap: () {
                    Navigator.pop(context);
                    onOpenCommunity();
                  },
                ),
                if (cloud != null) ...[
                  ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: const Text('Mis clases'),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenClasses();
                    },
                  ),
                  ListTile(
                    leading: Icon(cloud!.signedIn ? Icons.account_circle : Icons.login),
                    title: Text(cloud!.user?.alias ?? 'Entrar en línea'),
                    onTap: () {
                      Navigator.pop(context);
                      onAccount();
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(exercises.studentName ?? 'Escribe tu nombre'),
                  subtitle: const Text('Aparece al mostrar un ejercicio al profesor'),
                  onTap: () {
                    Navigator.pop(context);
                    onChangeName();
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onGuide();
                        },
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Guía'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onAbout();
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Acerca de'),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Mis ejercicios'),
                  subtitle: const Text('Profesor: pruebas que se generan solas'),
                  onTap: () {
                    Navigator.pop(context);
                    onOpenTeacher();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Asks before deleting [program]; [onSelect] receives the program shown
/// instead when it was the current one.
Future<void> confirmDeleteProgram(
  BuildContext context,
  ProgramStore store,
  SavedProgram program,
  ValueChanged<SavedProgram> onSelect,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('¿Eliminar "${program.name}"?'),
      content: const Text(
        'Se borrará de este dispositivo. Si lo compartiste o guardaste como .psc, esas copias no cambian.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
      ],
    ),
  );
  if (confirmed ?? false) {
    final wasCurrent = identical(program, store.current);
    store.delete(program);
    if (wasCurrent) onSelect(store.current);
  }
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
