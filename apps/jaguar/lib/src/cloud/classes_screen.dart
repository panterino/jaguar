import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../exercises/exercise_editor_screen.dart';
import '../exercises/exercise_store.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/pro_widgets.dart';
import '../widgets/skeleton.dart';
import '../workspace/classes_room.dart' show TaskRow;
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
    showDialog<String>(context: context, builder: (_) => const _NewClassDialog());

/// Fields with an outline inside a dialog: here people fill in a form, so they
/// should look like one.
Widget _formTheme(BuildContext context, Widget child) => Theme(
  data: Theme.of(
    context,
  ).copyWith(inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: false)),
  child: child,
);

class _NewClassDialog extends StatefulWidget {
  const _NewClassDialog();

  @override
  State<_NewClassDialog> createState() => _NewClassDialogState();
}

class _NewClassDialogState extends State<_NewClassDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _formTheme(
      context,
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Crear una clase'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tus alumnos la verán con este nombre. Al crearla recibes un código para que se unan.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nombre de la clase', hintText: '1° A · Lógica'),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: _submit, child: const Text('Crear clase')),
        ],
      ),
    );
  }
}

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
  Future<bool>? _sync;

  Cloud get _cloud => widget.cloud;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final sync = _cloud.signedIn ? _cloud.syncClasses() : null;
    setState(() {
      _sync = sync;
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
                  'Los alumnos hacen las tareas y las entregan desde su teléfono.',
              action: FilledButton(onPressed: _signIn, child: const Text('Entrar')),
            )
          : FutureBuilder<bool>(
              future: _sync,
              builder: (context, snapshot) {
                // The copy kept on the device is shown at once, with or without internet.
                final cached = _cloud.tasks.cachedClasses(user.uid);
                if (cached == null) {
                  if (snapshot.hasError) {
                    return _Empty(
                      icon: Icons.cloud_off,
                      title: 'No se pudieron cargar tus clases',
                      text: '${snapshot.error}',
                      action: OutlinedButton(onPressed: _reload, child: const Text('Reintentar')),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _Empty(
                      icon: Icons.cloud_off,
                      title: 'Sin conexión',
                      text:
                          'La primera vez hace falta internet para traer tus clases. Después las verás aquí aunque no haya.',
                      action: OutlinedButton(onPressed: _reload, child: const Text('Reintentar')),
                    );
                  }
                  return const Padding(padding: EdgeInsets.all(12), child: SkeletonClassList());
                }
                final classes = [for (final c in cached) c.room];
                final offline = snapshot.connectionState == ConnectionState.done && snapshot.data == false;
                if (classes.isEmpty) {
                  return _Empty(
                    icon: Icons.groups_outlined,
                    title: user.isTeacher ? 'Aún no tienes clases' : 'Aún no estás en ninguna clase',
                    text: user.isTeacher
                        ? 'Crea una clase y comparte su código con tu grupo.'
                        : 'Pídele a tu profesor el código de la clase (como JAG-K7Q4M2XP).',
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
                        if (offline)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: NoticeBox(
                              icon: Icons.cloud_off,
                              text: 'Sin conexión. Estás viendo lo último que se guardó.',
                            ),
                          ),
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
    this.settings,
  });

  final Cloud cloud;
  final ClassRoom room;
  final ExerciseStore exercises;

  /// For the code editor when the teacher writes an exercise from here.
  final ViewSettings? settings;
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
  bool _offline = false;
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

  /// A student reads the class from the copy kept on the device, refreshed
  /// from the server when there is internet.
  Future<void> _loadAsStudent() async {
    final cloud = widget.cloud;
    final uid = cloud.user?.uid;
    if (uid == null) return;
    bool online;
    try {
      online = await cloud.syncClasses();
    } on CloudException catch (e) {
      if (mounted && _assignments == null) setState(() => _error = e.message);
      return;
    }
    if (!mounted) return;
    final cached = cloud.tasks.cachedClasses(uid)?.where((c) => c.room.id == widget.room.id).firstOrNull;
    setState(() {
      _offline = !online;
      if (cached != null) {
        _assignments = cached.assignments;
        _error = null;
      } else if (_assignments == null) {
        _error = online
            ? 'Esta clase ya no está.'
            : 'Sin conexión. Abre la clase una vez con internet para verla aquí después.';
      }
    });
  }

  Future<void> _load() async {
    if (!_isTeacher) return _loadAsStudent();
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
            child: _ExercisePicker(
              exercises: widget.exercises.authored,
              cloud: widget.cloud,
              inDialog: true,
              onCreate: _createExercise,
            ),
          ),
        ),
      );
    }
    return showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) =>
          _ExercisePicker(exercises: widget.exercises.authored, cloud: widget.cloud, onCreate: _createExercise),
    );
  }

  /// Writes a new exercise without leaving the class: the editor opens over
  /// the picker, and the saved exercise is assigned right away.
  Future<Exercise?> _createExercise(BuildContext pickerContext) => Navigator.push<Exercise>(
    pickerContext,
    MaterialPageRoute<Exercise>(
      fullscreenDialog: true,
      builder: (_) => ExerciseEditorScreen(store: widget.exercises, settings: widget.settings),
    ),
  );

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
    widget.cloud.linkAssignment(assignment.exercise, assignment, className: widget.room.name);
    Navigator.popUntil(context, (route) => route.isFirst);
    widget.onOpenAssignment(assignment);
  }

  Future<void> _showSubmission(Submission submission, Assignment assignment) async {
    final said = _claimed['${assignment.id}/${submission.uid}'];
    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          title: Row(
            children: [
              InitialsAvatar(name: submission.name, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      assignment.title,
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      label: '${submission.passed} de ${submission.total} pruebas',
                      tone: submission.complete ? PillTone.good : PillTone.warn,
                      icon: submission.complete ? Icons.check_circle : Icons.timelapse,
                    ),
                    if (submission.updatedAt != null)
                      StatusPill(label: _time(submission.updatedAt!), icon: Icons.schedule),
                  ],
                ),
                if (submission.pastedLines > 0) ...[
                  const SizedBox(height: 12),
                  NoticeBox(
                    tone: PillTone.info,
                    icon: Icons.content_paste,
                    text:
                        'Pegó ${submission.pastedLines} líneas de una vez mientras lo escribía. Puede ser código suyo '
                        'de otro lado, o de alguien más: pídele que te explique el programa.',
                  ),
                ],
                if (said != null) ...[
                  const SizedBox(height: 12),
                  NoticeBox(
                    tone: PillTone.warn,
                    icon: Icons.rule,
                    text:
                        'El alumno dijo $said. Jaguar corrió su programa contra todas las pruebas, '
                        'las ocultas incluidas, y salió lo que ves arriba.',
                  ),
                ],
                const SizedBox(height: 14),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: scheme.surfaceContainerHigh,
                          padding: const EdgeInsets.fromLTRB(14, 2, 4, 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Programa del alumno',
                                  style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Copiar programa',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: submission.source));
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(const SnackBar(content: Text('Programa copiado')));
                                },
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(14),
                            child: SelectableText(
                              submission.source,
                              style: monoStyle.copyWith(fontSize: 13, height: 1.45, letterSpacing: 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                widget.onOpenSource('// Entrega de ${submission.name}: ${assignment.title}\n${submission.source}');
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Abrir una copia'),
            ),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        );
      },
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
              ? _Empty(
                  icon: Icons.cloud_off,
                  title: 'No se pudo cargar',
                  text: _error!,
                  action: OutlinedButton(onPressed: _load, child: const Text('Reintentar')),
                )
              : assignments == null
              ? (_isTeacher
                    ? SkeletonClassBoard(wide: wide)
                    : const Padding(padding: EdgeInsets.all(16), child: SkeletonRows(count: 3)))
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
        if (!_isTeacher) ...[
          if (_offline)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: NoticeBox(
                icon: Icons.cloud_off,
                text: 'Sin conexión. Puedes trabajar tus tareas aquí; entrégalas cuando tengas internet.',
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final a in assignments)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TaskRow(
                        assignment: a,
                        record: widget.cloud.tasks.forAssignment(widget.room.id, a.id),
                        onTap: () => _openAssignment(a),
                      ),
                      if (a.hiddenCount > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(52, 0, 16, 10),
                          child: Text(
                            a.hiddenCount == 1
                                ? 'Tu profe revisa 1 prueba más que no se ve.'
                                : 'Tu profe revisa ${a.hiddenCount} pruebas más que no se ven.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
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

  /// The class in three figures: people, tasks, and how much of what was asked
  /// is done.
  Widget _stats(List<Assignment> assignments) {
    final total = _members.length * assignments.length;
    final done = [for (final a in assignments) _completed(a)].fold(0, (a, b) => a + b);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(icon: Icons.groups_outlined, value: '${_members.length}', label: 'Alumnos'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(icon: Icons.assignment_outlined, value: '${assignments.length}', label: 'Tareas'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StatTile(
          icon: Icons.task_alt,
          value: total == 0 ? '—' : '${(done * 100 / total).round()} %',
          label: 'Entregas completas',
          progress: total == 0 ? null : done / total,
        ),
      ],
    );
  }

  /// The table as text with tabs, which a spreadsheet takes as columns. The
  /// numbers are the ones Jaguar checked, not what each student reported.
  String _gradesTsv(List<Assignment> assignments) {
    String cell(String text) => text.replaceAll(RegExp(r'[\t\r\n]+'), ' ');
    final rows = <List<String>>[
      ['Alumno', for (final a in assignments) a.title, 'Tareas completas'],
    ];
    for (final m in _members) {
      var done = 0;
      final cells = <String>[];
      for (final a in assignments) {
        final s = _submissions[a.id]?[m.uid];
        if (s == null) {
          cells.add('');
        } else {
          cells.add('${s.passed}/${s.total}');
          if (s.complete) done++;
        }
      }
      rows.add([m.name, ...cells, '$done/${assignments.length}']);
    }
    return rows.map((r) => r.map(cell).join('\t')).join('\n');
  }

  Future<void> _copyGrades(List<Assignment> assignments) async {
    await Clipboard.setData(ClipboardData(text: _gradesTsv(assignments)));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Calificaciones copiadas. Pégalas en una hoja de cálculo.')));
  }

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
            claimed: _claimed,
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
                _stats(assignments),
                const SizedBox(height: 14),
                Tooltip(
                  message: 'Elige uno de tus ejercicios o uno del banco',
                  child: FilledButton.icon(
                    onPressed: _assign,
                    icon: const Icon(Icons.assignment_add),
                    label: const Text('Asignar ejercicio'),
                  ),
                ),
                const SizedBox(height: 24),
                const BlockHeading('Tareas'),
                if (assignments.isEmpty)
                  Text(
                    'Todavía no hay tareas en esta clase.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                for (final a in assignments)
                  _TaskTile(
                    assignment: a,
                    completed: _completed(a),
                    students: _members.length,
                    onRemove: () => _removeAssignment(a),
                  ),
                if (assignments.isNotEmpty && _members.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Tooltip(
                    message: 'Copia la tabla para pegarla en una hoja de cálculo',
                    child: OutlinedButton.icon(
                      onPressed: () => _copyGrades(assignments),
                      icon: const Icon(Icons.table_view_outlined),
                      label: const Text('Copiar calificaciones'),
                    ),
                  ),
                ],
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
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BlockHeading('Código de la clase'),
          CodeBadge(code: code),
          const SizedBox(height: 10),
          Text(
            students == 1
                ? '1 alumno dentro. Tu grupo lo escribe en Unirme con código.'
                : '$students alumnos dentro. Tu grupo lo escribe en Unirme con código.',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Divider(height: 16, color: scheme.primary.withValues(alpha: 0.2)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      open ? 'Recibe alumnos nuevos' : 'Cerrada a alumnos nuevos',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      open ? 'Cualquiera con el código puede unirse.' : 'Quien ya está dentro se queda.',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(value: open, onChanged: onOpenChanged),
            ],
          ),
        ],
      ),
    );
  }
}

