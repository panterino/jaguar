import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../exercises/exercise_store.dart';
import '../theme.dart';
import 'account_dialog.dart';
import 'cloud.dart';
import 'regrade.dart';
import '../widgets/page_width.dart';

/// Same breakpoint as the rooms: from here the classes use the width.
const _wideWidth = 900.0;

bool _isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= _wideWidth;

/// Asks for the class code and the student's name; null if cancelled.
Future<(String, String)?> askJoinCode(BuildContext context) =>
    showDialog<(String, String)>(context: context, builder: (_) => const _JoinDialog());

/// Asks for the name of a new class; null if cancelled.
Future<String?> askNewClassName(BuildContext context) =>
    _askText(context, title: 'Nueva clase', label: 'Nombre de la clase', hint: '1° A · Lógica');

/// My classes: the teacher creates them; students join with a code.
class ClassesScreen extends StatefulWidget {
  const ClassesScreen({
    super.key,
    required this.cloud,
    required this.exercises,
    required this.onOpenAssignment,
    required this.onOpenSource,
  });

  final Cloud cloud;
  final ExerciseStore exercises;

  /// A student opens an assignment to solve it.
  final void Function(Assignment assignment) onOpenAssignment;

  /// The teacher opens a copy of a student's work.
  final ValueChanged<String> onOpenSource;

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  Future<List<ClassRoom>>? _classes;

