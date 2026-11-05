import 'package:flutter/material.dart';

import '../cloud/account_dialog.dart';
import '../cloud/classes_screen.dart';
import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../exercises/delivery_card.dart' show deliveryDate;
import '../widgets/pro_widgets.dart';
import '../widgets/skeleton.dart';

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

/// The classes of the person signed in, each with its tasks and, for a
/// student, how each one stands. It shows the copy kept on the device right
/// away, so it works with no internet, and refreshes it in the background.
class ClassesList extends StatefulWidget {
  const ClassesList({
    super.key,
    required this.cloud,
    required this.onOpenAssignment,
    required this.onOpenClass,
    this.forTeacher = false,
  });

  final Cloud cloud;

  /// The person is in teacher mode: what they see before signing in talks
  /// about creating classes, not about joining one.
  final bool forTeacher;
  final void Function(Assignment assignment) onOpenAssignment;
  final void Function(ClassRoom room) onOpenClass;

  @override
  State<ClassesList> createState() => _ClassesListState();
}

class _ClassesListState extends State<ClassesList> {
  String? _uid;
  int _revision = -1;
  bool _syncing = false;
  bool _offline = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.cloud.addListener(_onCloud);
    _onCloud();
  }

  @override
  void dispose() {
    widget.cloud.removeListener(_onCloud);
    super.dispose();
  }

  void _onCloud() {
    final cloud = widget.cloud;
    // A task changing state only repaints; signing in or out, creating or
    // joining a class reads the classes again.
    if (cloud.revision == _revision && cloud.user?.uid == _uid) {
      if (mounted) setState(() {});
      return;
    }
    _revision = cloud.revision;
    _uid = cloud.user?.uid;
    if (cloud.user != null) _sync();
    if (mounted) setState(() {});
  }

  Future<void> _sync() async {
    if (_syncing) return;
    _syncing = true;
    if (mounted) setState(() => _error = null);
    try {
      final online = await widget.cloud.syncClasses();
      if (mounted) setState(() => _offline = !online);
    } on CloudException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      _syncing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cloud = widget.cloud;
    final user = cloud.user;
    if (user == null) {
      return _Note(
        icon: widget.forTeacher ? Icons.school_outlined : Icons.cloud_outlined,
        title: widget.forTeacher ? 'Entra para crear tus clases' : 'Tus clases en línea',
        text: widget.forTeacher
            ? 'Con tu correo, tus clases y ejercicios te siguen a cualquier equipo. Tus alumnos entran con un '
                  'código, sin dar correo ni teléfono.'
            : 'Tu profe crea una clase y te da un código. Aquí ves sus tareas y cuánto llevas, sin dar correo ni '
                  'teléfono.',
        action: FilledButton(onPressed: () => showAccountDialog(context, cloud), child: const Text('Entrar')),
      );
    }
    final classes = cloud.tasks.cachedClasses(user.uid);
    if (classes == null) {
      if (_error != null) {
        return _Note(
          icon: Icons.cloud_off,
          title: 'No se pudieron cargar tus clases',
          text: _error!,
          action: OutlinedButton(onPressed: _sync, child: const Text('Reintentar')),
        );
      }
      // Nothing kept yet, and without internet there is nothing to show.
      if (!_syncing && _offline) {
        return _Note(
          icon: Icons.cloud_off,
          title: 'Sin conexión',
          text: 'La primera vez hace falta internet para traer tus clases. Después las verás aquí aunque no haya.',
          action: OutlinedButton(onPressed: _sync, child: const Text('Reintentar')),
        );
      }
      return const SkeletonClassList();
    }
    if (classes.isEmpty) {
      return _Note(
        icon: Icons.groups_outlined,
        title: user.isTeacher ? 'Aún no tienes clases' : 'Aún no estás en una clase',
        text: user.isTeacher
            ? 'Crea una y comparte su código con tu grupo.'
            : 'Pídele el código a tu profe y toca Unirme con código.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_offline)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: NoticeBox(
              icon: Icons.cloud_off,
              text:
                  'Sin conexión. Estás viendo lo último que se guardó. Puedes trabajar tus tareas y entregarlas '
                  'cuando tengas internet.',
            ),
          ),
        for (final c in classes)
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
                if (c.room.ownerId == user.uid)
                  _OwnedHeader(room: c.room, tasks: c.assignments.length, onTap: () => widget.onOpenClass(c.room))
                else
                  InkWell(
                    onTap: () => widget.onOpenClass(c.room),
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
                                  c.room.name,
                                  style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
                                ),
                                Text(
                                  'Prof. ${c.room.ownerAlias}',
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
                if (c.assignments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Sin tareas por ahora.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  for (final a in c.assignments)
                    c.room.ownerId == user.uid
                        ? _TeacherTaskRow(assignment: a, onTap: () => widget.onOpenClass(c.room))
                        : TaskRow(
                            assignment: a,
                            record: cloud.tasks.forAssignment(c.room.id, a.id),
                            onTap: () => widget.onOpenAssignment(a),
                          ),
                const SizedBox(height: 4),
              ],
            ),
          ),
      ],
    );
  }
}

