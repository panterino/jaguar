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
import '../share/scan_screen.dart';
import '../share/share_dialog.dart';
import '../theme.dart';
import 'app_menus.dart';
import 'intro_sheet.dart';
import 'mode_widgets.dart';
import 'desktop_chrome.dart';
import '../lessons/lesson_screen.dart';
import '../lessons/lessons.dart';
import 'programs_drawer.dart';
import 'rooms.dart';
import 'programs_sidebar.dart';
import 'settings_screen.dart';
import 'start_panel.dart';
import 'split_view.dart';
import 'tour.dart';

/// Tablets in landscape show code and console side by side; phones switch
/// between them with tabs.
const _wideLayoutWidth = 900.0;

/// What the panel next to the code shows.
enum _Panel { console, tests }

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.store,
    required this.exercises,
    required this.settings,
    this.cloud,
    this.startInEditor = false,
  });

  final ProgramStore store;
  final ExerciseStore exercises;
  final ViewSettings settings;

  /// Classes and community; null when Jaguar runs offline.
  final Cloud? cloud;

  /// On a phone, open the editor instead of the rooms: the app was launched
  /// with a program or an exercise from a link.
  final bool startInEditor;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> with WidgetsBindingObserver {
  late final SyntaxController _code = SyntaxController(text: widget.store.current.source);

  /// The program shown in the editor. Saving goes by id so a pending save
  /// never lands on a program that was just created, opened or deleted.
  late String _editingId = widget.store.current.id;
  final _codeFocus = FocusNode();
  final _undo = UndoHistoryController();
  final _editorKey = GlobalKey<CodeEditorState>();
  late final _diagnostics = Diagnostics(_code);
  final _session = ConsoleSession();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// The play button, for the first-launch balloons.
  final _runKey = GlobalKey();
  final _firstLineKey = GlobalKey();
  final _testsTabKey = GlobalKey();

  /// True while [_show] puts a program in the editor, which is not typing.
  bool _loading = false;

  /// When Atrás was last pressed on the main screen: a second press soon
  /// after closes the app.
  DateTime? _lastBack;
  Timer? _saveTimer;
  int _tab = 0; // narrow layout: 0 code, 1 console, 2 tests

  /// Phones: the room on screen, and whether the editor covers the rooms.
  Room? _roomChoice;

  /// The room on screen. Until one is picked: the Taller on a wide screen (the
  /// editor, as always) or when a link brought a program; Inicio on a phone.
  Room get _room =>
      _roomChoice ??
      (widget.startInEditor || MediaQuery.sizeOf(context).width >= _wideLayoutWidth ? Room.workshop : Room.home);
  late bool _inEditor = widget.startInEditor;
  _Panel _panel = _Panel.console; // wide layouts
  double _diagramSplit = 0.5; // code | diagram, in "Ambos"
  bool _checking = false;

  /// The last Probar of the program in the editor, and the code it tested.
  CheckResult? _testResult;
  String? _testedSource;

  /// Results by program, so they survive opening another program and coming
  /// back (and, through [SavedProgram.testedSource], restarting the app).
  final _results = <String, (CheckResult, String)>{};

  ProgramStore get _store => widget.store;
  ViewSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _code.addListener(_scheduleSave);
    _code.addListener(_onTyped);
    _session.addListener(_onSessionChanged);
    if (_settings.chosenMode == null) WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTeacher());
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreTests(_store.current));
  }

  /// Android can end the process right after the app goes to the background,
  /// before the delayed save of [_scheduleSave] runs.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _saveNow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveNow();
    _saveTimer?.cancel();
    _hintTimer?.cancel();
    // Before the controller it listens to; it is created here if the
    // diagram view never needed it.
    _diagnostics.dispose();
    _code.dispose();
    _codeFocus.dispose();
    _undo.dispose();
    _session.dispose();
    super.dispose();
  }

  void _onTyped() {
    if (!_loading) _tourAdvance(0);
  }

  // The first-launch balloons: write, run, tests. Each one goes away when
  // the person does what it says.

  bool get _tourActive => _settings.tourStep < 3 && !_store.isEmpty && _exercise?.id == challenges.first.id;

  void _tourAdvance(int from) {
    if (_settings.tourStep == from) _settings.tourStep = from + 1;
  }

  Widget? _tourBalloon() {
    if (!_tourActive) return null;
    void onSkip() => _settings.tourStep = 3;
    return switch (_settings.tourStep) {
      0 when _tab == 0 && _settings.editorView != EditorView.diagram => TourBalloon(
        key: const ValueKey('tour-0'),
        target: _firstLineKey,
        arrow: TourArrow.up,
        text: 'Escribe aquí tu programa. Cada instrucción va en su línea.',
        onSkip: onSkip,
        onGotIt: () => _tourAdvance(0),
      ),
      1 => TourBalloon(
        key: const ValueKey('tour-1'),
        target: _runKey,
        arrow: TourArrow.up,
        text: 'Toca Ejecutar, el triángulo de arriba, para correr tu programa.',
        onSkip: onSkip,
      ),
      2 when _tab != 2 => TourBalloon(
        key: const ValueKey('tour-2'),
        target: _testsTabKey,
        arrow: TourArrow.down,
        text: 'Toca Pruebas para saber si está bien.',
        onSkip: onSkip,
      ),
      _ => null,
    };
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

  /// The first-launch question; [again] reopens it to change how Jaguar is
  /// used (from Ajustes) without opening anything.
  Future<void> _welcome({bool again = false}) async {
    final choice = await showWelcome(context, again: again);
    if (choice == null || !mounted) return;
    _settings.mode = choice == WelcomeChoice.learning ? AppMode.basic : AppMode.full;
    _settings.teacher = choice == WelcomeChoice.teacher;
    if (again) return;
    // The blank program of a first launch is not wanted any more.
    _saveNow();
    _store.discardBlank();
    final wide = MediaQuery.sizeOf(context).width >= _wideLayoutWidth;
    _settings.editorView = wide ? EditorView.both : EditorView.code;
    switch (choice) {
      case WelcomeChoice.learning:
        // The first lesson; at its end the first challenge opens, and its
        // balloons start there. The four-page introduction stays in Ajustes.
        _settings.tourStep = 0;
        _openStep(routeSteps.first);
      case WelcomeChoice.programmer:
        _settings.tourStep = 3;
        _openSource(examples.first.$2);
        await _intro(beginner: false);
      case WelcomeChoice.teacher:
        _settings.tourStep = 3;
        if (_store.isEmpty && wide) _show(_store.current);
    }
  }

  /// The short introduction: the ideas for someone new, the map for someone
  /// who already programs. Always available again from Ajustes and the start
  /// panel.
  Future<void> _intro({required bool beginner}) async {
    if (!mounted) return;
    final result = await showIntro(context, beginner: beginner);
    if (result == IntroResult.openGuide && mounted) _showGuide();
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
    if (panel == _Panel.tests) _tourAdvance(2);
    _panel = panel;
    _tab = panel == _Panel.console ? 1 : 2;
  });

  void _show(SavedProgram program, {bool openEditor = true}) {
    _session.stop();
    final known = _results[program.id];
    _testResult = known?.$1;
    _testedSource = known?.$2;
    if (known == null) _restoreTests(program);
    _panel = _Panel.console;
    _editingId = program.id;
    _loading = true;
    _code.value = TextEditingValue(text: program.source);
    _loading = false;
    _undo.value = UndoHistoryValue.empty;
    final wide = MediaQuery.sizeOf(context).width >= _wideLayoutWidth;
    setState(() {
      _tab = 0;
      if (openEditor) {
        _inEditor = true;
        // On a wide screen the editor is the Taller.
        if (wide) _roomChoice = Room.workshop;
      }
    });
  }

  /// Phones: from the editor back to the room it was opened from.
  void _leaveEditor() {
    _saveNow();
    _session.stop();
    setState(() {
      _inEditor = false;
      _tab = 0;
    });
  }

  /// After a restart only the counts were saved: running the tests again on
  /// the code that was tested gives the same result, so the Pruebas tab shows
  /// it (in grey if the code changed since).
  Future<void> _restoreTests(SavedProgram program) async {
    final tested = program.testedSource;
    final id = program.exerciseId;
    if (tested == null || id == null) return;
    final exercise = widget.exercises.byId(id);
    if (exercise == null) return;
    final result = await checkSolution(tested, exercise);
    if (!mounted || _editingId != program.id) return;
    _results[program.id] = (result, tested);
    setState(() {
      _testResult = result;
      _testedSource = tested;
    });
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
    _store.recordTests(programId, passed: result.passedCount, total: exercise.cases.length, source: source);
    _results[programId] = (result, source);
    if (result.passed && challengeById(exercise.id) != null && !_settings.doneChallenges.contains(exercise.id)) {
      _settings.markChallengeDone(exercise.id);
      _toast('¡Reto superado!');
    }
    // Exercises from a class send their result to the teacher.
    final sent = await widget.cloud?.submitIfAssigned(
      exercise: exercise,
      studentName: widget.exercises.studentName ?? widget.cloud?.user?.alias ?? 'Alumno',
      source: source,
      result: result,
      pastedLines: _store.pastedLines(programId),
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
          pastedLines: _store.pastedLines(_editingId),
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

  void _openChallenge(Challenge challenge) {
    widget.exercises.saveReceived(challenge.exercise);
    _openExercise(challenge.exercise);
  }

  void _openChallenges() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ChallengesScreen(settings: _settings, onOpen: _openChallenge),
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

  /// A student opens a task from their class: the results of Probar go to the
  /// teacher.
  void _openAssignment(Assignment assignment) {
    widget.cloud?.linkAssignment(assignment.exercise, assignment);
    widget.exercises.saveReceived(assignment.exercise);
    _openExercise(assignment.exercise);
  }

  void _openClass(ClassRoom room) {
    final cloud = widget.cloud;
    if (cloud == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ClassScreen(
          cloud: cloud,
          room: room,
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
      _toast('Sin conexión: Jaguar Code funciona igual, y tus programas se guardan en este equipo.');
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
    // Running ends the write and run balloons, whichever was showing.
    if (_settings.tourStep < 2) _settings.tourStep = 2;
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
    final console = ConsoleView(
      session: _session,
      onGoToLine: _goToLine,
      fontSize: _settings.fontSize,
      settings: _settings,
    );
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

  Future<void> _openLink() async => _openShared(await showOpenLinkDialog(context));

  /// The QR the teacher projects: the camera reads it and the exercise opens.
  Future<void> _scanQr() async => _openShared(await scanQr(context));

  void _openShared(SharedContent? content) {
    if (!mounted) return;
    switch (content) {
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

  void _showGuide() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => GuideScreen(
        teacher: _settings.teacher,
        onOpenChallenges: _openChallenges,
        onDeskCheck: _deskCheck,
        onPlan: _plan,
        onOpenClasses: widget.cloud == null ? null : _openClasses,
        onOpenTeacher: _settings.teacher ? _openTeacher : null,
        onScan: canScanQr ? _scanQr : null,
      ),
    ),
  );

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
          'Guía',
          icon: Icons.menu_book_outlined,
          onSelected: _showGuide,
          shortcut: const SingleActivator(LogicalKeyboardKey.f1),
        ),
        AppMenuItem('Retos para practicar…', icon: Icons.flag_outlined, onSelected: _openChallenges),
        AppMenuItem('Comunidad y ejemplos…', icon: Icons.public, onSelected: _openCommunity),
        AppMenuItem('Ajustes…', icon: Icons.settings_outlined, onSelected: _openSettings),
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
          AppMenuItem('Acerca de Jaguar Code', icon: Icons.info_outline, onSelected: _showAbout),
        ],
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_settings, _store]),
      builder: (context, _) {
        widget.cloud?.prefersTeacher = _settings.teacher;
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
          child: Focus(autofocus: true, child: _content(desktop, shownMenus)),
        );
        // The browser tab and the task switcher show the program's name.
        screen = ListenableBuilder(
          listenable: _code,
          builder: (context, child) =>
              Title(title: '${programName(_code.text)} — Jaguar Code', color: jaguarYellow, child: child!),
          child: screen,
        );
        if (desktop && usePlatformMenus) {
          screen = PlatformMenuBar(
            menus: platformMenus(shownMenus, appName: 'Jaguar Code', onAbout: _showAbout),
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

    final banner = exercise == null
        ? null
        : ExerciseBanner(
            onHints: challengeById(exercise.id) == null ? null : () => showHints(context, challengeById(exercise.id)!),
            onPlan: _plan,
            challenge: challengeById(exercise.id) != null,
            key: ValueKey(exercise.id),
            exercise: exercise,
            checking: _checking,
            onCheck: () => _check(exercise),
            showCheckButton: false,
            side: consoleBelow,
          );

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
            onLargePaste: _onLargePaste,
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

    final panel = _panelArea(
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
      // The statement never takes height from the code: next to it when the
      // console is below, above the console when it is on the right.
      first: banner != null && consoleBelow
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: editor),
                const VerticalDivider(width: 1),
                SizedBox(width: 300, child: banner),
              ],
            )
          : editor,
      second: banner != null && !consoleBelow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                banner,
                Expanded(child: panel),
              ],
            )
          : panel,
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
      onHome: _openHome,
      onSettings: _openSettings,
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
  Timer? _hintTimer;

  Widget _diagram() {
    // The first time the diagram shows, a line says it is the same program.
    final intro = !_settings.viewHintShown;
    if (intro) {
      _hintTimer ??= Timer(const Duration(seconds: 10), () => _settings.viewHintShown = true);
    }
    return _diagramView(intro: intro);
  }

  Widget _diagramView({required bool intro}) => DiagramView(
    code: _code,
    intro: intro ? 'Es el mismo programa dibujado. Toca un bloque para ver su línea de código.' : null,
    executingLine: _executingLine,
    // While a program runs the diagram shows where it goes; editing waits.
    editing: _session.isRunning ? null : DiagramEditing(code: _code, notation: Notation.pseint),
    onUndo: _session.isRunning ? null : _undo.undo,
    onTapLine: (line) {
      _settings.viewHintShown = true;
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
      challenge: challengeById(exercise.id) != null,
      onNextChallenge: switch (nextChallenge(exercise.id)) {
        final next? => () => _openChallenge(next),
        null => null,
      },
      onAllChallenges: _openChallenges,
    ),
  );

  void _onLargePaste(int lines) {
    _store.recordPaste(_editingId, lines);
  }

  /// Android's Atrás on the main screen: close the menu, go back to the code,
  /// and only leave after a second press, so nobody loses their place by
  /// accident.
  void _onBack() {
    final scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return;
    }
    final phone = MediaQuery.sizeOf(context).width < _wideLayoutWidth;
    if (_tab != 0) {
      setState(() => _tab = 0);
      return;
    }
    // Phones: the editor opens from a room; Atrás goes back to it, and from
    // another room to Inicio, before it asks to leave.
    if (phone && _inEditor) {
      _leaveEditor();
      return;
    }
    if (phone && _room != Room.home) {
      setState(() => _roomChoice = Room.home);
      return;
    }
    final now = DateTime.now();
    if (_lastBack != null && now.difference(_lastBack!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBack = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(duration: Duration(seconds: 2), content: Text('Presiona Atrás otra vez para salir')),
      );
  }

  /// The title in the app bar: a challenge shows just "Reto 1", the full title
  /// is in its statement.
  String _barTitle() {
    final exercise = _exercise;
    if (exercise != null && challengeById(exercise.id) != null) return exercise.title.split(' · ').last;
    return programName(_code.text);
  }

  /// Where the program in the editor comes from, under its name.
  String _barSubtitle() {
    final exercise = _exercise;
    if (exercise == null) return 'Taller';
    final index = challenges.indexWhere((c) => c.id == exercise.id);
    if (index < 0) return 'Ejercicio del profe';
    return 'Ruta · Nivel ${challenges[index].level} · Reto ${index + 1}';
  }

  void _openHome() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Jaguar Code')),
          body: _startPanel(afterAction: () => Navigator.pop(context)),
        ),
      ),
    );
  }

  /// What the content area shows with no program open.
  Widget _startPanel({VoidCallback? afterAction}) {
    VoidCallback wrap(VoidCallback action) => () {
      afterAction?.call();
      action();
    };
    return StartPanel(
      settings: _settings,
      store: _store,
      onNew: wrap(_newProgram),
      onOpenFile: wrap(_openFile),
      onOpenSource: (source) => wrap(() => _openSource(source))(),
      onOpenLink: wrap(_openLink),
      onOpenChallenges: wrap(_openChallenges),
      onContinueChallenge: (challenge) => wrap(() => _openChallenge(challenge))(),
      onSelect: (program) => wrap(() => _load(program))(),
      onScan: canScanQr ? wrap(_scanQr) : null,
      onOpenTeacher: _settings.teacher ? wrap(_openTeacher) : null,
      onOpenGuide: wrap(_showGuide),
      onOpenSettings: wrap(_openSettings),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          settings: _settings,
          exercises: widget.exercises,
          onChangeName: _changeName,
          onWelcome: () => _welcome(again: true),
          onIntro: () => _intro(beginner: _settings.isBasic),
          onRepeatTour: () {
            Navigator.pop(context);
            _settings.tourStep = 0;
            _openChallenge(challenges.first);
          },
          onCommunity: widget.cloud == null ? null : _openCommunity,
          onAccount: widget.cloud == null ? null : _account,
          onAbout: _showAbout,
        ),
      ),
    );
  }

  Widget _drawer() => ProgramsDrawer(
    store: _store,
    cloud: widget.cloud,
    settings: _settings,
    onOpenCommunity: _openCommunity,
    onOpenChallenges: _openChallenges,
    onOpenClasses: _openClasses,
    onAccount: _account,
    onGuide: _showGuide,
    onAbout: _showAbout,
    onHome: _openHome,
    onSettings: _openSettings,
    exercises: widget.exercises,
    onSelect: _load,
    onNew: _newProgram,
    onScan: canScanQr && !_settings.isBasic ? _scanQr : null,
    onOpenTeacher: _settings.teacher ? _openTeacher : null,
  );

  Future<void> _exportAll() async {
    _saveNow();
    final sources = [for (final program in _store.programs) program.source];
    if (sources.isEmpty) return;
    try {
      if (await exportAllPrograms(sources, nameOf: programName)) {
        _toast('Listo: ${sources.length} programas en un archivo');
      }
    } on Object catch (e) {
      _toast('No se pudo guardar el archivo: $e');
    }
  }

  /// Phones: deleting from the Taller keeps the rooms on screen; the editor
  /// only follows the program that stays selected.
  void _deleteFromWorkshop(SavedProgram program) {
    confirmDeleteProgram(context, _store, program, (selected) {
      if (_editingId != selected.id) _show(selected, openEditor: false);
    });
  }

  RoomActions _roomActions() => RoomActions(
    onOpenChallenge: _openChallenge,
    onOpenStep: _openStep,
    onOpenProgram: _load,
    onOpenSource: _openSource,
    onOpenExercise: _openExercise,
    onDeleteProgram: _deleteFromWorkshop,
    onNew: _newProgram,
    onOpenFile: _openFile,
    onExportAll: _exportAll,
    onOpenLink: _openLink,
    onOpenGuide: _showGuide,
    onOpenSettings: _openSettings,
    onScan: canScanQr ? _scanQr : null,
    onOpenAssignment: widget.cloud == null ? null : _openAssignment,
    onOpenClass: widget.cloud == null ? null : _openClass,
    onOpenTeacher: _settings.teacher ? _openTeacher : null,
  );

  /// A step of the path: a lesson opens its own screen, a challenge the editor.
  void _openStep(RouteStep step) {
    switch (step) {
      case LessonStep(:final lesson):
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => LessonScreen(lesson: lesson, settings: _settings, onOpenNext: _openStep),
          ),
        );
      case ChallengeStep(:final challenge):
        _openChallenge(challenge);
    }
  }

  void _goRoom(Room room) => setState(() => _roomChoice = room);

  /// Wide screens: the rooms other than the Taller, next to the rail.
  Widget _buildRoomsWide() => RoomsScaffold(
    room: _room,
    onRoom: _goRoom,
    settings: _settings,
    store: _store,
    exercises: widget.exercises,
    cloud: widget.cloud,
    actions: _roomActions(),
    bottomNavigation: false,
  );

  /// What is on screen: on a phone, a room or the editor; on a wide screen a
  /// rail with the rooms and, beside it, the room or the workspace.
  Widget _content(bool desktop, List<AppMenu> menus) {
    final wide = MediaQuery.sizeOf(context).width >= _wideLayoutWidth;
    if (!wide) return _buildTouch();
    final inner = _room == Room.workshop ? (desktop ? _buildDesktop(menus) : _buildTouch()) : _buildRoomsWide();
    return Row(
      children: [
        RoomsRail(room: _room, onRoom: _goRoom),
        const VerticalDivider(width: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: motion(context, const Duration(milliseconds: 260)),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(key: ValueKey(_room == Room.workshop ? 'taller' : 'sala'), child: inner),
          ),
        ),
      ],
    );
  }

  Widget _buildRooms() => PopScope(
    // The browser keeps its own Atrás.
    canPop: kIsWeb,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _onBack();
    },
    child: RoomsScaffold(
      room: _room,
      onRoom: _goRoom,
      settings: _settings,
      store: _store,
      exercises: widget.exercises,
      cloud: widget.cloud,
      actions: _roomActions(),
    ),
  );

  Widget _buildTouch() {
    final phone = MediaQuery.sizeOf(context).width < _wideLayoutWidth;
    if (!phone) return _buildEditorTouch();
    // A room and the editor trade places: the editor slides in from the right
    // and out the same way, so Atrás feels like going back.
    return AnimatedSwitcher(
      duration: motion(context, const Duration(milliseconds: 300)),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(children: [...previous, ?current]),
      transitionBuilder: (child, animation) {
        final editor = (child.key as ValueKey<String>).value == 'editor';
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: Offset(editor ? 0.12 : -0.06, 0), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_inEditor ? 'editor' : 'salas'),
        child: _inEditor ? _buildEditorTouch() : _buildRooms(),
      ),
    );
  }

  Widget _buildEditorTouch() {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _wideLayoutWidth;
    // On phones the program name needs the room: Ejecutar becomes an icon.
    final compact = width < 340 || MediaQuery.textScalerOf(context).scale(1) > 1.2;
    final scheme = Theme.of(context).colorScheme;
    final empty = _store.isEmpty;
    // Two points smaller on phones, so most lines fit without scrolling.
    final fontSize = wide ? _settings.fontSize : _settings.fontSize - 2;
    final running = _session.isRunning;
    final errorLine = _session.state == RunState.failed ? _session.error?.line : null;
    final exercise = _exercise;

    final banner = exercise == null
        ? null
        : ExerciseBanner(
            onHints: challengeById(exercise.id) == null ? null : () => showHints(context, challengeById(exercise.id)!),
            onPlan: _plan,
            challenge: challengeById(exercise.id) != null,
            key: ValueKey(exercise.id),
            exercise: exercise,
            checking: _checking,
            onCheck: () => _check(exercise),
          );

    final codePane = Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CodeEditor(
                key: _editorKey,
                diagnostics: _diagnostics,
                controller: _code,
                focusNode: _codeFocus,
                undoController: _undo,
                errorLine: errorLine,
                executingLine: _executingLine,
                onLargePaste: _onLargePaste,
                fontSize: fontSize,
                inlineErrors: wide,
              ),
              // Where the first balloon points: under the first lines.
              Positioned(
                top: fontSize * 3,
                left: 16,
                child: SizedBox(key: _firstLineKey, width: 1, height: 1),
              ),
            ],
          ),
        ),
        if (!wide) _ErrorStrip(diagnostics: _diagnostics, code: _code, onGoToLine: _goToLine),
        KeywordBar(controller: _code, focusNode: _codeFocus),
      ],
    );
    final view = _settings.editorView;
    final editor = Column(
      children: [
        if (banner != null && !wide) banner,
        _ViewStrip(settings: _settings, allowBoth: wide),
        Expanded(
          child: switch (view) {
            EditorView.diagram => _diagram(),
            EditorView.both when wide => SplitView(
              axis: Axis.horizontal,
              fraction: _diagramSplit,
              onChanged: (fraction) => setState(() => _diagramSplit = fraction),
              onReset: () => setState(() => _diagramSplit = 0.5),
              minFirst: 240,
              minSecond: 200,
              first: codePane,
              second: _diagram(),
            ),
            _ => codePane,
          },
        ),
      ],
    );
    final console = _console();
    // Phones: Pruebas is a third tab at the bottom.
    final tab = exercise == null && _tab == 2 ? 1 : _tab;

    final balloon = _tourBalloon();
    final scaffold = PopScope(
      // The browser keeps its own Atrás.
      canPop: kIsWeb,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        key: wide ? _scaffoldKey : null,
        appBar: AppBar(
          titleSpacing: 0,
          // Phones open the editor from a room: the arrow goes back to it.
          leading: wide
              ? null
              : IconButton(tooltip: 'Volver', icon: const Icon(Icons.arrow_back), onPressed: _leaveEditor),
          title: empty
              ? const Text('Jaguar Code')
              : ListenableBuilder(
                  listenable: _code,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_barTitle(), overflow: TextOverflow.ellipsis),
                      Text(
                        _barSubtitle(),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
          // Three controls: the menu, play and the rest. What is used less
          // lives under the three dots.
          actions: empty
              ? null
              : [
                  if (compact)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton.filled(
                        key: _runKey,
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
                      padding: const EdgeInsets.only(right: 4, left: 4),
                      child: FilledButton.icon(
                        key: _runKey,
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
                  _MoreMenu(
                    full: !_settings.isBasic,
                    hasExercise: exercise != null,
                    onNew: _newProgram,
                    onOpenFile: _openFile,
                    onSaveFile: _saveFile,
                    onSendFile: _sendFile,
                    onShare: _share,
                    onOpenLink: _openLink,
                    onScan: canScanQr ? _scanQr : null,
                    onDeskCheck: _deskCheck,
                    onPlan: _plan,
                    onGuide: _showGuide,
                  ),
                ],
        ),
        drawer: wide ? _drawer() : null,
        body: empty
            ? _startPanel()
            : wide
            ? Row(
                children: [
                  Expanded(flex: 3, child: editor),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ?banner,
                        Expanded(child: _panelArea()),
                      ],
                    ),
                  ),
                ],
              )
            : IndexedStack(
                index: tab,
                children: [editor, console, if (exercise != null) _testsPanel(exercise) else const SizedBox.shrink()],
              ),
        bottomNavigationBar: empty || wide
            ? (!empty && _session.stepping && running ? DebugBar(session: _session, onRunToCursor: _runToCursor) : null)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_session.stepping && running) DebugBar(session: _session, onRunToCursor: _runToCursor),
                  NavigationBar(
                    selectedIndex: tab,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    onDestinationSelected: (tab) => setState(() {
                      if (tab == 2) _tourAdvance(2);
                      _tab = tab;
                      if (tab > 0) _panel = tab == 1 ? _Panel.console : _Panel.tests;
                    }),
                    destinations: [
                      const NavigationDestination(icon: Icon(Icons.code), label: 'Programa'),
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
                            isLabelVisible: true,
                            label: Text(_testsBadgeText(exercise)),
                            backgroundColor: _testsBadgeColor(),
                            child: Icon(Icons.fact_check_outlined, key: _testsTabKey),
                          ),
                          label: 'Pruebas',
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
    if (balloon == null) return scaffold;
    return Stack(
      children: [
        scaffold,
        Positioned.fill(child: balloon),
      ],
    );
  }

  /// "3" before the first Probar, "2/3" after. Never a failure before trying.
  String _testsBadgeText(Exercise exercise) {
    final result = _testResult;
    return result == null ? '${exercise.cases.length}' : '${result.passedCount}/${exercise.cases.length}';
  }

  /// Green when everything passed, amber for part, red when none did, and
  /// grey when there is nothing to judge or the code changed since.
  Color? _testsBadgeColor() {
    final result = _testResult;
    if (result == null || _testsStale) return Theme.of(context).colorScheme.outline;
    if (result.passed) return Colors.green.shade700;
    return result.passedCount == 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary;
  }
}