  Cloud get _cloud => widget.cloud;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final classes = _cloud.signedIn ? _cloud.backend.myClasses() : null;
    setState(() {
      _classes = classes;
    });
  }

  Future<void> _signIn() async {
    await showAccountDialog(context, _cloud);
    _reload();
  }

  Future<void> _create() async {
    final name = await _askText(context, title: 'Nueva clase', label: 'Nombre de la clase', hint: '1° A · Lógica');
    if (name == null) return;
    try {
      final room = await _cloud.createClass(name);
      _reload();
      if (mounted) _open(room);
    } on CloudException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> _join() async {
    final result = await showDialog<(String, String)>(context: context, builder: (_) => const _JoinDialog());
    if (result == null) return;
    try {
      final room = await _cloud.joinClass(code: result.$1, name: result.$2);
      widget.exercises.studentName = result.$2;
      _reload();
      if (mounted) _open(room);
    } on CloudException catch (e) {
      _toast(e.message);
    }
  }

  void _open(ClassRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ClassScreen(
          cloud: _cloud,
          room: room,
          exercises: widget.exercises,
          onOpenAssignment: widget.onOpenAssignment,
          onOpenSource: widget.onOpenSource,
        ),
      ),
    );
  }

  void _toast(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _cloud.user;
    final theme = Theme.of(context);
    final wide = _isWide(context);
    final actionLabel = user == null
        ? null
        : user.isTeacher
        ? 'Crear clase'
        : 'Unirme con un código';
    final actionIcon = user?.isTeacher ?? false ? Icons.add : Icons.group_add_outlined;
    final action = user?.isTeacher ?? false ? _create : _join;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases'),
        actions: [IconButton(tooltip: 'Actualizar', icon: const Icon(Icons.refresh), onPressed: _reload)],
      ),
      // On a computer the button sits at the top of the list, near the eyes.
      floatingActionButton: user == null || wide
          ? null
          : FloatingActionButton.extended(onPressed: action, icon: Icon(actionIcon), label: Text(actionLabel!)),
      body: user == null
          ? _Empty(
              icon: Icons.cloud_outlined,
              title: 'Clases en línea',
              text:
                  'Los profesores crean una clase y le dan el código a su grupo. '
                  'Las tareas y los resultados de Probar llegan solos.',
              action: FilledButton(onPressed: _signIn, child: const Text('Entrar')),
            )
          : FutureBuilder(
              future: _classes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _Empty(icon: Icons.cloud_off, title: 'Sin conexión', text: '${snapshot.error}');
                }
                final classes = snapshot.data;
                if (classes == null) return const Center(child: CircularProgressIndicator());
                if (classes.isEmpty) {
                  return _Empty(
                    icon: Icons.groups_outlined,
                    title: user.isTeacher ? 'Aún no tienes clases' : 'Aún no estás en ninguna clase',
                    text: user.isTeacher
                        ? 'Crea una clase y comparte su código con tu grupo.'
                        : 'Pídele a tu profesor el código de la clase (como JAG-4K7Q).',
                    action: wide
                        ? FilledButton.icon(onPressed: action, icon: Icon(actionIcon), label: Text(actionLabel!))
                        : null,
                  );
                }
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: pageWidth),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(12, wide ? 8 : 12, 12, 96),
                      children: [
                        if (wide)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: action,
                                icon: Icon(actionIcon),
                                label: Text(actionLabel!),
                              ),
                            ),
                          ),
                        for (final room in classes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  room.ownerId == user.uid ? Icons.school_outlined : Icons.backpack_outlined,
                                ),
                                title: Text(room.name, style: theme.textTheme.titleMedium),
                                subtitle: Text(
                                  room.ownerId == user.uid ? 'Código ${room.code}' : 'Con ${room.ownerAlias}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _open(room),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// A class: the teacher's dashboard, or the student's list of assignments.
class ClassScreen extends StatefulWidget {
  const ClassScreen({
    super.key,
    required this.cloud,
    required this.room,
    required this.exercises,
    required this.onOpenAssignment,
    required this.onOpenSource,
  });

  final Cloud cloud;
  final ClassRoom room;
  final ExerciseStore exercises;
  final void Function(Assignment assignment) onOpenAssignment;
  final ValueChanged<String> onOpenSource;

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  List<Assignment>? _assignments;
  List<Member> _members = const [];

  /// assignmentId → student uid → submission (teacher), or my own.
  Map<String, Map<String, Submission>> _submissions = const {};
  String? _error;
  Timer? _refresh;
  late bool _open = widget.room.open;

  /// What each student claimed, for the entries the teacher's check changed:
  /// `assignmentId/uid` → "3 de 3". The numbers on screen are the checked ones.
  Map<String, String> _claimed = const {};

  /// Checked results, kept while the program stays the same, so the 20-second
  /// refresh does not run every program again.
  final Map<String, ({String source, int passed, int total, int? stamp})> _checked = {};

  CloudBackend get _backend => widget.cloud.backend;
  bool get _isTeacher => widget.room.ownerId == widget.cloud.user?.uid;

  @override
  void initState() {
    super.initState();
    _load();
    // The dashboard fills up while the class works.
    if (_isTeacher) _refresh = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final assignments = await _backend.assignments(widget.room.id);
      final members = _isTeacher ? await _backend.members(widget.room.id) : const <Member>[];
      final submissions = <String, Map<String, Submission>>{};
      final claimed = <String, String>{};
      for (final a in assignments) {
        if (_isTeacher) {
          submissions[a.id] = await _regradeAll(a, await _backend.submissions(widget.room.id, a.id), claimed);
        } else {
          final mine = await _backend.mySubmission(widget.room.id, a.id);
          submissions[a.id] = {if (mine case final Submission s) s.uid: s};
        }
      }
      if (!mounted) return;
      setState(() {
        _assignments = assignments;
        _members = members;
        _submissions = submissions;
        _claimed = claimed;
        _error = null;
      });
    } on CloudException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  /// A student writes the number of tests they passed, so it is not believed:
  /// the program runs again here against every test, hidden ones included.
  Future<Map<String, Submission>> _regradeAll(
    Assignment assignment,
    Map<String, Submission> sent,
    Map<String, String> claimed,
  ) async {
    final result = <String, Submission>{};
    for (final entry in sent.entries) {
      final s = entry.value;
      final key = '${assignment.id}/${entry.key}';
      final stamp = s.updatedAt?.millisecondsSinceEpoch;
      var known = _checked[key];
      if (known == null || known.source != s.source || known.stamp != stamp) {
        final graded = await regrade(assignment, s);
        known = (source: s.source, passed: graded.passed, total: graded.total, stamp: stamp);
        _checked[key] = known;
      }
      if (known.passed != s.passed || known.total != s.total) claimed[key] = '${s.passed} de ${s.total}';
      result[entry.key] = Submission(
        uid: s.uid,
        name: s.name,
        source: s.source,
        passed: known.passed,
        total: known.total,
        updatedAt: s.updatedAt,
        pastedLines: s.pastedLines,
      );
    }
    return result;
  }

  Future<void> _setOpen(bool open) async {
    final before = _open;
    setState(() => _open = open);
    try {
      await _backend.setClassOpen(widget.room.id, open: open);
    } on CloudException catch (e) {
      if (!mounted) return;
      setState(() => _open = before);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// A dialog on a computer, a bottom sheet on a phone.
  Future<Exercise?> _pickExercise() {
    if (_isWide(context)) {
      return showDialog<Exercise>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
            child: _ExercisePicker(exercises: widget.exercises.authored, cloud: widget.cloud, inDialog: true),
          ),
        ),
      );
    }
    return showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ExercisePicker(exercises: widget.exercises.authored, cloud: widget.cloud),
    );
  }

  Future<void> _assign() async {
    final exercise = await _pickExercise();
    if (exercise == null) return;
    try {
      await _backend.assign(widget.room.id, exercise);
      await _load();
    } on CloudException catch (e) {
      _toast(e.message);
    }
  }

  /// Removing a task also removes what the students delivered, so it asks.
  Future<void> _removeAssignment(Assignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Quitar "${assignment.title}"?'),
        content: const Text('Tus alumnos dejarán de verla y se pierden sus entregas de esta tarea.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitar')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _backend.removeAssignment(widget.room.id, assignment.id);
      await _load();
    } on CloudException catch (e) {
      _toast(e.message);
    }
  }

  void _toast(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openAssignment(Assignment assignment) {
    widget.cloud.linkAssignment(assignment.exercise, assignment);
    Navigator.popUntil(context, (route) => route.isFirst);
    widget.onOpenAssignment(assignment);
  }

  Future<void> _showSubmission(Submission submission, Assignment assignment) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${submission.name} · ${assignment.title}'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${submission.passed} de ${submission.total} pruebas'
                '${submission.updatedAt == null ? '' : ' · ${_time(submission.updatedAt!)}'}',
              ),
              if (_claimed['${assignment.id}/${submission.uid}'] case final String said) ...[
                const SizedBox(height: 8),
                Text(
                  'El alumno dijo $said; al revisar su programa contra todas las pruebas salió esto.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (submission.pastedLines > 0) ...[
                const SizedBox(height: 8),
                _PastedNote(lines: submission.pastedLines),
              ],
              const SizedBox(height: 8),
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(submission.source, style: monoStyle.copyWith(fontSize: 13, letterSpacing: 0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              widget.onOpenSource('// Entrega de ${submission.name}: ${assignment.title}\n${submission.source}');
            },
            child: const Text('Abrir una copia'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _assignments;
    final wide = _isWide(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        actions: [IconButton(tooltip: 'Actualizar', icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: _isTeacher && !wide
          ? FloatingActionButton.extended(
              onPressed: _assign,
              icon: const Icon(Icons.assignment_add),
              label: const Text('Asignar ejercicio'),
            )
          : null,
      body: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.maybePop(context)},
        child: Focus(
          autofocus: true,
          child: _error != null
              ? _Empty(icon: Icons.cloud_off, title: 'No se pudo cargar', text: _error!)
              : assignments == null
              ? const Center(child: CircularProgressIndicator())
              : _isTeacher && wide
              ? PageWidth(width: workWidth, child: _teacherWide(assignments))
              : _list(assignments, wide),
        ),
      ),
    );
  }

  /// The phone layout, and the student's on any screen: one column.
  Widget _list(List<Assignment> assignments, bool wide) {
    final theme = Theme.of(context);
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (_isTeacher)
          _CodeCard(code: widget.room.code, students: _members.length, open: _open, onOpenChanged: _setOpen),
        const SizedBox(height: 16),
        Text('Tareas', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (assignments.isEmpty)
          Text(
            _isTeacher
                ? 'Asigna un ejercicio: tus alumnos lo verán aquí y sus resultados te llegarán solos.'
                : 'Tu profesor aún no asigna tareas.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        if (_isTeacher && assignments.isNotEmpty)
          _ProgressTable(
            assignments: assignments,
            members: _members,
            submissions: _submissions,
            onTap: _showSubmission,
            onRemove: _removeAssignment,
          ),
        if (!_isTeacher)
          for (final a in assignments)
            Card(
              child: ListTile(
                leading: _StatusIcon(submission: _submissions[a.id]?.values.firstOrNull),
                title: Text(a.title),
                subtitle: Text(
                  '${switch (_submissions[a.id]?.values.firstOrNull) {
                    null => 'Sin entregar',
                    final s when s.complete => 'Completa: ${s.passed} de ${s.total} pruebas',
                    final s => '${s.passed} de ${s.total} pruebas',
                  }}'
                  '${a.hiddenCount == 0
                      ? ''
                      : a.hiddenCount == 1
                      ? '. Tu profe revisa 1 prueba más que no se ve.'
                      : '. Tu profe revisa ${a.hiddenCount} pruebas más que no se ven.'}',
                ),
                trailing: FilledButton.tonal(onPressed: () => _openAssignment(a), child: const Text('Resolver')),
              ),
            ),
      ],
    );
    if (!wide) return list;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: pageWidth),
        child: list,
      ),
    );
  }

  /// How many students finished [assignment] (every test passed).
  int _completed(Assignment assignment) => [
    for (final m in _members)
      if (_submissions[assignment.id]?[m.uid]?.complete ?? false) m,
  ].length;

  /// The teacher on a computer: the class and its tasks on the left, and
  /// the deliveries table taking the rest of the width and height.
  Widget _teacherWide(List<Assignment> assignments) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final Widget right = assignments.isEmpty
        ? _Empty(
            icon: Icons.assignment_outlined,
            title: 'Aún no hay tareas',
            text: 'Asigna un ejercicio: tus alumnos lo verán en su clase y sus resultados te llegarán solos.',
            action: FilledButton.icon(
              onPressed: _assign,
              icon: const Icon(Icons.assignment_add),
              label: const Text('Asignar ejercicio'),
            ),
          )
        : _members.isEmpty
        ? const _Empty(
            icon: Icons.group_outlined,
            title: 'Aún no hay alumnos',
            text: 'Cuando tus alumnos se unan con el código, aquí verás su avance en cada tarea.',
          )
        : _ProgressGrid(
            assignments: assignments,
            members: _members,
            submissions: _submissions,
            completed: _completed,
            onTap: _showSubmission,
          );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 340,
          child: FocusTraversalGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _CodeCard(code: widget.room.code, students: _members.length, open: _open, onOpenChanged: _setOpen),
                const SizedBox(height: 12),
                Tooltip(
                  message: 'Elige uno de tus ejercicios o uno del banco',
                  child: FilledButton.icon(
                    onPressed: _assign,
                    icon: const Icon(Icons.assignment_add),
                    label: const Text('Asignar ejercicio'),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Tareas', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                if (assignments.isEmpty)
                  Text(
                    'Todavía no hay tareas en esta clase.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                for (final a in assignments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${_completed(a)} de ${_members.length} completas'),
                    trailing: IconButton(
                      tooltip: 'Quitar tarea',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeAssignment(a),
                    ),
                  ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, color: scheme.outlineVariant),
        Expanded(
          child: FocusTraversalGroup(
            child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: right),
          ),
        ),
      ],
    );
  }
}

