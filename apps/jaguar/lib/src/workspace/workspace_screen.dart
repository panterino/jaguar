import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../challenges/challenges.dart';
import '../challenges/challenges_screen.dart';
import '../cloud/account_dialog.dart';
import '../cloud/classes_screen.dart';
import '../cloud/cloud.dart';
import '../cloud/community_screen.dart';
import '../console/desk_check_screen.dart';
import '../console/console_session.dart';
import '../console/console_view.dart';
import '../console/debug_widgets.dart';
import '../editor/auto_indent.dart';
import '../editor/code_editor.dart';
import '../editor/completions.dart';
import '../editor/keyword_bar.dart';
import '../diagram/diagram_editing.dart';
import '../diagram/diagram_view.dart';
import '../editor/syntax_controller.dart';
import '../exercises/plan_dialog.dart';
import '../exercises/exercise_banner.dart';
import '../exercises/exercise_editor_screen.dart';
import '../exercises/exercise_store.dart';
import '../exercises/exercises_screen.dart';
import '../exercises/tests_panel.dart';
import '../exercises/verified_screen.dart';
import '../files/psc_files.dart';
import '../help/privacy.dart';
import '../help/about_screen.dart';
import '../help/guide_screen.dart';
import '../programs/examples.dart';
import '../programs/program_store.dart';
import '../settings.dart';
import '../share/share_codec.dart';
import '../share/share_dialog.dart';
import '../theme.dart';
import 'app_menus.dart';
import 'mode_widgets.dart';
import 'desktop_chrome.dart';
import 'programs_drawer.dart';
import 'programs_sidebar.dart';
import 'split_view.dart';

/// Tablets in landscape show code and console side by side; phones switch
/// between them with tabs.
const _wideLayoutWidth = 900.0;