/// A task as the teacher's list shows it: open the class to see the deliveries.
class _TeacherTaskRow extends StatelessWidget {
  const _TeacherTaskRow({required this.assignment, required this.onTap});

  final Assignment assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.assignment_outlined, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assignment.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                    Text('Ver entregas', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A task of the student's class: what it is, where it stands, and what to do.
class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.assignment, required this.record, required this.onTap});

  final Assignment assignment;
  final TaskRecord? record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = record?.state ?? TaskState.todo;
    final started = record?.passed != null;
    final marker = switch (state) {
      TaskState.todo => Icon(
        Icons.radio_button_unchecked,
        size: 22,
        color: scheme.outline,
        semanticLabel: 'sin entregar',
      ),
      TaskState.delivered => Icon(
        Icons.check_circle,
        size: 22,
        color: Colors.green.shade600,
        semanticLabel: 'entregada',
      ),
      TaskState.changed => Icon(Icons.edit_outlined, size: 22, color: scheme.tertiary, semanticLabel: 'con cambios'),
    };
    final detail = switch (state) {
      TaskState.todo => started ? 'Por entregar · última prueba ${record!.passed} de ${record!.total}' : 'Por hacer',
      TaskState.delivered =>
        'Entregada${record?.deliveredAt == null ? '' : ' · ${deliveryDate(record!.deliveredAt!)}'}'
            '${record?.deliveredPassed == null ? '' : ' · ${record!.deliveredPassed} de ${record!.deliveredTotal} pruebas'}',
      TaskState.changed => 'Cambiaste tu programa después de entregar',
    };
    final action = switch (state) {
      TaskState.todo => started ? 'Seguir' : 'Empezar',
      TaskState.delivered => null,
      TaskState.changed => 'Entregar',
    };
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
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
                    Text(assignment.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                    Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (action != null) Text(action, style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary)),
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

/// The top of a teacher's class: name, state, how many tasks, and the code
/// ready to read out or copy.
class _OwnedHeader extends StatelessWidget {
  const _OwnedHeader({required this.room, required this.tasks, required this.onTap});

  final ClassRoom room;
  final int tasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.groups_2_outlined, color: scheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          tasks == 0 ? 'Sin tareas todavía' : (tasks == 1 ? '1 tarea' : '$tasks tareas'),
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: room.open ? 'Abierta' : 'Cerrada',
                    tone: room.open ? PillTone.good : PillTone.neutral,
                    icon: room.open ? Icons.lock_open_outlined : Icons.lock_outline,
                  ),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: CodeBadge(code: room.code, large: false),
          ),
        ],
      ),
    );
  }
}
