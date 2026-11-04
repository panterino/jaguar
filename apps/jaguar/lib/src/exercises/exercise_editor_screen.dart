import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../editor/code_editor.dart';
import '../editor/completions.dart';
import '../editor/keyword_bar.dart';
import '../editor/syntax_controller.dart';
import '../settings.dart';
import '../theme.dart';
import 'check_results_sheet.dart';
import 'exercise_store.dart';
import 'project_screen.dart';
import '../widgets/page_width.dart';

class _CaseFields {
  _CaseFields([TestCase? testCase])
    : name = testCase?.name ?? '',
      inputs = TextEditingController(text: testCase?.inputs.join('\n') ?? ''),
      expected = TextEditingController(text: testCase?.expected ?? ''),
      hidden = testCase?.hidden ?? false;

  final String name;
  final TextEditingController inputs;
  final TextEditingController expected;
  bool hidden;

  TestCase toTestCase() => TestCase(
    name: name,
    inputs: inputs.text.isEmpty ? const [] : inputs.text.replaceAll('\r\n', '\n').split('\n'),
    expected: expected.text,
    hidden: hidden,
  );

  void dispose() {
    inputs.dispose();
    expected.dispose();
  }
}

/// Where the teacher writes an exercise. The teacher writes the solution;
/// Jaguar proposes the test cases from it (see `suggestTests`), and the
/// teacher only reviews them.
class ExerciseEditorScreen extends StatefulWidget {
  const ExerciseEditorScreen({super.key, required this.store, this.exercise, this.fromProgram, this.settings});

  final ExerciseStore store;

  /// Font size and keyword bar of the code editor, the same as in the
  /// workspace. Null uses the defaults.
  final ViewSettings? settings;

  /// Null for a new exercise.
  final Exercise? exercise;