String _time(DateTime time) {
  final local = time.toLocal();
  return '${local.day}/${local.month} ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.students, required this.open, required this.onOpenChanged});

  final String code;
  final int students;
  final bool open;
  final ValueChanged<bool> onOpenChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Código para unirse', style: theme.textTheme.labelLarge),
                  SelectableText(
                    code,
                    style: monoStyle.copyWith(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: 2),
                  ),
                  Text(students == 1 ? '1 alumno' : '$students alumnos', style: theme.textTheme.bodySmall),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(value: open, onChanged: onOpenChanged),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          open ? 'Recibe alumnos nuevos' : 'Cerrada a alumnos nuevos',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copiar código',
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Students × assignments: ✓, 2/3 or — in each cell.
class _ProgressTable extends StatelessWidget {
  const _ProgressTable({
    required this.assignments,
    required this.members,
    required this.submissions,
    required this.onTap,
    required this.onRemove,
  });

  final List<Assignment> assignments;
  final List<Member> members;
  final Map<String, Map<String, Submission>> submissions;
  final void Function(Submission, Assignment) onTap;
  final ValueChanged<Assignment> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (members.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in assignments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.assignment_outlined),
              title: Text(a.title),
              trailing: IconButton(
                tooltip: 'Quitar tarea',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onRemove(a),
              ),
            ),
          const SizedBox(height: 8),
          Text('Cuando tus alumnos se unan con el código, aquí verás su avance.', style: theme.textTheme.bodySmall),
        ],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Alumno')),
          for (final a in assignments)
            DataColumn(
              label: Tooltip(
                message: a.title,
                child: SizedBox(width: 110, child: Text(a.title, overflow: TextOverflow.ellipsis)),
              ),
            ),
        ],
        rows: [
          for (final m in members)
            DataRow(
              cells: [
                DataCell(Text(m.name)),
                for (final a in assignments)
                  switch (submissions[a.id]?[m.uid]) {
                    null => const DataCell(Text('—')),
                    final s => DataCell(
                      Row(
                        children: [
                          _StatusIcon(submission: s),
                          const SizedBox(width: 6),
                          Text('${s.passed}/${s.total}'),
                          if (s.pastedLines > 0) ...[
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Pegó ${s.pastedLines} líneas de una vez',
                              child: Icon(Icons.content_paste, size: 16, color: Theme.of(context).colorScheme.tertiary),
                            ),
                          ],
                        ],
                      ),
                      onTap: () => onTap(s, a),
                    ),
                  },
              ],
            ),
        ],
      ),
    );
  }
}

