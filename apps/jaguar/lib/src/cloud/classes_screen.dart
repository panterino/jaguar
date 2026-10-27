import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../exercises/exercise_store.dart';
import '../theme.dart';
import 'account_dialog.dart';
import 'cloud.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases'),
        actions: [IconButton(tooltip: 'Actualizar', icon: const Icon(Icons.refresh), onPressed: _reload)],
      ),
      floatingActionButton: user == null
          ? null
          : user.isTeacher
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Crear clase'),
            )
          : FloatingActionButton.extended(
              onPressed: _join,
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Unirme con un código'),
            ),
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
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final room in classes)
                      Card(
                        child: ListTile(
                          leading: Icon(room.ownerId == user.uid ? Icons.school_outlined : Icons.backpack_outlined),
                          title: Text(room.name, style: theme.textTheme.titleMedium),
                          subtitle: Text(room.ownerId == user.uid ? 'Código ${room.code}' : 'Con ${room.ownerAlias}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _open(room),
                        ),
                      ),
                  ],
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
      for (final a in assignments) {
        if (_isTeacher) {
          submissions[a.id] = await _backend.submissions(widget.room.id, a.id);
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
        _error = null;
      });
    } on CloudException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _assign() async {
    final exercise = await showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ExercisePicker(exercises: widget.exercises.authored, cloud: widget.cloud),
    );
    if (exercise == null) return;
    try {
      await _backend.assign(widget.room.id, exercise);
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
    final theme = Theme.of(context);
    final assignments = _assignments;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        actions: [IconButton(tooltip: 'Actualizar', icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: _isTeacher
          ? FloatingActionButton.extended(
              onPressed: _assign,
              icon: const Icon(Icons.assignment_add),
              label: const Text('Asignar ejercicio'),
            )
          : null,
      body: _error != null
          ? _Empty(icon: Icons.cloud_off, title: 'No se pudo cargar', text: _error!)
          : assignments == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                if (_isTeacher) _CodeCard(code: widget.room.code, students: _members.length),
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
                    onRemove: (a) async {
                      await _backend.removeAssignment(widget.room.id, a.id);
                      await _load();
                    },
                  ),
                if (!_isTeacher)
                  for (final a in assignments)
                    Card(
                      child: ListTile(
                        leading: _StatusIcon(submission: _submissions[a.id]?.values.firstOrNull),
                        title: Text(a.title),
                        subtitle: Text(switch (_submissions[a.id]?.values.firstOrNull) {
                          null => 'Sin entregar',
                          final s when s.complete => 'Completa: ${s.passed} de ${s.total} pruebas',
                          final s => '${s.passed} de ${s.total} pruebas',
                        }),
                        trailing: FilledButton.tonal(
                          onPressed: () => _openAssignment(a),
                          child: const Text('Resolver'),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}

String _time(DateTime time) {
  final local = time.toLocal();
  return '${local.day}/${local.month} ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.students});

  final String code;
  final int students;

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
  const _ExercisePicker({required this.exercises, required this.cloud});

  final List<Exercise> exercises;
  final Cloud cloud;

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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
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
