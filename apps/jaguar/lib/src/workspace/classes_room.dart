import 'package:flutter/material.dart';

import '../cloud/account_dialog.dart';
import '../cloud/classes_screen.dart';
import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';

/// Joins a class with its code: signs in first if needed. Used by the room
/// and by its app bar button.
Future<void> joinClassFlow(BuildContext context, Cloud cloud, ExerciseStore exercises) async {
  if (!cloud.signedIn) {
    await showAccountDialog(context, cloud);
    if (!cloud.signedIn || !context.mounted) return;
  }
  final result = await askJoinCode(context);
  if (result == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await cloud.joinClass(code: result.$1, name: result.$2);
    exercises.studentName = result.$2;
  } on CloudException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

/// A teacher creates a class.
Future<void> createClassFlow(BuildContext context, Cloud cloud) async {
  final name = await askNewClassName(context);
  if (name == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await cloud.createClass(name);
  } on CloudException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

class _Entry {
  const _Entry(this.assignment, this.mine);

  final Assignment assignment;
  final Submission? mine;
}

class _ClassView {
  const _ClassView(this.room, this.entries, {required this.owned});

  final ClassRoom room;
  final List<_Entry> entries;

  /// The signed-in person created it: a teacher's class.
  final bool owned;
}

/// The classes of the person signed in, each with its assignments and how far
/// they got: the tasks the teacher asked for, in one place.
class ClassesList extends StatefulWidget {
  const ClassesList({
    super.key,
    required this.cloud,
    required this.onOpenAssignment,
    required this.onOpenClass,
  });

  final Cloud cloud;
  final void Function(Assignment assignment) onOpenAssignment;
  final void Function(ClassRoom room) onOpenClass;

  @override
  State<ClassesList> createState() => _ClassesListState();
}

class _ClassesListState extends State<ClassesList> {
  Future<List<_ClassView>>? _future;
  String? _uid;

  @override
  void initState() {
    super.initState();
    widget.cloud.addListener(_onCloud);
    _start();
  }

  @override
  void dispose() {
    widget.cloud.removeListener(_onCloud);
    super.dispose();
  }

  void _onCloud() {
    // Joining or creating a class, or signing in or out.
    if (mounted) _reload();
  }

  void _start() {
    final user = widget.cloud.user;
    _uid = user?.uid;
    _future = user == null ? null : _load(user);
  }

  void _reload() => setState(_start);

  Future<List<_ClassView>> _load(CloudUser user) async {
    final backend = widget.cloud.backend;
    final views = <_ClassView>[];
    for (final room in await backend.myClasses()) {
      final owned = room.ownerId == user.uid;
      final entries = <_Entry>[];
      for (final assignment in await backend.assignments(room.id)) {
        entries.add(_Entry(assignment, owned ? null : await backend.mySubmission(room.id, assignment.id)));
      }
      views.add(_ClassView(room, entries, owned: owned));
    }
    return views;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cloud = widget.cloud;
    if (!cloud.signedIn) {
      return _Note(
        icon: Icons.cloud_outlined,
        title: 'Tus clases en línea',
        text:
            'Tu profe crea una clase y te da un código. Aquí ves sus tareas y cuánto llevas, sin dar correo ni '
            'teléfono.',
        action: FilledButton(onPressed: () => showAccountDialog(context, cloud), child: const Text('Entrar')),
      );
    }
    if (_uid != cloud.user?.uid) WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    return FutureBuilder<List<_ClassView>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Note(
            icon: Icons.cloud_off,
            title: 'Sin conexión',
            text: '${snapshot.error}',
            action: OutlinedButton(onPressed: _reload, child: const Text('Reintentar')),
          );
        }
        final classes = snapshot.data;
        if (classes == null) {
          return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
        }
        if (classes.isEmpty) {
          return _Note(
            icon: Icons.groups_outlined,
            title: cloud.user!.isTeacher ? 'Aún no tienes clases' : 'Aún no estás en una clase',
            text: cloud.user!.isTeacher
                ? 'Crea una y comparte su código con tu grupo.'
                : 'Pídele el código a tu profe y toca Unirme con código.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final view in classes)
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: scheme.surfaceContainerLow,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => widget.onOpenClass(view.room),
                      child: Container(
                        color: scheme.primaryContainer,
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    view.room.name,
                                    style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
                                  ),
                                  Text(
                                    view.owned
                                        ? 'Tu clase · código ${view.room.code}'
                                        : 'Prof. ${view.room.ownerAlias}',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
                          ],
                        ),
                      ),
                    ),
                    if (view.entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Sin tareas por ahora.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      )
                    else
                      for (final entry in view.entries)
                        _AssignmentRow(
                          entry: entry,
                          owned: view.owned,
                          onTap: () => view.owned ? widget.onOpenClass(view.room) : widget.onOpenAssignment(entry.assignment),
                        ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({required this.entry, required this.owned, required this.onTap});

  final _Entry entry;
  final bool owned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = entry.mine;
    final (Widget marker, String status) = owned
        ? (Icon(Icons.assignment_outlined, size: 20, color: scheme.onSurfaceVariant), 'Ver entregas')
        : mine == null
        ? (Icon(Icons.radio_button_unchecked, size: 20, color: scheme.outline, semanticLabel: 'sin empezar'), 'Sin empezar')
        : mine.complete
        ? (
            Icon(Icons.check, size: 20, color: Colors.green.shade700, semanticLabel: 'entregada'),
            'Entregada · ${mine.passed} de ${mine.total} pruebas',
          )
        : (
            Icon(Icons.circle, size: 14, color: scheme.primary, semanticLabel: 'en proceso'),
            '${mine.passed} de ${mine.total} pruebas',
          );
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 24, child: Center(child: marker)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.assignment.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                    Text(status, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (!owned && (mine == null || !mine.complete))
                Text(
                  mine == null ? 'Empezar' : 'Seguir',
                  style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.title, required this.text, this.action});

  final IconData icon;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