/// Phones: the error under the code, whole, instead of at the end of a line
/// that does not fit on the screen.
class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.diagnostics, required this.code, required this.onGoToLine});

  final Diagnostics diagnostics;
  final SyntaxController code;
  final ValueChanged<int> onGoToLine;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: diagnostics,
    builder: (context, _) {
      final error = diagnostics.shownError;
      if (error == null) return const SizedBox.shrink();
      final scheme = Theme.of(context).colorScheme;
      return Material(
        color: scheme.errorContainer,
        child: InkWell(
          onTap: () => onGoToLine(error.line),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 20, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Línea ${error.line}: ${error.message}${error.hint == null ? '' : ' ${error.hint}'}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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

/// `Código | Diagrama | Ambos`: the same program written or drawn.
class _EditorViewSwitch extends StatelessWidget {
  const _EditorViewSwitch({required this.settings, required this.allowBoth, this.expanded = false});

  final ViewSettings settings;
  final bool allowBoth;

  /// Fills the width with larger text (phones) instead of the toolbar's size.
  final bool expanded;

  static const _labels = {EditorView.code: 'Código', EditorView.diagram: 'Diagrama', EditorView.both: 'Ambos'};
  static const _tips = {
    EditorView.code: 'Tu programa escrito paso a paso',
    EditorView.diagram: 'Tu programa dibujado como diagrama de flujo',
    EditorView.both: 'El código y el diagrama lado a lado',
  };
  static const _icons = {
    EditorView.code: Icons.code,
    EditorView.diagram: Icons.account_tree_outlined,
    EditorView.both: Icons.vertical_split_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final view = !allowBoth && settings.editorView == EditorView.both ? EditorView.code : settings.editorView;
    return Semantics(
      label: 'Vista del programa',
      child: SegmentedButton<EditorView>(
        segments: [
          for (final option in [EditorView.code, EditorView.diagram, if (allowBoth) EditorView.both])
            ButtonSegment(
              value: option,
              icon: Icon(_icons[option], size: expanded ? 18 : 16),
              label: Text(_labels[option]!),
              tooltip: _tips[option],
            ),
        ],
        selected: {view},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => settings.editorView = selection.single,
        style: expanded
            // Snug in its bar: no extra tap-target padding under the buttons.
            ? SegmentedButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(0, 36),
                visualDensity: VisualDensity.standard,
              )
            : SegmentedButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
                textStyle: const TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
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

/// `Código | Diagrama`: one clear switch, with words, under the app bar. It
/// folds away while typing so the code gets the room.
class _ViewStrip extends StatelessWidget {
  const _ViewStrip({required this.settings, required this.allowBoth});

  final ViewSettings settings;
  final bool allowBoth;

  @override
  Widget build(BuildContext context) {
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnimatedSize(
      duration: motion(context, const Duration(milliseconds: 200)),
      alignment: Alignment.topCenter,
      child: typing
          ? const SizedBox(width: double.infinity)
          : DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _EditorViewSwitch(settings: settings, allowBoth: allowBoth, expanded: true),
                  ),
                ),
              ),
            ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({
    required this.full,
    required this.hasExercise,
    required this.onNew,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onSendFile,
    required this.onShare,
    required this.onOpenLink,
    this.onScan,
    required this.onDeskCheck,
    required this.onPlan,
    required this.onGuide,
  });

  /// Completo adds New, Open link and Scan.
  final bool full;
  final bool hasExercise;
  final VoidCallback onNew;
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onSendFile;
  final VoidCallback onShare;
  final VoidCallback onDeskCheck;
  final VoidCallback onPlan;
  final VoidCallback onGuide;
  final VoidCallback onOpenLink;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, _) => IconButton(
        tooltip: 'Más opciones',
        icon: const Icon(Icons.more_vert),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.menu_book_outlined),
          onPressed: onGuide,
          child: const Text('Guía: cómo funciona todo'),
        ),
        if (hasExercise)
          MenuItemButton(
            leadingIcon: const Icon(Icons.edit_note),
            onPressed: onPlan,
            child: const Text('Planteamiento'),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.table_chart_outlined),
          onPressed: onDeskCheck,
          child: const Text('Prueba de escritorio'),
        ),
        const Divider(height: 1),
        if (full)
          MenuItemButton(leadingIcon: const Icon(Icons.add), onPressed: onNew, child: const Text('Nuevo programa')),
        MenuItemButton(
          leadingIcon: const Icon(Icons.folder_open),
          onPressed: onOpenFile,
          child: const Text('Abrir archivo (.psc)'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.save_alt),
          onPressed: onSaveFile,
          child: const Text('Guardar como archivo (.psc)'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.qr_code_2),
          onPressed: onShare,
          child: const Text('Compartir (QR o enlace)'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.send_outlined),
          onPressed: onSendFile,
          child: const Text('Enviar archivo (WhatsApp, correo…)'),
        ),
        if (full) ...[
          MenuItemButton(leadingIcon: const Icon(Icons.link), onPressed: onOpenLink, child: const Text('Abrir enlace')),
          if (onScan != null)
            MenuItemButton(
              leadingIcon: const Icon(Icons.qr_code_scanner),
              onPressed: onScan,
              child: const Text('Escanear QR del ejercicio'),
            ),
        ],
      ],
    );
  }
}