/// Students x assignments for a computer: the header stays in place while
/// the rows scroll, the name column is wide, and the table scrolls sideways
/// only when there are more tasks than room.
class _ProgressGrid extends StatelessWidget {
  const _ProgressGrid({
    required this.assignments,
    required this.members,
    required this.submissions,
    required this.completed,
    required this.onTap,
  });

  final List<Assignment> assignments;
  final List<Member> members;
  final Map<String, Map<String, Submission>> submissions;
  final int Function(Assignment) completed;
  final void Function(Submission, Assignment) onTap;

  static const _nameWidth = 220.0;
  static const _taskWidth = 190.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final natural = _nameWidth + assignments.length * _taskWidth;
          final width = natural > constraints.maxWidth ? natural : constraints.maxWidth;
          // The task columns share what the name column leaves, so a few
          // tasks do not leave an empty strip on the right.
          final taskWidth = (width - _nameWidth) / assignments.length;
          final grid = SizedBox(
            width: width,
            child: Column(
              children: [
                _row(
                  context,
                  header: true,
                  name: Text('Alumno', style: _head(context)),
                  cells: [
                    for (final a in assignments)
                      Tooltip(
                        message: a.title,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: _head(context)),
                            Text(
                              '${completed(a)} de ${members.length} completas',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                  ],
                  taskWidth: taskWidth,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, i) {
                      final m = members[i];
                      return _row(
                        context,
                        shaded: i.isOdd,
                        name: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        cells: [for (final a in assignments) _cell(context, m, a)],
                        taskWidth: taskWidth,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
          return natural > constraints.maxWidth
              ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: grid)
              : grid;
        },
      ),
    );
  }

  TextStyle? _head(BuildContext context) => Theme.of(context).textTheme.labelLarge;

  Widget _row(
    BuildContext context, {
    required Widget name,
    required List<Widget> cells,
    required double taskWidth,
    bool header = false,
    bool shaded = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: header
            ? scheme.surfaceContainerHigh
            : shaded
            ? scheme.surfaceContainerLow
            : null,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _nameWidth,
            constraints: const BoxConstraints(minHeight: 52),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: name,
          ),
          for (final cell in cells)
            Container(
              width: taskWidth,
              constraints: const BoxConstraints(minHeight: 52),
              alignment: Alignment.centerLeft,
              padding: header ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : EdgeInsets.zero,
              child: cell,
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, Member member, Assignment assignment) {
    final scheme = Theme.of(context).colorScheme;
    final s = submissions[assignment.id]?[member.uid];
    if (s == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Semantics(
          label: '${member.name}, ${assignment.title}: sin entregar',
          child: Text('Sin entregar', style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      );
    }
    return Semantics(
      button: true,
      label: '${member.name}, ${assignment.title}: ${s.passed} de ${s.total} pruebas. Abre la entrega.',
      excludeSemantics: true,
      child: Tooltip(
        message: 'Ver la entrega de ${member.name}',
        child: InkWell(
          onTap: () => onTap(s, assignment),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _StatusIcon(submission: s),
                const SizedBox(width: 8),
                Flexible(child: Text('${s.passed} de ${s.total}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (s.pastedLines > 0) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Pegó ${s.pastedLines} líneas de una vez',
                    child: Icon(Icons.content_paste, size: 16, color: scheme.tertiary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.submission});

  final Submission? submission;

  @override
  Widget build(BuildContext context) {
    final s = submission;
    if (s == null) return Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.outline);
    return s.complete
        ? Icon(Icons.check_circle, color: Colors.green.shade600)
        : Icon(Icons.timelapse, color: Theme.of(context).colorScheme.tertiary);
  }
}

/// Choose what to assign: one of my exercises or one from the shared bank.
class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker({required this.exercises, required this.cloud, this.inDialog = false});

  final List<Exercise> exercises;
  final Cloud cloud;

  /// In a dialog on a computer: with its own title and a close button.
  final bool inDialog;

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  late final _bank = widget.cloud.backend.publications(kind: PublicationKind.ejercicio);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: widget.inDialog,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (widget.inDialog)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text('Asignar ejercicio', style: theme.textTheme.titleLarge)),
                  IconButton(tooltip: 'Cerrar', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
          Text('Mis ejercicios', style: theme.textTheme.titleMedium),
          if (widget.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Aún no tienes. Crea uno con "Crear ejercicio con este programa" en el menú Profesor.'),
            ),
          for (final e in widget.exercises)
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(e.title),
              subtitle: Text('${e.cases.length} pruebas'),
              onTap: () => Navigator.pop(context, e),
            ),
          const Divider(),
          Text('Del banco de la comunidad', style: theme.textTheme.titleMedium),
          FutureBuilder(
            future: _bank,
            builder: (context, snapshot) {
              final bank = snapshot.data;
              if (snapshot.hasError) return const Text('No se pudo cargar el banco.');
              if (bank == null) return const LinearProgressIndicator();
              if (bank.isEmpty) return const Text('Todavía no hay ejercicios compartidos.');
              return Column(
                children: [
                  for (final p in bank)
                    if (p.exercise case final exercise?)
                      ListTile(
                        leading: const Icon(Icons.public),
                        title: Text(p.title),
                        subtitle: Text('${p.topic} · de ${p.authorAlias}'),
                        onTap: () => Navigator.pop(context, exercise),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _JoinDialog extends StatefulWidget {
  const _JoinDialog();

  @override
  State<_JoinDialog> createState() => _JoinDialogState();
}

class _JoinDialogState extends State<_JoinDialog> {
  final _code = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code.text.trim().isEmpty || _name.text.trim().isEmpty) return;
    Navigator.pop(context, (_code.text.trim(), _name.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unirme a una clase'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _code,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Código de la clase', hintText: 'JAG-4K7Q'),
            ),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                helperText: 'Solo lo ve tu profesor, para saber de quién es cada entrega.',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: const Text('Unirme')),
      ],
    );
  }
}

Future<String?> _askText(BuildContext context, {required String title, required String label, String? hint}) {
  final field = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: field,
        autofocus: true,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onSubmitted: (text) => Navigator.pop(context, text.trim().isEmpty ? null : text.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(context, field.text.trim().isEmpty ? null : field.text.trim()),
          child: const Text('Crear'),
        ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.text, this.action});

  final IconData icon;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(text, textAlign: TextAlign.center),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// What the teacher sees when a lot of code arrived at once. A reason to
/// ask the student to explain it, not proof of anything.
class _PastedNote extends StatelessWidget {
  const _PastedNote({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: scheme.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.content_paste, size: 20, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pegó $lines líneas de una vez mientras lo escribía. Puede ser código suyo de otro lado, '
              'o de alguien más: pídele que te explique el programa.',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