/// What the panel next to the code shows.
enum _Panel { console, tests }

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key, required this.store, required this.exercises, required this.settings, this.cloud});

  final ProgramStore store;
  final ExerciseStore exercises;
  final ViewSettings settings;

  /// Classes and community; null when Jaguar runs offline.
  final Cloud? cloud;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final SyntaxController _code = SyntaxController(text: widget.store.current.source);

  /// The program shown in the editor. Saving goes by id so a pending save
  /// never lands on a program that was just created, opened or deleted.
  late String _editingId = widget.store.current.id;
  final _codeFocus = FocusNode();
  final _undo = UndoHistoryController();
  final _editorKey = GlobalKey<CodeEditorState>();
  late final _diagnostics = Diagnostics(_code);
  final _session = ConsoleSession();
  Timer? _saveTimer;
  int _tab = 0; // narrow layout: 0 code, 1 console, 2 tests
  _Panel _panel = _Panel.console; // wide layouts
  double _diagramSplit = 0.5; // code | diagram, in "Ambos"
  bool _checking = false;

  /// The last Probar of the program in the editor, and the code it tested.
  CheckResult? _testResult;
  String? _testedSource;

  ProgramStore get _store => widget.store;
  ViewSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _code.addListener(_scheduleSave);
    _session.addListener(_onSessionChanged);
    if (_settings.chosenMode == null) WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTeacher());
  }

  @override
  void dispose() {
    _saveNow();
    _saveTimer?.cancel();
    // Before the controller it listens to; it is created here if the
    // diagram view never needed it.
    _diagnostics.dispose();
    _code.dispose();
    _codeFocus.dispose();
    _undo.dispose();
    _session.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _saveNow);
  }

  void _saveNow() {
    _saveTimer?.cancel();
    _store.update(_editingId, _code.text);
  }

  RunState _lastRunState = RunState.idle;

  void _onSessionChanged() {
    final state = _session.state;
    if (state == RunState.finished && _lastRunState != RunState.finished) _countFluentRun();
    _lastRunState = state;
    setState(() {});
  }

  /// The first-launch question; [again] reopens it to change profile
  /// (student, programmer, teacher) at any time.
  Future<void> _welcome({bool again = false}) async {
    final choice = await showWelcome(context, again: again);
    if (choice == null || !mounted) return;
    _settings.mode = choice == WelcomeChoice.learning ? AppMode.basic : AppMode.full;
    // Schools teach flowcharts first, then pseudocode. On a phone the code
    // stays and a hint shows where the diagram is.
    if (choice == WelcomeChoice.learning && !again) {
      if (MediaQuery.sizeOf(context).width >= _wideLayoutWidth) {
        _settings.editorView = EditorView.diagram;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 8),
            content: Row(
              children: [
                Icon(Icons.account_tree_outlined, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Toca este botón arriba para ver tu programa como diagrama de flujo, y otra vez para volver al código.',
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    _settings.teacher = choice == WelcomeChoice.teacher;
    if (choice == WelcomeChoice.teacher) _openTeacher();
  }

  static final _advancedCode = RegExp(r'^\s*(para|mientras|repetir|funcion|subproceso)\b', multiLine: true);

  /// After enough programs with loops or functions run without errors,
  /// suggest the full mode once. Never switch on our own.
  void _countFluentRun() {
    final settings = _settings;
    if (!settings.isBasic || settings.fullModeSuggested) return;
    if (!_advancedCode.hasMatch(normalize(_code.text))) return;
    settings.fluentRuns += 1;
    if (settings.fluentRuns < 10) return;
    settings.fullModeSuggested = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 12),
        content: const Text('Ya dominas lo básico. ¿Quieres probar el modo Completo? Puedes regresar cuando quieras.'),
        action: SnackBarAction(label: 'Probar', onPressed: () => settings.mode = AppMode.full),
      ),
    );
  }

  void _showPanel(_Panel panel) => setState(() {
    _panel = panel;
    _tab = panel == _Panel.console ? 1 : 2;
  });

  void _show(SavedProgram program) {
    _session.stop();
    _testResult = null;
    _testedSource = null;
    _panel = _Panel.console;
    _editingId = program.id;
    _code.value = TextEditingValue(text: program.source);
    _undo.value = UndoHistoryValue.empty;
    setState(() => _tab = 0);
  }

  void _load(SavedProgram program) {
    _saveNow();
    _store.select(program);
    _show(program);
  }

  void _openSource(String source) {
    _saveNow();
    _show(_store.openSource(source));
  }

  void _newProgram() {
    _saveNow();
    _show(_store.create(newProgramTemplate));
    _codeFocus.requestFocus();
  }

  void _duplicate(SavedProgram program) {
    _saveNow();
    _show(_store.create(program.source));
  }

  void _openExercise(Exercise exercise) {
    _saveNow();
    _show(_store.openExercise(exercise));
  }

  /// The exercise the program in the editor is solving, if any.
  Exercise? get _exercise {
    final id = _store.current.exerciseId;
    return id == null ? null : widget.exercises.byId(id);
  }

  /// Probar: runs every test and opens the Pruebas tab with the results.
  Future<void> _check(Exercise exercise) async {
    if (_checking) return;
    _saveNow();
    _session.stop();
    final source = _code.text;
    final programId = _editingId;
    _showPanel(_Panel.tests);
    setState(() => _checking = true);
    final result = await checkSolution(source, exercise);
    if (!mounted) return;
    _store.recordTests(programId, passed: result.passedCount, total: exercise.cases.length);
    if (result.passed && challengeById(exercise.id) != null && !_settings.doneChallenges.contains(exercise.id)) {
      _settings.markChallengeDone(exercise.id);
      _toast('¡Reto superado! Abre Retos para seguir con el siguiente.');
    }
    // Exercises from a class send their result to the teacher.
    final sent = await widget.cloud?.submitIfAssigned(
      exercise: exercise,
      studentName: widget.exercises.studentName ?? widget.cloud?.user?.alias ?? 'Alumno',
      source: source,
      result: result,
    );
    if (sent ?? false) _toast('Tu resultado llegó a tu profesor: ${result.passedCount} de ${exercise.cases.length}.');
    if (!mounted) return;
    setState(() {
      _checking = false;
      // The student may have opened another program meanwhile.
      if (programId != _editingId) return;
      _testResult = result;
      _testedSource = source;
    });
  }

  /// Shows a test running in the console, its inputs typed by themselves.
  void _replay(TestCase test) {
    _saveNow();
    _showPanel(_Panel.console);
    final name = test.name.isEmpty ? 'la prueba' : 'la prueba «${test.name}»';
    _session.run(_code.text, inputs: test.inputs, note: 'Ejecutando con los datos de $name: se escriben solos.');
  }

  Future<void> _showVerified(Exercise exercise, CheckResult result, String source) async {
    final verifiedAt = DateTime.now();
    var name = widget.exercises.studentName;
    name ??= await askStudentName(context);
    if (name == null || !mounted) return;
    widget.exercises.studentName = name;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => VerifiedScreen(
          exerciseTitle: exercise.title,
          studentName: name!,
          passedCases: result.passedCount,
          verifiedAt: verifiedAt,
          source: source,
        ),
      ),
    );
  }

  void _openTeacher() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExercisesScreen(
          store: widget.exercises,
          cloud: widget.cloud,
          onTryAsStudent: (exercise) {
            Navigator.popUntil(context, (route) => route.isFirst);
            _openExercise(exercise);
          },
        ),
      ),
    );
  }

  /// Profesor: the program in the editor becomes the solution of a new
  /// exercise, with its cases generated from it.
  void _exerciseFromProgram([SavedProgram? program]) {
    _saveNow();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExerciseEditorScreen(store: widget.exercises, fromProgram: program?.source ?? _code.text),
      ),
    );
  }

  void _openChallenges() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ChallengesScreen(
        settings: _settings,
        onOpen: (challenge) {
          widget.exercises.saveReceived(challenge.exercise);
          _openExercise(challenge.exercise);
        },
      ),
    ),
  );

  void _openCommunity() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CommunityScreen(cloud: widget.cloud, onOpenSource: _openSource, currentProgram: _code.text),
      ),
    );
  }

  void _openClasses() {
    final cloud = widget.cloud;
    if (cloud == null) {
      _toast('Las clases en línea necesitan conexión a internet.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ClassesScreen(
          cloud: cloud,
          exercises: widget.exercises,
          onOpenAssignment: (assignment) {
            widget.exercises.saveReceived(assignment.exercise);
            _openExercise(assignment.exercise);
          },
          onOpenSource: _openSource,
        ),
      ),
    );
  }

  Future<void> _account() async {
    final cloud = widget.cloud;
    if (cloud == null) {
      _toast('Sin conexión: Jaguar funciona igual, y tus programas se guardan en este equipo.');
      return;
    }
    await showAccountDialog(context, cloud);
    _syncTeacher();
  }

  /// Signing in with a teacher account turns the teacher tools on.
  void _syncTeacher() {
    if (widget.cloud?.user?.isTeacher ?? false) _settings.teacher = true;
  }

  Future<void> _shareWithCommunity() async {
    final cloud = widget.cloud;
    if (cloud == null) return;
    if (!cloud.signedIn) {
      await showAccountDialog(context, cloud);
      if (!cloud.signedIn || !mounted) return;
    }
    _saveNow();
    final published = await showDialog<bool>(
      context: context,
      builder: (_) => PublishDialog(cloud: cloud, source: _code.text),
    );
    if (published ?? false) _toast('¡Publicado! Ya está en la comunidad.');
  }

  Future<void> _changeName() async {
    final name = await askStudentName(context, current: widget.exercises.studentName);
    if (name != null) widget.exercises.studentName = name;
  }

  void _run() {
    if (_session.isRunning) {
      _session.stop();
      return;
    }
    _saveNow();
    _showPanel(_Panel.console);
    _session.run(_code.text);
  }

  /// Paso a paso (F10): starts a run that pauses before every statement,
  /// or takes the next step of the one in progress.
  void _step() {
    if (_session.isRunning) {
      if (_session.stepping && _session.state == RunState.paused) _session.nextStep();
      return;
    }
    _saveNow();
    _showPanel(_Panel.console);
    _session.run(_code.text, stepByStep: true);
  }

  /// Ejecutar hasta aquí (F4): runs and pauses at the line of the cursor
  /// (or the block selected in the diagram), as DFD does.
  void _runToCursor() {
    final line = _code.cursorPosition.$1;
    if (_session.isRunning) {
      _session.runToLine(line);
      return;
    }
    _saveNow();
    _showPanel(_Panel.console);
    _session.run(_code.text, untilLine: line);
  }

  /// The line about to run, while going step by step.
  int? get _executingLine => _session.stepping && _session.isRunning ? _session.currentLine : null;

  /// The console, with the step-by-step controls and variables when in use.
  Widget _console() {
    final console = ConsoleView(session: _session, onGoToLine: _goToLine, fontSize: _settings.fontSize);
    if (!_session.stepping) return console;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_session.isRunning && useDesktopLayout(context)) DebugBar(session: _session, onRunToCursor: _runToCursor),
        Expanded(flex: 3, child: console),
        Expanded(
          flex: 2,
          child: VariablesTable(
            variables: _session.variables,
            onEvaluate: _session.state == RunState.paused ? _session.evaluate : null,
          ),
        ),
      ],
    );
  }

  void _goToLine(int line) {
    // The line is in the code, so the code must be visible.
    if (_settings.editorView == EditorView.diagram) _settings.editorView = EditorView.code;
    setState(() => _tab = 0);
    _code.selectLine(line);
    _codeFocus.requestFocus();
  }

  Future<void> _askLine() async {
    final lineCount = '\n'.allMatches(_code.text).length + 1;
    final line = await showDialog<int>(
      context: context,
      builder: (context) => _GoToLineDialog(lineCount: lineCount, current: _code.cursorPosition.$1),
    );
    if (line == null) return;
    final offset = _code.text.split('\n').take(line - 1).fold(0, (sum, l) => sum + l.length + 1);
    _code.selection = TextSelection.collapsed(offset: offset);
    _codeFocus.requestFocus();
  }

  Future<void> _openFile() async {
    try {
      final source = await openPscFile();
      if (source != null) _openSource(source);
    } on Object catch (e) {
      _toast('No se pudo abrir el archivo: $e');
    }
  }

  Future<void> _saveFile([SavedProgram? program]) async {
    if (program == null) _saveNow();
    final source = program?.source ?? _code.text;
    try {
      if (await savePscFile(programName(source), source)) _toast('Programa guardado');
    } on Object catch (e) {
      _toast('No se pudo guardar el archivo: $e');
    }
  }

  Future<void> _sendFile() async {
    _saveNow();
    try {
      await sendPscFile(programName(_code.text), _code.text);
    } on Object catch (e) {
      _toast('No se pudo enviar el archivo: $e');
    }
  }

  void _share() => showShareDialog(context, name: programName(_code.text), source: _code.text);

  Future<void> _openLink() async {
    switch (await showOpenLinkDialog(context)) {
      case SharedProgram(:final source):
        _openSource(source);
      case SharedExercise(:final exercise):
        widget.exercises.saveReceived(exercise);
        _openExercise(exercise);
      case null:
        break;
    }
  }

  /// Runs an editor command from the menu, showing the code if needed.
  void _withEditor(void Function(CodeEditorState editor) command) {
    if (_settings.editorView == EditorView.diagram) _settings.editorView = EditorView.both;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocus.requestFocus();
      final editor = _editorKey.currentState;
      if (editor != null) command(editor);
    });
  }

  // Editar: the menu acts on the editor even when the click took the focus.

  void _editorCommand(void Function() command) {
    _codeFocus.requestFocus();
    command();
  }

  Future<void> _copy({required bool cut}) async {
    final selection = _code.selection;
    if (!selection.isValid || selection.isCollapsed) return;
    await Clipboard.setData(ClipboardData(text: selection.textInside(_code.text)));
    if (cut) {
      _code.value = TextEditingValue(
        text: selection.textBefore(_code.text) + selection.textAfter(_code.text),
        selection: TextSelection.collapsed(offset: selection.start),
      );
    }
    _codeFocus.requestFocus();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    _editorCommand(() => _code.insertSnippet(text.replaceAll('\r\n', '\n').replaceAll('§', '')));
  }

  void _showAbout() => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AboutScreen()));

  /// Writes the planteamiento as comments at the top of the program.
  Future<void> _plan() async {
    final plan = await showPlanDialog(context, readPlan(_code.text), statement: _exercise?.statement);
    if (plan == null || !mounted) return;
    final before = _code.text;
    final after = writePlan(before, plan);
    if (after == before) return;
    final offset = _code.selection.isValid ? _code.selection.baseOffset + after.length - before.length : 0;
    _code.value = TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: offset.clamp(0, after.length)),
    );
  }

  void _deskCheck() {
    _saveNow();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DeskCheckScreen(name: programName(_code.text), source: _code.text),
      ),
    );
  }

  void _showGuide() => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const GuideScreen()));

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<AppMenu> _menus({required bool desktop}) {
    final running = _session.isRunning;
    final exercise = _exercise;
    final settings = _settings;
    return [
      AppMenu('Archivo', [
        AppMenuItem(
          'Nuevo programa',
          icon: Icons.note_add_outlined,
          onSelected: _newProgram,
          // Browsers keep Ctrl+N for a new window.
          shortcut: kIsWeb ? null : primary(LogicalKeyboardKey.keyN),
        ),
        AppMenuItem(
          'Abrir archivo .psc…',
          icon: Icons.folder_open_outlined,
          onSelected: _openFile,
          shortcut: primary(LogicalKeyboardKey.keyO),
        ),
        AppMenuItem('Abrir enlace…', icon: Icons.link, onSelected: _openLink),
        const AppMenuDivider(),
        AppMenuItem('Planteamiento (entrada, proceso, salida)…', icon: Icons.edit_note, onSelected: _plan),
        const AppMenuDivider(),
        AppMenuItem(
          'Guardar como .psc…',
          icon: Icons.save_alt,
          onSelected: _saveFile,
          shortcut: primary(LogicalKeyboardKey.keyS),
        ),
        AppMenuItem('Compartir con QR o enlace…', icon: Icons.qr_code_2, onSelected: _share),
        if (widget.cloud != null)
          AppMenuItem('Publicar en la comunidad…', icon: Icons.public, onSelected: _shareWithCommunity),
      ]),
      AppMenu('Editar', [
        AppMenuItem(
          'Deshacer',
          icon: Icons.undo,
          onSelected: () => _editorCommand(_undo.undo),
          shortcut: primary(LogicalKeyboardKey.keyZ),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Rehacer',
          icon: Icons.redo,
          onSelected: () => _editorCommand(_undo.redo),
          shortcut: primary(LogicalKeyboardKey.keyZ, shift: true),
          textFieldHandles: true,
        ),
        const AppMenuDivider(),
        AppMenuItem(
          'Cortar',
          icon: Icons.content_cut,
          onSelected: () => _copy(cut: true),
          shortcut: primary(LogicalKeyboardKey.keyX),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Copiar',
          icon: Icons.content_copy,
          onSelected: () => _copy(cut: false),
          shortcut: primary(LogicalKeyboardKey.keyC),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Pegar',
          icon: Icons.content_paste,
          onSelected: _paste,
          shortcut: primary(LogicalKeyboardKey.keyV),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Seleccionar todo',
          icon: Icons.select_all,
          onSelected: () =>
              _editorCommand(() => _code.selection = TextSelection(baseOffset: 0, extentOffset: _code.text.length)),
          shortcut: primary(LogicalKeyboardKey.keyA),
          textFieldHandles: true,
        ),
        const AppMenuDivider(),
        AppMenuItem(
          'Comentar o descomentar',
          icon: Icons.notes,
          onSelected: () => _editorCommand(_code.toggleComment),
          shortcut: primary(LogicalKeyboardKey.slash),
          // On Spanish keyboards "/" is Shift+7.
          extraShortcuts: [primary(LogicalKeyboardKey.slash, shift: true)],
        ),
        AppMenuItem(
          'Aumentar sangría',
          icon: Icons.format_indent_increase,
          onSelected: () => _editorCommand(() => _code.indentLines(indentUnit)),
          shortcut: const SingleActivator(LogicalKeyboardKey.tab),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Reducir sangría',
          icon: Icons.format_indent_decrease,
          onSelected: () => _editorCommand(() => _code.dedentLines(indentUnit)),
          shortcut: const SingleActivator(LogicalKeyboardKey.tab, shift: true),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Ordenar sangría',
          icon: Icons.format_align_left,
          onSelected: () => _withEditor((e) => e.reindentAll()),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyF, alt: true, shift: true),
          textFieldHandles: true,
        ),
        const AppMenuDivider(),
        AppMenuItem(
          'Mover línea arriba',
          icon: Icons.arrow_upward,
          onSelected: () => _withEditor((e) => e.moveLinesBy(up: true)),
          shortcut: const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Mover línea abajo',
          icon: Icons.arrow_downward,
          onSelected: () => _withEditor((e) => e.moveLinesBy(up: false)),
          shortcut: const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Duplicar línea',
          icon: Icons.copy_all_outlined,
          onSelected: () => _withEditor((e) => e.duplicate()),
          shortcut: const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true, shift: true),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Eliminar línea',
          icon: Icons.backspace_outlined,
          onSelected: () => _withEditor((e) => e.deleteLine()),
          shortcut: primary(LogicalKeyboardKey.keyK, shift: true),
          textFieldHandles: true,
        ),
        const AppMenuDivider(),
        AppMenuItem(
          'Buscar…',
          icon: Icons.search,
          onSelected: () => _withEditor((e) => e.openFind()),
          shortcut: primary(LogicalKeyboardKey.keyF),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Reemplazar…',
          icon: Icons.find_replace,
          onSelected: () => _withEditor((e) => e.openFind(replace: true)),
          shortcut: primary(LogicalKeyboardKey.keyH),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Renombrar variable…',
          icon: Icons.drive_file_rename_outline,
          onSelected: () => _withEditor((e) => e.renameAtCursor()),
          shortcut: const SingleActivator(LogicalKeyboardKey.f2),
          textFieldHandles: true,
        ),
        AppMenuItem(
          'Sugerencias',
          icon: Icons.auto_awesome_outlined,
          onSelected: () => _withEditor((e) => e.suggest()),
          shortcut: const SingleActivator(LogicalKeyboardKey.space, control: true),
          textFieldHandles: true,
        ),
        const AppMenuDivider(),
        AppMenuItem(
          'Ir a la línea…',
          icon: Icons.format_list_numbered,
          onSelected: _askLine,
          shortcut: primary(LogicalKeyboardKey.keyG),
        ),
      ]),
      AppMenu('Ejecutar', [
        AppMenuItem(
          'Ejecutar',
          icon: Icons.play_arrow,
          onSelected: running ? null : _run,
          shortcut: primary(LogicalKeyboardKey.enter),
          // F9 as in PSeInt.
          extraShortcuts: [const SingleActivator(LogicalKeyboardKey.f9), const SingleActivator(LogicalKeyboardKey.f5)],
        ),
        AppMenuItem(
          'Detener',
          icon: Icons.stop,
          onSelected: running ? _session.stop : null,
          shortcut: const SingleActivator(LogicalKeyboardKey.f9, shift: true),
          extraShortcuts: [const SingleActivator(LogicalKeyboardKey.f5, shift: true)],
        ),
        AppMenuItem(
          _session.stepping && running ? 'Siguiente paso' : 'Paso a paso',
          icon: Icons.directions_walk,
          onSelected: running && !(_session.stepping && _session.state == RunState.paused) ? null : _step,
          shortcut: const SingleActivator(LogicalKeyboardKey.f10),
          // F7 is DFD's Paso simple.
          extraShortcuts: [const SingleActivator(LogicalKeyboardKey.f7)],
        ),
        AppMenuItem(
          'Ejecutar hasta aquí',
          icon: Icons.vertical_align_bottom,
          onSelected: running && _session.state != RunState.paused ? null : _runToCursor,
          shortcut: const SingleActivator(LogicalKeyboardKey.f4),
        ),
        AppMenuItem(
          'Pausar',
          icon: Icons.pause,
          onSelected: running && !_session.stepping ? _session.pause : null,
          shortcut: const SingleActivator(LogicalKeyboardKey.pause),
        ),
        AppMenuItem('Prueba de escritorio…', icon: Icons.table_chart_outlined, onSelected: _deskCheck),
        const AppMenuDivider(),
        AppMenuItem(
          'Probar',
          icon: Icons.fact_check_outlined,
          onSelected: exercise == null ? null : () => _check(exercise),
          shortcut: primary(LogicalKeyboardKey.enter, shift: true),
        ),
        const AppMenuDivider(),
        AppMenuItem(
          'Limpiar consola',
          icon: Icons.clear_all,
          onSelected: running || _session.state == RunState.idle ? null : _session.clearOutput,
        ),
      ]),
      if (desktop)
        AppMenu('Ver', [
          AppMenuItem(
            'Panel de programas',
            checked: settings.sidebar,
            onSelected: settings.isBasic ? null : () => settings.sidebar = !settings.sidebar,
            shortcut: primary(LogicalKeyboardKey.keyB),
          ),
          AppMenuItem(
            'Consola a la derecha',
            checked: !settings.consoleBelow,
            onSelected: () => settings.consoleBelow = false,
          ),
          AppMenuItem('Consola abajo', checked: settings.consoleBelow, onSelected: () => settings.consoleBelow = true),
          const AppMenuDivider(),
          AppMenuItem(
            'Pseudocódigo',
            checked: settings.editorView == EditorView.code,
            onSelected: () => settings.editorView = EditorView.code,
            shortcut: primary(LogicalKeyboardKey.digit1, alt: true),
          ),
          AppMenuItem(
            'Diagrama de flujo',
            checked: settings.editorView == EditorView.diagram,
            onSelected: () => settings.editorView = EditorView.diagram,
            shortcut: primary(LogicalKeyboardKey.digit2, alt: true),
          ),
          AppMenuItem(
            'Pseudocódigo y diagrama',
            checked: settings.editorView == EditorView.both,
            onSelected: () => settings.editorView = EditorView.both,
            shortcut: primary(LogicalKeyboardKey.digit3, alt: true),
          ),
          AppMenuItem(
            'Barra de palabras clave',
            checked: settings.keywordBar,
            onSelected: () => settings.keywordBar = !settings.keywordBar,
          ),
          const AppMenuDivider(),
          AppMenuItem(
            'Letra más grande',
            icon: Icons.text_increase,
            onSelected: () => settings.fontSize += 1,
            shortcut: primary(LogicalKeyboardKey.equal),
            extraShortcuts: [
              primary(LogicalKeyboardKey.equal, shift: true), // "=" is Shift+0 on Spanish keyboards
              primary(LogicalKeyboardKey.add),
              primary(LogicalKeyboardKey.numpadAdd),
            ],
          ),
          AppMenuItem(
            'Letra más pequeña',
            icon: Icons.text_decrease,
            onSelected: () => settings.fontSize -= 1,
            shortcut: primary(LogicalKeyboardKey.minus),
            extraShortcuts: [primary(LogicalKeyboardKey.numpadSubtract)],
          ),
          AppMenuItem(
            'Tamaño normal',
            icon: Icons.format_size,
            onSelected: () => settings.fontSize = 14,
            shortcut: primary(LogicalKeyboardKey.digit0),
          ),
          const AppMenuDivider(),
          AppSubmenu('Tema', [
            for (final (mode, label) in const [
              (ThemeMode.system, 'Como el sistema'),
              (ThemeMode.light, 'Claro'),
              (ThemeMode.dark, 'Oscuro'),
            ])
              AppMenuItem(label, checked: settings.themeMode == mode, onSelected: () => settings.themeMode = mode),
          ]),
        ]),
      if (_settings.teacher)
        AppMenu('Profesor', [
          AppMenuItem(
            'Crear ejercicio con este programa…',
            icon: Icons.auto_awesome,
            onSelected: () => _exerciseFromProgram(),
          ),
          AppMenuItem('Mis ejercicios…', icon: Icons.school_outlined, onSelected: _openTeacher),
          if (widget.cloud != null) AppMenuItem('Mis clases…', icon: Icons.groups_outlined, onSelected: _openClasses),
          AppMenuItem('Mi nombre para los ejercicios…', icon: Icons.badge_outlined, onSelected: _changeName),
        ]),
      AppMenu('Ayuda', [
        AppMenuItem(
          'Guía rápida',
          icon: Icons.menu_book_outlined,
          onSelected: _showGuide,
          shortcut: const SingleActivator(LogicalKeyboardKey.f1),
        ),
        AppMenuItem('Retos para practicar…', icon: Icons.flag_outlined, onSelected: _openChallenges),
        AppMenuItem('Comunidad y ejemplos…', icon: Icons.public, onSelected: _openCommunity),
        AppMenuItem(
          'Cambiar cómo uso Jaguar (alumno, profesor…)',
          icon: Icons.swap_horiz,
          onSelected: () => _welcome(again: true),
        ),
        AppMenuItem(
          'Aviso de privacidad',
          icon: Icons.privacy_tip_outlined,
          onSelected: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PrivacyScreen())),
        ),
        AppSubmenu('Ejemplos', [
          for (final (title, source) in examples) AppMenuItem(title, onSelected: () => _openSource(source)),
        ]),
        if (!usePlatformMenus) ...[
          const AppMenuDivider(),
          AppMenuItem('Acerca de Jaguar', icon: Icons.info_outline, onSelected: _showAbout),
        ],
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final desktop = useDesktopLayout(context);
        final menus = _menus(desktop: desktop);
        // Básico shows fewer menus, but every shortcut keeps working.
        final shownMenus = _settings.isBasic
            ? [
                for (final menu in menus)
                  if (const {'Archivo', 'Ejecutar', 'Ayuda'}.contains(menu.label)) menu,
              ]
            : menus;
        Widget screen = CallbackShortcuts(
          bindings: menuShortcuts(menus),
          // Shortcuts work as soon as the window opens, before any click.
          child: Focus(autofocus: true, child: desktop ? _buildDesktop(shownMenus) : _buildTouch()),
        );
        // The browser tab and the task switcher show the program's name.
        screen = ListenableBuilder(
          listenable: _code,
          builder: (context, child) =>
              Title(title: '${programName(_code.text)} — Jaguar', color: jaguarYellow, child: child!),
          child: screen,
        );
        if (desktop && usePlatformMenus) {
          screen = PlatformMenuBar(
            menus: platformMenus(shownMenus, appName: 'Jaguar', onAbout: _showAbout),
            child: screen,
          );
        }
        return screen;
      },
    );
  }

  Widget _buildDesktop(List<AppMenu> menus) {
    final scheme = Theme.of(context).colorScheme;
    final settings = _settings;
    // Básico keeps one layout: programs on the left, console on the right
    // and the keyword bar as a reminder of the syntax.
    final basic = settings.isBasic;
    final consoleBelow = basic || settings.consoleBelow;
    final showSidebar = basic || settings.sidebar;
    final exercise = _exercise;
    final running = _session.isRunning;
    final errorLine = _session.state == RunState.failed ? _session.error?.line : null;

    final codePane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CodeEditor(
            key: _editorKey,
            diagnostics: _diagnostics,
            controller: _code,
            focusNode: _codeFocus,
            undoController: _undo,
            errorLine: errorLine,
            executingLine: _executingLine,
            fontSize: settings.fontSize,
            highlightCurrentLine: true,
          ),
        ),
        if (basic || settings.keywordBar) KeywordBar(controller: _code, focusNode: _codeFocus),
      ],
    );

    final editor = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditorTab(code: _code, isExercise: exercise != null),
        if (exercise != null)
          ExerciseBanner(
            onHints: challengeById(exercise.id) == null ? null : () => showHints(context, challengeById(exercise.id)!),
            onPlan: _plan,
            key: ValueKey(exercise.id),
            exercise: exercise,
            checking: _checking,
            onCheck: () => _check(exercise),
            showCheckButton: false,
          ),
        Expanded(
          child: switch (settings.editorView) {
            EditorView.code => codePane,
            EditorView.diagram => _diagram(),
            EditorView.both => SplitView(
              axis: Axis.horizontal,
              fraction: _diagramSplit,
              onChanged: (fraction) => setState(() => _diagramSplit = fraction),
              onReset: () => setState(() => _diagramSplit = 0.5),
              minFirst: 240,
              minSecond: 200,
              first: codePane,
              second: _diagram(),
            ),
          },
        ),
      ],
    );

    final console = _panelArea(
      actions: [
        if (!basic)
          ToolbarIcon(
            icon: consoleBelow ? Icons.vertical_split_outlined : Icons.horizontal_split_outlined,
            size: 18,
            tooltip: consoleBelow ? 'Poner la consola a la derecha' : 'Poner la consola abajo',
            onPressed: () => settings.consoleBelow = !consoleBelow,
          ),
      ],
    );

    final workArea = SplitView(
      axis: consoleBelow ? Axis.vertical : Axis.horizontal,
      fraction: settings.split,
      onChanged: (fraction) => settings.split = fraction,
      onReset: () => settings.split = 0.6,
      minFirst: 240,
      minSecond: 140,
      first: editor,
      second: console,
    );

    final sidebar = ProgramsSidebar(
      store: _store,
      exercises: widget.exercises,
      onSelect: _load,
      onNew: _newProgram,
      onDuplicate: _duplicate,
      onSaveFile: _saveFile,
      onMakeExercise: _settings.teacher ? _exerciseFromProgram : null,
      cloud: widget.cloud,
      onOpenCommunity: _openCommunity,
      onOpenChallenges: _openChallenges,
      onOpenClasses: _openClasses,
      onAccount: _account,
      onOpenTeacher: _settings.teacher ? _openTeacher : null,
      onChangeName: _settings.teacher ? null : _changeName,
      teacher: _settings.teacher,
      onChangeProfile: () => _welcome(again: true),
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!usePlatformMenus)
            AppMenuBar(
              menus: menus,
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Image.asset('assets/images/mascota.png', width: 20, height: 20),
              ),
            ),
          DesktopToolbar(
            sidebarVisible: showSidebar,
            basic: basic,
            modeSwitch: ModeSwitch(settings: settings),
            running: running,
            onToggleSidebar: () => settings.sidebar = !settings.sidebar,
            onNew: _newProgram,
            onOpenFile: _openFile,
            onSaveFile: _saveFile,
            onRun: _run,
            viewSwitch: _EditorViewSwitch(settings: settings, allowBoth: true),
            onPause: running && !_session.stepping ? _session.pause : null,
            onShare: _share,
            onCheck: exercise == null ? null : () => _check(exercise),
            checking: _checking,
          ),
          Expanded(
            child: showSidebar
                ? LayoutBuilder(
                    builder: (context, constraints) => SplitView(
                      axis: Axis.horizontal,
                      fraction: settings.sidebarWidth / constraints.maxWidth,
                      onChanged: (fraction) => settings.sidebarWidth = fraction * constraints.maxWidth,
                      onReset: () => settings.sidebarWidth = 240,
                      minFirst: 160,
                      minSecond: 480,
                      first: sidebar,
                      second: workArea,
                    ),
                  )
                : workArea,
          ),
          StatusBar(
            session: _session,
            code: _code,
            diagnostics: _diagnostics,
            onGoToLine: _goToLine,
            onAskLine: _askLine,
            basic: basic,
          ),
        ],
      ),
    );
  }

  /// Tapping a block selects its line. With the code beside it, the code
  /// gets the focus so the selection shows; otherwise nothing moves.
  Widget _diagram() => DiagramView(
    code: _code,
    executingLine: _executingLine,
    notation: _settings.notation,
    onNotationChanged: (notation) => _settings.notation = notation,
    // While a program runs the diagram shows where it goes; editing waits.
    editing: _session.isRunning ? null : DiagramEditing(code: _code, notation: _settings.notation),
    onUndo: _session.isRunning ? null : _undo.undo,
    onTapLine: (line) {
      _code.selectLine(line);
      if (_settings.editorView == EditorView.both && useDesktopLayout(context)) _codeFocus.requestFocus();
    },
  );

  /// Consola and, when the program has tests, Pruebas.
  Widget _panelArea({List<Widget> actions = const []}) {
    final exercise = _exercise;
    final running = _session.isRunning;
    final showTests = exercise != null && _panel == _Panel.tests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: _code,
          builder: (context, _) => PanelTabs(
            tabs: [
              (
                label: 'Consola',
                badge: null,
                badgeColor: null,
                selected: !showTests,
                onTap: () => _showPanel(_Panel.console),
              ),
              if (exercise != null) _testsTab(exercise, selected: showTests),
            ],
            actions: [
              if (!showTests)
                ToolbarIcon(
                  icon: Icons.clear_all,
                  size: 18,
                  tooltip: 'Limpiar consola',
                  onPressed: running || _session.state == RunState.idle ? null : _session.clearOutput,
                ),
              ...actions,
            ],
          ),
        ),
        Expanded(child: showTests ? _testsPanel(exercise) : _console()),
      ],
    );
  }

  bool get _testsStale => _testResult != null && _testedSource != _code.text;

  PanelTab _testsTab(Exercise exercise, {required bool selected}) {
    final result = _testResult;
    final allPassed = result != null && result.passed && !_testsStale;
    return (
      label: 'Pruebas',
      badge: result == null ? '${exercise.cases.length}' : '${result.passedCount}/${exercise.cases.length}',
      badgeColor: result == null || _testsStale
          ? null
          : allPassed
          ? Colors.green.shade700
          : Theme.of(context).colorScheme.error,
      selected: selected,
      onTap: () => _showPanel(_Panel.tests),
    );
  }

  Widget _testsPanel(Exercise exercise) => ListenableBuilder(
    listenable: _code,
    builder: (context, _) => TestsPanel(
      exercise: exercise,
      result: _testResult,
      running: _checking,
      stale: _testsStale,
      onRunTests: () => _check(exercise),
      onGoToLine: _goToLine,
      onReplay: _replay,
      onShowTeacher: () => _showVerified(exercise, _testResult!, _testedSource!),
    ),
  );

  Widget _buildTouch() {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _wideLayoutWidth;
    // On phones the program name needs the room: Ejecutar becomes an icon.
    final compact = width < 480;
    final scheme = Theme.of(context).colorScheme;
    // Two points smaller on phones, so most lines fit without scrolling.
    final fontSize = wide ? _settings.fontSize : _settings.fontSize - 2;
    final running = _session.isRunning;
    final errorLine = _session.state == RunState.failed ? _session.error?.line : null;
    final exercise = _exercise;

    final editor = Column(
      children: [
        if (exercise != null)
          ExerciseBanner(
            onHints: challengeById(exercise.id) == null ? null : () => showHints(context, challengeById(exercise.id)!),
            onPlan: _plan,
            key: ValueKey(exercise.id),
            exercise: exercise,
            checking: _checking,
            onCheck: () => _check(exercise),
          ),
        if (_settings.editorView == EditorView.diagram)
          Expanded(child: _diagram())
        else ...[
          Expanded(
            child: CodeEditor(
              key: _editorKey,
              diagnostics: _diagnostics,
              controller: _code,
              focusNode: _codeFocus,
              undoController: _undo,
              errorLine: errorLine,
              executingLine: _executingLine,
              fontSize: fontSize,
            ),
          ),
          KeywordBar(controller: _code, focusNode: _codeFocus),
        ],
      ],
    );
    final console = _console();
    // Phones: Pruebas is a third tab at the bottom.
    final tab = exercise == null && _tab == 2 ? 1 : _tab;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: ListenableBuilder(
          listenable: _code,
          builder: (context, _) => Text(programName(_code.text), overflow: TextOverflow.ellipsis),
        ),
        actions: [
          IconButton(tooltip: 'Compartir (QR o enlace)', icon: const Icon(Icons.qr_code_2), onPressed: _share),
          // Phones switch between the code and its flowchart from here.
          IconButton(
            tooltip: _settings.editorView == EditorView.diagram ? 'Ver pseudocódigo' : 'Ver diagrama de flujo',
            icon: Icon(_settings.editorView == EditorView.diagram ? Icons.code : Icons.account_tree_outlined),
            onPressed: () => _settings.editorView = _settings.editorView == EditorView.diagram
                ? EditorView.code
                : EditorView.diagram,
          ),
          if (wide) ...[
            IconButton(tooltip: 'Abrir .psc', icon: const Icon(Icons.folder_open), onPressed: _openFile),
            IconButton(tooltip: 'Guardar .psc', icon: const Icon(Icons.save_alt), onPressed: _saveFile),
          ],
          _MoreMenu(
            onNew: _newProgram,
            onOpenFile: _openFile,
            onSaveFile: _saveFile,
            onSendFile: _sendFile,
            onOpenLink: _openLink,
            onDeskCheck: _deskCheck,
            onPlan: _plan,
          ),
          if (compact)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filled(
                tooltip: running ? 'Detener' : 'Ejecutar',
                onPressed: _run,
                icon: Icon(running ? Icons.stop : Icons.play_arrow),
                // Explicit colors: the app bar tints its action icons.
                style: IconButton.styleFrom(
                  backgroundColor: running ? scheme.error : scheme.primary,
                  foregroundColor: running ? scheme.onError : scheme.onPrimary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: FilledButton.icon(
                onPressed: _run,
                icon: Icon(running ? Icons.stop : Icons.play_arrow),
                label: Text(running ? 'Detener' : 'Ejecutar'),
                style: running
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      )
                    : null,
              ),
            ),
        ],
      ),
      drawer: ProgramsDrawer(
        store: _store,
        cloud: widget.cloud,
        onOpenCommunity: _openCommunity,
        onOpenChallenges: _openChallenges,
        onOpenClasses: _openClasses,
        onAccount: _account,
        onGuide: _showGuide,
        onAbout: _showAbout,
        modeSwitch: ModeSwitch(settings: _settings, dense: false),
        exercises: widget.exercises,
        onSelect: _load,
        onNew: _newProgram,
        onOpenTeacher: _settings.teacher ? _openTeacher : null,
        onChangeName: _settings.teacher ? null : _changeName,
        onToggleTeacher: () => _welcome(again: true),
        teacher: _settings.teacher,
      ),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 3, child: editor),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _panelArea()),
              ],
            )
          : IndexedStack(
              index: tab,
              children: [editor, console, if (exercise != null) _testsPanel(exercise) else const SizedBox.shrink()],
            ),
      bottomNavigationBar: wide
          ? (_session.stepping && running ? DebugBar(session: _session, onRunToCursor: _runToCursor) : null)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_session.stepping && running) DebugBar(session: _session, onRunToCursor: _runToCursor),
                NavigationBar(
                  height: 60,
                  selectedIndex: tab,
                  onDestinationSelected: (tab) => setState(() {
                    _tab = tab;
                    if (tab > 0) _panel = tab == 1 ? _Panel.console : _Panel.tests;
                  }),
                  destinations: [
                    const NavigationDestination(icon: Icon(Icons.code), label: 'Código'),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: _session.state == RunState.waitingInput || _session.state == RunState.failed,
                        child: const Icon(Icons.terminal),
                      ),
                      label: 'Consola',
                    ),
                    if (exercise != null)
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: _testResult != null,
                          label: Text('${_testResult?.passedCount ?? 0}/${exercise.cases.length}'),
                          backgroundColor: _testResult?.passed == true ? Colors.green.shade700 : null,
                          child: const Icon(Icons.fact_check_outlined),
                        ),
                        label: 'Pruebas',
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// The program's name above the code, like an editor tab.
class _EditorTab extends StatelessWidget {
  const _EditorTab({required this.code, required this.isExercise});