  /// "Crear ejercicio con este programa": the program is the solution; the
  /// title and statement come from its name and first comments, and the
  /// cases are generated right away.
  final String? fromProgram;

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  late final String _id = widget.exercise?.id ?? ExerciseStore.newId();
  late final _title = TextEditingController(
    text: widget.exercise?.title ?? (widget.fromProgram == null ? '' : titleFromProgram(widget.fromProgram!)),
  );
  late final _statement = TextEditingController(
    text: widget.exercise?.statement ?? (widget.fromProgram == null ? '' : statementFromProgram(widget.fromProgram!)),
  );
  late final _solution = SyntaxController(
    text: widget.fromProgram ?? widget.store.solutionFor(_id) ?? 'Algoritmo solucion\n    \nFinAlgoritmo\n',
  );
  late MatchMode _mode = widget.exercise?.mode ?? MatchMode.flexible;
  late final List<_CaseFields> _cases = [
    for (final testCase in widget.exercise?.cases ?? const <TestCase>[]) _CaseFields(testCase),
  ];
  // The solution is written in the same editor as any program: completions,
  // auto indent, find and replace, and errors while typing.
  final _solutionFocus = FocusNode();
  final _undo = UndoHistoryController();
  late final _diagnostics = Diagnostics(_solution);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.fromProgram != null) WidgetsBinding.instance.addPostFrameCallback((_) => _generateCases());
  }

  /// Proposes the cases from the solution, replacing the ones there.
  Future<void> _generateCases() async {
    if (!_hasSolution) {
      _toast('Primero escribe tu solución: de ella salen los casos.');
      return;
    }
    if (_cases.isNotEmpty && widget.fromProgram == null) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Reemplazar los casos?'),
          content: const Text('Jaguar propondrá casos nuevos a partir de tu solución.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reemplazar')),
          ],
        ),
      );
      if (replace != true) return;
    }
    setState(() => _busy = true);
    try {
      final tests = await suggestTests(_solution.text, mode: _mode);
      if (!mounted) return;
      setState(() {
        for (final c in _cases) {
          c.dispose();
        }
        _cases
          ..clear()
          ..addAll(tests.map(_CaseFields.new));
      });
      _toast(
        tests.isEmpty
            ? 'No encontré casos: revisa que tu solución lea datos y muestre algo.'
            : 'Listo: ${tests.length} casos que recorren los caminos de tu solución. Revísalos y ajusta si quieres.',
      );
    } on JaguarError catch (error) {
      _toast('Tu solución tiene un error en la línea ${error.line}: ${error.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _statement.dispose();
    _diagnostics.dispose();
    _solution.dispose();
    _solutionFocus.dispose();
    _undo.dispose();
    for (final c in _cases) {
      c.dispose();
    }
    super.dispose();
  }

  Exercise get _exercise => Exercise(
    id: _id,
    title: _title.text.trim().isEmpty ? 'Ejercicio sin título' : _title.text.trim(),
    statement: _statement.text.trim(),
    mode: _mode,
    cases: [for (final c in _cases) c.toTestCase()],
  );

  bool get _hasSolution {
    final body = _solution.text
        .replaceAll(RegExp(r'\s*(algoritmo|finalgoritmo)\b[^\n]*', caseSensitive: false), '')
        .trim();
    return body.isNotEmpty;
  }

  /// Returns a problem that makes the exercise unusable, or null.
  String? _validate() {
    if (_cases.isEmpty) return 'Agrega al menos un caso de prueba.';
    for (var i = 0; i < _cases.length; i++) {
      if (_cases[i].expected.text.trim().isEmpty) {
        return 'El caso ${i + 1} no tiene salida esperada. Escríbela o calcúlala con tu solución.';
      }
    }
    return null;
  }

  bool _save() {
    final problem = _validate();
    if (problem != null) {
      _toast(problem);
      return false;
    }
    widget.store.saveAuthored(_exercise, solution: _hasSolution ? _solution.text : null);
    return true;
  }

  Future<void> _fillExpectedFromSolution() async {
    if (!_hasSolution) {
      _toast('Primero escribe tu solución.');
      return;
    }
    setState(() => _busy = true);
    for (var i = 0; i < _cases.length; i++) {
      final result = await expectedOutputFor(_solution.text, _cases[i].toTestCase().inputs, _mode, caseIndex: i);
      if (result.error != null) {
        setState(() => _busy = false);
        _toast('Tu solución falló en el caso ${i + 1}: ${result.error!.message}');
        return;
      }
      _cases[i].expected.text = result.output;
    }
    setState(() => _busy = false);
    _toast(
      _mode == MatchMode.flexible
          ? 'Listo. Se quitaron los mensajes que piden datos; revisa que quede solo lo que el alumno debe mostrar.'
          : 'Listo. En modo exacto el alumno debe mostrar todo igual, incluidos los mensajes.',
    );
  }

  Future<void> _checkSolution() async {
    if (!_hasSolution) {
      _toast('Primero escribe tu solución.');
      return;
    }
    final problem = _validate();
    if (problem != null) {
      _toast(problem);
      return;
    }
    setState(() => _busy = true);
    final result = await checkSolution(_solution.text, _exercise);
    setState(() => _busy = false);
    if (!mounted) return;
    await showCheckResults(context, result: result);
  }

  void _project() {
    if (!_save()) return;
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProjectScreen(exercise: _exercise)));
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The code editor of the app, in a frame. [height] null fills the space.
  Widget _solutionEditor({double? height}) {
    final settings = widget.settings;
    final desktop = useDesktopLayout(context);
    final scheme = Theme.of(context).colorScheme;
    final editor = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CodeEditor(
            diagnostics: _diagnostics,
            controller: _solution,
            focusNode: _solutionFocus,
            undoController: _undo,
            fontSize: settings?.fontSize ?? 14,
            highlightCurrentLine: desktop,
          ),
        ),
        if (!desktop || (settings?.keywordBar ?? false)) KeywordBar(controller: _solution, focusNode: _solutionFocus),
      ],
    );
    final framed = Semantics(
      label: 'Editor de la solución',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(10.5), child: editor),
      ),
    );
    return height == null ? framed : SizedBox(height: height, child: framed);
  }

  /// Saves and stays, for Ctrl+S: the teacher keeps writing.
  void _saveAndStay() {
    if (_save()) _toast('Guardado');
  }

  Widget _titleField() => TextField(
    controller: _title,
    decoration: const InputDecoration(labelText: 'Título', hintText: 'Ej. Par o impar'),
    textCapitalization: TextCapitalization.sentences,
  );

  Widget _statementField() => TextField(
    controller: _statement,
    decoration: const InputDecoration(
      labelText: 'Enunciado',
      hintText: 'Lee un número entero y muestra si es par o impar.',
      alignLabelWithHint: true,
    ),
    minLines: 3,
    maxLines: 8,
    textCapitalization: TextCapitalization.sentences,
  );

  Widget _modeSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Cómo se compara la salida?', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<MatchMode>(
          segments: const [
            ButtonSegment(value: MatchMode.flexible, label: Text('Flexible'), icon: Icon(Icons.tune)),
            ButtonSegment(value: MatchMode.exact, label: Text('Exacta'), icon: Icon(Icons.rule)),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) => setState(() => _mode = selection.single),
        ),
        const SizedBox(height: 6),
        Text(
          _mode == MatchMode.flexible
              ? 'Las líneas esperadas deben aparecer en orden. El alumno puede escribir sus propios '
                    'mensajes, y no importan mayúsculas, acentos ni espacios.'
              : 'La salida debe ser idéntica, línea por línea.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _casesSection({required bool addInHeader}) {
    final theme = Theme.of(context);
    final add = TextButton.icon(
      onPressed: () => setState(() => _cases.add(_CaseFields())),
      icon: const Icon(Icons.add),
      label: const Text('Agregar caso'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: _SectionTitle(
                title: 'Casos de prueba',
                subtitle:
                    'Se generan solos con tu solución. Puedes editarlos, ocultarlos o agregar más: '
                    'cada dato de entrada va en su propia línea.',
              ),
            ),
            if (addInHeader) ...[const SizedBox(width: 8), add],
          ],
        ),
        if (_cases.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.fact_check_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Aún no hay casos. Escribe tu solución y pulsa «Generar casos», o agrega uno a mano.'),
                ),
              ],
            ),
          ),
        for (var i = 0; i < _cases.length; i++)
          _CaseCard(
            key: ObjectKey(_cases[i]),
            index: i + 1,
            fields: _cases[i],
            onHiddenChanged: (hidden) => setState(() => _cases[i].hidden = hidden),
            onDelete: () => setState(() => _cases.removeAt(i).dispose()),
          ),
        if (!addInHeader) Align(alignment: Alignment.centerLeft, child: add),
      ],
    );
  }

  Widget _solutionHeader() => const _SectionTitle(
    title: 'Tu solución',
    subtitle: 'Escríbela como si fueras el alumno. De ella salen los casos de prueba; nunca se comparte.',
  );

  Widget _solutionActions() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      FilledButton.icon(
        onPressed: _busy ? null : _generateCases,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generar casos con mi solución'),
      ),
      OutlinedButton.icon(
        onPressed: _busy ? null : _fillExpectedFromSolution,
        icon: const Icon(Icons.auto_fix_high),
        label: const Text('Recalcular salidas'),
      ),
      Tooltip(
        message: 'Corre tu solución con los casos (${shortcutLabel('Enter')})',
        child: OutlinedButton.icon(
          onPressed: _busy ? null : _checkSolution,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Comprobar mi solución'),
        ),
      ),
    ],
  );

  /// One column, as on a phone: details, solution, then the cases.
  Widget _narrowBody() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _titleField(),
          const SizedBox(height: 12),
          _statementField(),
          const SizedBox(height: 24),
          _solutionHeader(),
          _solutionEditor(height: 340),
          const SizedBox(height: 8),
          _solutionActions(),
          const SizedBox(height: 20),
          _modeSection(),
          const SizedBox(height: 24),
          _casesSection(addInHeader: false),
          const SizedBox(height: 48),
        ],
      ),
    ),
  );

  /// Two panes on a computer: what the students see on the left (title,
  /// statement, cases) and the teacher's solution on the right, with room.
  Widget _wideBody() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: FocusTraversalGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              children: [
                _titleField(),
                const SizedBox(height: 12),
                _statementField(),
                const SizedBox(height: 20),
                _modeSection(),
                const SizedBox(height: 24),
                _casesSection(addInHeader: true),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, color: scheme.outlineVariant),
        Expanded(
          flex: 6,
          child: FocusTraversalGroup(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final header = [_solutionHeader(), _solutionActions(), const SizedBox(height: 12)];
                // On a short window the editor keeps a usable height and the
                // pane scrolls instead.
                if (constraints.maxHeight < 560) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [...header, _solutionEditor(height: 340)],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...header,
                      Expanded(child: _solutionEditor()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Nuevo ejercicio' : 'Editar ejercicio'),
        actions: [
          Tooltip(
            message: 'Guardar y cerrar',
            child: TextButton.icon(
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              onPressed: () {
                if (_save()) Navigator.pop(context);
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
              onPressed: _project,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Proyectar'),
            ),
          ),
        ],
        bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()) : null,
      ),
      body: CallbackShortcuts(
        bindings: {
          // Ctrl on Windows and Linux, Cmd on Mac: both work anywhere.
          for (final (key, action) in <(LogicalKeyboardKey, VoidCallback)>[
            (LogicalKeyboardKey.keyS, _saveAndStay),
            (LogicalKeyboardKey.enter, _checkSolution),
          ]) ...{SingleActivator(key, control: true): action, SingleActivator(key, meta: true): action},
        },
        child: wide ? PageWidth(width: workWidth, child: _wideBody()) : _narrowBody(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({
    super.key,
    required this.index,
    required this.fields,
    required this.onHiddenChanged,
    required this.onDelete,
  });

  final int index;
  final _CaseFields fields;
  final ValueChanged<bool> onHiddenChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final mono = monoStyle.copyWith(fontSize: 14);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Caso $index', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                const Text('Oculto'),
                Switch(value: fields.hidden, onChanged: onHiddenChanged),
                IconButton(tooltip: 'Eliminar caso', icon: const Icon(Icons.delete_outline), onPressed: onDelete),
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final inputs = TextField(
                  controller: fields.inputs,
                  minLines: 3,
                  maxLines: null,
                  style: mono,
                  decoration: const InputDecoration(
                    labelText: 'Datos de entrada',
                    hintText: '8',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                );
                final expected = TextField(
                  controller: fields.expected,
                  minLines: 3,
                  maxLines: null,
                  style: mono,
                  decoration: const InputDecoration(
                    labelText: 'Salida esperada',
                    hintText: '8 es par',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                );
                if (constraints.maxWidth < 520) {
                  return Column(children: [inputs, const SizedBox(height: 12), expected]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: inputs),
                    const SizedBox(width: 12),
                    Expanded(child: expected),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final _leadingComments = RegExp(r'^\s*//\s?(.*)$');

/// "area_del_circulo" → "Area del circulo".
String titleFromProgram(String source) {
  final match = RegExp(r'^\s*(?:algoritmo|proceso)\s+(\S+)', caseSensitive: false, multiLine: true).firstMatch(source);
  final name = (match?[1] ?? 'ejercicio').replaceAll('_', ' ').trim();
  return name.isEmpty ? 'Ejercicio' : name[0].toUpperCase() + name.substring(1);
}

/// The comments at the top of the program, which usually explain it.
String statementFromProgram(String source) {
  final lines = <String>[];
  for (final line in source.split('\n')) {
    final match = _leadingComments.firstMatch(line);
    if (match == null) {
      if (line.trim().isEmpty && lines.isEmpty) continue;
      break;
    }
    lines.add(match[1]!.trim());
  }
  return lines.join(' ').replaceFirst(RegExp(r'^ejercicio:\s*', caseSensitive: false), '');
}
