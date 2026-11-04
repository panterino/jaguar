import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../cloud/account_dialog.dart';
import '../cloud/cloud.dart';
import '../cloud/community_screen.dart';
import '../settings.dart';
import '../theme.dart';
import 'exercise_editor_screen.dart';
import 'exercise_store.dart';
import 'project_screen.dart';

/// Same breakpoint as the rooms: from here the list and the detail go side
/// by side.
const _wideWidth = 900.0;

/// The teacher's exercise bank, reusable across groups and semesters.
///
/// On a phone it is a list with a menu per exercise. On a computer the list
/// is on the left and the selected exercise on the right, with its statement,
/// its cases and every action one click away.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key, required this.store, required this.onTryAsStudent, this.cloud, this.settings});

  final ExerciseStore store;
  final ValueChanged<Exercise> onTryAsStudent;

  /// To share exercises with other teachers; null offline.
  final Cloud? cloud;

  /// For the code editor of the solution; null uses the defaults.
  final ViewSettings? settings;

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String? _selectedId;

  ExerciseStore get _store => widget.store;

  Future<void> _share(Exercise exercise) async {
    final cloud = widget.cloud!;
    if (!cloud.signedIn) {
      await showAccountDialog(context, cloud);
      if (!cloud.signedIn || !mounted) return;
    }
    final published = await showDialog<bool>(
      context: context,
      builder: (_) => PublishDialog(cloud: cloud, source: '', exercise: exercise.toJson()),
    );
    if (published == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compartido: otros profesores ya pueden asignarlo a sus clases.')));
    }
  }

  void _edit([Exercise? exercise]) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExerciseEditorScreen(store: _store, exercise: exercise, settings: widget.settings),
      ),
    );
  }

  void _project(Exercise exercise) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProjectScreen(exercise: exercise)));
  }

  Future<void> _confirmDelete(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar "${exercise.title}"?'),
        content: const Text('Los alumnos que ya lo abrieron conservan su copia.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed ?? false) _store.delete(exercise.id);
  }

  /// The selected exercise, or the first one when nothing (or something
  /// already deleted) is selected.
  Exercise? _current(List<Exercise> exercises) {
    for (final exercise in exercises) {
      if (exercise.id == _selectedId) return exercise;
    }
    return exercises.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _wideWidth;
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final exercises = _store.authored;
        final current = _current(exercises);
        return Scaffold(
          appBar: AppBar(title: const Text('Mis ejercicios')),
          // On a computer the button lives in the list; with nothing yet, the
          // empty state already offers it.
          floatingActionButton: wide || exercises.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: _edit,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo ejercicio'),
                ),
          body: CallbackShortcuts(
            bindings: {
              // Ctrl on Windows and Linux, Cmd on Mac.
              const SingleActivator(LogicalKeyboardKey.keyN, control: true): _edit,
              const SingleActivator(LogicalKeyboardKey.keyN, meta: true): _edit,
              if (current != null) ...{
                const SingleActivator(LogicalKeyboardKey.keyE, control: true): () => _edit(current),
                const SingleActivator(LogicalKeyboardKey.keyE, meta: true): () => _edit(current),
                const SingleActivator(LogicalKeyboardKey.delete): () => _confirmDelete(current),
              },
              const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.maybePop(context),
            },
            child: Focus(
              autofocus: true,
              child: exercises.isEmpty
                  ? _EmptyState(onCreate: _edit)
                  : wide
                  ? _wideBody(exercises, current!)
                  : _narrowBody(exercises),
            ),
          ),
        );
      },
    );
  }

  Widget _narrowBody(List<Exercise> exercises) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final exercise in exercises)
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(exercise.title),
            subtitle: Text(_summary(exercise)),
            onTap: () => _edit(exercise),
            trailing: MenuAnchor(
              builder: (context, controller, _) => IconButton(
                tooltip: 'Opciones',
                icon: const Icon(Icons.more_vert),
                onPressed: () => controller.isOpen ? controller.close() : controller.open(),
              ),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.qr_code_2),
                  onPressed: () => _project(exercise),
                  child: const Text('Proyectar'),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.play_circle_outline),
                  onPressed: () => widget.onTryAsStudent(exercise),
                  child: const Text('Probar como alumno'),
                ),
                if (widget.cloud != null)
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.public),
                    onPressed: () => _share(exercise),
                    child: const Text('Compartir en el banco'),
                  ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(exercise),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _summary(Exercise exercise) {
    final count = exercise.cases.length;
    return '${count == 1 ? '1 caso' : '$count casos'}'
        '${_store.solutionFor(exercise.id) != null ? ' · con solución' : ''}';
  }

  Widget _wideBody(List<Exercise> exercises, Exercise current) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 340,
          child: FocusTraversalGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Tooltip(
                        message: 'Nuevo ejercicio (${shortcutLabel('N')})',
                        child: FilledButton.icon(
                          onPressed: _edit,
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo ejercicio'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        exercises.length == 1 ? '1 ejercicio' : '${exercises.length} ejercicios',
                        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    children: [
                      for (final exercise in exercises)
                        // Moving with the keyboard selects, as in a file list.
                        Focus(
                          skipTraversal: true,
                          onFocusChange: (focused) {
                            if (focused && _selectedId != exercise.id) setState(() => _selectedId = exercise.id);
                          },
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            selected: exercise.id == current.id,
                            selectedTileColor: theme.colorScheme.secondaryContainer,
                            selectedColor: theme.colorScheme.onSecondaryContainer,
                            leading: const Icon(Icons.assignment_outlined),
                            title: Text(exercise.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(_summary(exercise)),
                            onTap: () => setState(() => _selectedId = exercise.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: FocusTraversalGroup(
            child: _ExerciseDetail(
              // A new key per exercise: scroll goes back to the top.
              key: ValueKey(current.id),
              exercise: current,
              hasSolution: _store.solutionFor(current.id) != null,
              onEdit: () => _edit(current),
              onProject: () => _project(current),
              onTry: () => widget.onTryAsStudent(current),
              onShare: widget.cloud == null ? null : () => _share(current),
              onDelete: () => _confirmDelete(current),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/mascota.png', width: 96, height: 96, excludeFromSemantics: true),
              const SizedBox(height: 16),
              Text('Crea tu primer ejercicio', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Escribe el enunciado y tu solución: Jaguar propone los casos de prueba. '
                'Proyéctalo como QR y tus alumnos lo resuelven; Jaguar les dice si está bien.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Tooltip(
                message: 'Nuevo ejercicio (${shortcutLabel('N')})',
                child: FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Crear mi primer ejercicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The selected exercise on a computer: what it says, its cases, and what
/// can be done with it.
class _ExerciseDetail extends StatelessWidget {
  const _ExerciseDetail({
    super.key,
    required this.exercise,
    required this.hasSolution,
    required this.onEdit,
    required this.onProject,
    required this.onTry,
    required this.onShare,
    required this.onDelete,
  });

  final Exercise exercise;
  final bool hasSolution;
  final VoidCallback onEdit;
  final VoidCallback onProject;
  final VoidCallback onTry;

  /// Null offline.
  final VoidCallback? onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hidden = exercise.cases.where((c) => c.hidden).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(header: true, child: Text(exercise.title, style: theme.textTheme.headlineSmall)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Fact(
                    Icons.fact_check_outlined,
                    exercise.cases.length == 1 ? '1 caso' : '${exercise.cases.length} casos',
                  ),
                  if (hidden > 0) _Fact(Icons.visibility_off_outlined, hidden == 1 ? '1 oculto' : '$hidden ocultos'),
                  _Fact(
                    exercise.mode == MatchMode.flexible ? Icons.tune : Icons.rule,
                    exercise.mode == MatchMode.flexible ? 'Comparación flexible' : 'Comparación exacta',
                  ),
                  _Fact(
                    hasSolution ? Icons.check_circle_outline : Icons.error_outline,
                    hasSolution ? 'Con solución guardada' : 'Sin solución',
                    warn: !hasSolution,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onProject,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Proyectar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onTry,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Probar como alumno'),
                  ),
                  if (onShare != null)
                    OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.public),
                      label: const Text('Compartir en el banco'),
                    ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Enunciado', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              exercise.statement.isEmpty
                  ? Text(
                      'Este ejercicio aún no tiene enunciado. Ábrelo con Editar para escribirlo.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    )
                  : SelectableText(exercise.statement, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 28),
              Text('Casos de prueba', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (exercise.cases.isEmpty)
                Text(
                  'Aún no hay casos. Abre el ejercicio y pulsa «Generar casos con mi solución».',
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                )
              else
                _CasesTable(cases: exercise.cases),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small fact about the exercise, as a chip that does nothing.
class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.label, {this.warn = false});

  final IconData icon;
  final String label;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = warn ? scheme.error : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warn ? scheme.error : scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

/// Inputs and expected output of every case, side by side.
class _CasesTable extends StatelessWidget {
  const _CasesTable({required this.cases});

  final List<TestCase> cases;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final head = theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant);
    final mono = monoStyle.copyWith(fontSize: 13, letterSpacing: 0, color: scheme.onSurface);
    Widget cell(Widget child) =>
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: child);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1.4),
          3: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        border: TableBorder(horizontalInside: BorderSide(color: scheme.outlineVariant)),
        children: [
          TableRow(
            decoration: BoxDecoration(color: scheme.surfaceContainerLow),
            children: [
              cell(Text('Caso', style: head)),
              cell(Text('Datos de entrada', style: head)),
              cell(Text('Salida esperada', style: head)),
              cell(Text('Visibilidad', style: head)),
            ],
          ),
          for (final (i, c) in cases.indexed)
            TableRow(
              children: [
                cell(Text('${i + 1}', style: theme.textTheme.bodyMedium)),
                cell(
                  c.inputs.isEmpty
                      ? Text('Sin datos', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
                      : SelectableText(c.inputs.join('\n'), style: mono),
                ),
                cell(SelectableText(c.expected, style: mono)),
                cell(
                  Row(
                    children: [
                      Icon(
                        c.hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(c.hidden ? 'Oculto' : 'Visible', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