  final SyntaxController code;
  final bool isExercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(color: scheme.primary, width: 2),
                  right: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExercise ? Icons.assignment_outlined : Icons.description_outlined,
                    size: 15,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: ListenableBuilder(
                      listenable: code,
                      builder: (context, _) => Text(
                        '${programName(code.text)}.psc',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// `Pseudocódigo | Diagrama | Ambos`, in the toolbar.
class _EditorViewSwitch extends StatelessWidget {
  const _EditorViewSwitch({required this.settings, required this.allowBoth});

  final ViewSettings settings;
  final bool allowBoth;

  static const _labels = {EditorView.code: 'Pseudocódigo', EditorView.diagram: 'Diagrama', EditorView.both: 'Ambos'};
  static const _icons = {
    EditorView.code: Icons.code,
    EditorView.diagram: Icons.account_tree_outlined,
    EditorView.both: Icons.vertical_split_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final view = !allowBoth && settings.editorView == EditorView.both ? EditorView.code : settings.editorView;
    return SegmentedButton<EditorView>(
      segments: [
        for (final option in [EditorView.code, EditorView.diagram, if (allowBoth) EditorView.both])
          ButtonSegment(
            value: option,
            icon: Icon(_icons[option], size: 16),
            // Icons only, in the toolbar; the names are in the tooltips.
            tooltip: _labels[option],
          ),
      ],
      selected: {view},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => settings.editorView = selection.single,
      style: SegmentedButton.styleFrom(
        visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
        textStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class _GoToLineDialog extends StatefulWidget {
  const _GoToLineDialog({required this.lineCount, required this.current});

  final int lineCount;
  final int current;

  @override
  State<_GoToLineDialog> createState() => _GoToLineDialogState();
}

class _GoToLineDialogState extends State<_GoToLineDialog> {
  late final _field = TextEditingController(text: '${widget.current}')
    ..selection = TextSelection(baseOffset: 0, extentOffset: '${widget.current}'.length);
  String? _error;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    final line = int.tryParse(_field.text.trim());
    if (line == null || line < 1 || line > widget.lineCount) {
      setState(() => _error = 'Escribe un número del 1 al ${widget.lineCount}');
      return;
    }
    Navigator.pop(context, line);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ir a la línea'),
      content: SizedBox(
        width: 280,
        child: TextField(
          controller: _field,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Línea (1 a ${widget.lineCount})', errorText: _error),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: const Text('Ir')),
      ],
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({
    required this.onNew,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onSendFile,
    required this.onOpenLink,
    required this.onDeskCheck,
    required this.onPlan,
  });

  final VoidCallback onNew;
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onSendFile;
  final VoidCallback onDeskCheck;
  final VoidCallback onPlan;
  final VoidCallback onOpenLink;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, _) => IconButton(
        tooltip: 'Más opciones',
        icon: const Icon(Icons.more_vert),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(leadingIcon: const Icon(Icons.edit_note), onPressed: onPlan, child: const Text('Planteamiento')),
        MenuItemButton(
          leadingIcon: const Icon(Icons.table_chart_outlined),
          onPressed: onDeskCheck,
          child: const Text('Prueba de escritorio'),
        ),
        const Divider(height: 1),
        MenuItemButton(leadingIcon: const Icon(Icons.add), onPressed: onNew, child: const Text('Nuevo programa')),
        MenuItemButton(
          leadingIcon: const Icon(Icons.folder_open),
          onPressed: onOpenFile,
          child: const Text('Abrir archivo .psc'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.save_alt),
          onPressed: onSaveFile,
          child: const Text('Guardar como .psc'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.send_outlined),
          onPressed: onSendFile,
          child: const Text('Enviar .psc (WhatsApp, correo…)'),
        ),
        MenuItemButton(leadingIcon: const Icon(Icons.link), onPressed: onOpenLink, child: const Text('Abrir enlace')),
      ],
    );
  }
}