/// A task in the side panel: its name, how many finished it, and a bar.
class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.assignment, required this.completed, required this.students, required this.onRemove});

  final Assignment assignment;
  final int completed;
  final int students;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  assignment.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Quitar tarea',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed de $students completas',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: students == 0 ? 0 : completed / students,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                if (assignment.hiddenCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    assignment.hiddenCount == 1
                        ? 'Incluye 1 prueba oculta'
                        : 'Incluye ${assignment.hiddenCount} pruebas ocultas',
                    style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    required this.claimed,
    required this.onTap,
  });

  final List<Assignment> assignments;
  final List<Member> members;
  final Map<String, Map<String, Submission>> submissions;
  final int Function(Assignment) completed;

  /// `assignmentId/uid` → what the student said, where Jaguar's check found
  /// something else.
  final Map<String, String> claimed;
  final void Function(Submission, Assignment) onTap;

  static const _nameWidth = 240.0;
  static const _taskWidth = 190.0;
  static const _totalWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final natural = _nameWidth + assignments.length * _taskWidth + _totalWidth;
          final width = natural > constraints.maxWidth ? natural : constraints.maxWidth;
          // The task columns share what the other two leave, so a few tasks
          // do not leave an empty strip on the right.
          final taskWidth = (width - _nameWidth - _totalWidth) / assignments.length;
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: _head(context)),
                            const SizedBox(height: 2),
                            Text(
                              '${completed(a)} de ${members.length} completas',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: members.isEmpty ? 0 : completed(a) / members.length,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                              backgroundColor: scheme.surfaceContainerHighest,
                            ),
                          ],
                        ),
                      ),
                  ],
                  total: Text('Avance', style: _head(context)),
                  taskWidth: taskWidth,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, i) {
                      final m = members[i];
                      final done = [
                        for (final a in assignments)
                          if (submissions[a.id]?[m.uid]?.complete ?? false) a,
                      ].length;
                      return _row(
                        context,
                        shaded: i.isOdd,
                        name: Row(
                          children: [
                            InitialsAvatar(name: m.name),
                            const SizedBox(width: 12),
                            Expanded(child: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        cells: [for (final a in assignments) _cell(context, m, a)],
                        total: _total(context, done),
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

  TextStyle? _head(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);

  /// How many tasks this student finished, as a short bar and a fraction.
  Widget _total(BuildContext context, int done) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: assignments.isEmpty ? 0 : done / assignments.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 10),
          Text('$done/${assignments.length}', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required Widget name,
    required List<Widget> cells,
    required Widget total,
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
            ? scheme.surfaceContainerLow.withValues(alpha: 0.6)
            : null,
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: header ? 1 : 0.6)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _nameWidth,
            constraints: BoxConstraints(minHeight: header ? 64 : 56),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: name,
          ),
          for (final cell in cells)
            Container(
              width: taskWidth,
              constraints: BoxConstraints(minHeight: header ? 64 : 56),
              alignment: Alignment.centerLeft,
              padding: header ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : EdgeInsets.zero,
              child: cell,
            ),
          Container(
            width: _totalWidth,
            constraints: BoxConstraints(minHeight: header ? 64 : 56),
            alignment: Alignment.centerLeft,
            padding: header ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : EdgeInsets.zero,
            child: total,
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
          child: Text('Sin entregar', style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8))),
        ),
      );
    }
    final said = claimed['${assignment.id}/${member.uid}'];
    return Semantics(
      button: true,
      label:
          '${member.name}, ${assignment.title}: ${s.passed} de ${s.total} pruebas.'
          '${said == null ? '' : ' El alumno dijo $said.'} Abre la entrega.',
      excludeSemantics: true,
      child: Tooltip(
        message: 'Ver la entrega de ${member.name}',
        child: InkWell(
          onTap: () => onTap(s, assignment),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  child: StatusPill(
                    label: '${s.passed} de ${s.total}',
                    tone: s.complete ? PillTone.good : PillTone.warn,
                    icon: s.complete ? Icons.check_circle : Icons.timelapse,
                  ),
                ),
                if (said != null) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'El alumno dijo $said; Jaguar revisó su programa y salió esto.',
                    child: Icon(Icons.rule, size: 18, color: scheme.error),
                  ),
                ],
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
  const _ExercisePicker({required this.exercises, required this.cloud, required this.onCreate, this.inDialog = false});

  final List<Exercise> exercises;
  final Cloud cloud;

  /// Opens the editor for a new exercise; the saved one comes back.
  final Future<Exercise?> Function(BuildContext context) onCreate;

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
    final scheme = theme.colorScheme;
    return SafeArea(
      child: ListView(
        shrinkWrap: widget.inDialog,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          if (widget.inDialog)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text('Asignar ejercicio', style: theme.textTheme.titleLarge)),
                  IconButton(tooltip: 'Cerrar', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
          Text(
            'Elige el ejercicio que tu grupo va a resolver. Se revisa solo.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () async {
              final created = await widget.onCreate(context);
              if (created != null && context.mounted) Navigator.pop(context, created);
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear un ejercicio nuevo'),
          ),
          const SizedBox(height: 16),
          const BlockHeading('Mis ejercicios'),
          if (widget.exercises.isEmpty) const NoticeBox(text: 'Aún no tienes ejercicios guardados.'),
          for (final e in widget.exercises)
            _PickRow(
              icon: Icons.assignment_outlined,
              title: e.title,
              detail: e.cases.length == 1 ? '1 prueba' : '${e.cases.length} pruebas',
              onTap: () => Navigator.pop(context, e),
            ),
          const SizedBox(height: 16),
          const BlockHeading('Del banco de la comunidad'),
          FutureBuilder(
            future: _bank,
            builder: (context, snapshot) {
              final bank = snapshot.data;
              if (snapshot.hasError) return const NoticeBox(tone: PillTone.bad, text: 'No se pudo cargar el banco.');
              if (bank == null) return const SkeletonRows(count: 3);
              if (bank.isEmpty) return const NoticeBox(text: 'Todavía no hay ejercicios compartidos.');
              return Column(
                children: [
                  for (final p in bank)
                    if (p.exercise case final exercise?)
                      _PickRow(
                        icon: Icons.public,
                        title: p.title,
                        detail: '${p.topic} · de ${p.authorAlias}',
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

/// One exercise to choose: a card with its name and a line of detail.
class _PickRow extends StatelessWidget {
  const _PickRow({required this.icon, required this.title, required this.detail, required this.onTap});

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    return _formTheme(
      context,
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Unirme a una clase'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pídele el código a tu profesor. No hace falta correo ni teléfono.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _code,
                autofocus: true,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                style: monoStyle.copyWith(fontSize: 16, letterSpacing: 1),
                decoration: const InputDecoration(labelText: 'Código de la clase', hintText: 'JAG-K7Q4M2XP'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  helperText: 'Solo lo ve tu profesor, para saber de quién es cada entrega.',
                  helperMaxLines: 2,
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
      ),
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
