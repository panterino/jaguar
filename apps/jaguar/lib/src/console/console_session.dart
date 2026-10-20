import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';

enum RunState { idle, running, waitingInput, waitingKey, paused, finished, failed, stopped }

enum SegmentKind { output, input, info }

class ConsoleSegment {
  ConsoleSegment(this.kind, this.text);

  final SegmentKind kind;
  String text;
}

/// A row of the variables table in step-by-step mode.
class DebugVariable {
  const DebugVariable(this.name, this.value, {required this.changed});

  final String name;
  final String value;

  /// Changed (or appeared) in the last step.
  final bool changed;
}

/// Runs a program and acts as its console: collects output, asks the UI for
/// input on `Leer` and reports errors.
class ConsoleSession extends ChangeNotifier implements JaguarIO {
  static const _maxOutputChars = 200000;

  final List<ConsoleSegment> segments = [];
  RunState state = RunState.idle;

  /// How many runs have started: tells one run's end from the next.
  int runCount = 0;
  JaguarError? error;

  Interpreter? _interpreter;
  Completer<String?>? _pendingRead;
  Completer<void>? _pendingKey;
  Completer<void> _stopSignal = Completer<void>();
  int _outputChars = 0;
  bool _truncated = false;
  Timer? _notifyTimer;

  bool get isRunning => switch (state) {
    RunState.running || RunState.waitingInput || RunState.waitingKey || RunState.paused => true,
    _ => false,
  };

  /// Step by step: the program pauses before each statement, showing its
  /// line and the variables, as DFD and PSeInt do.
  bool stepping = false;

  /// Playing the steps by themselves, one every [autoPlayDelay].
  bool autoPlay = false;
  static const autoPlayDelay = Duration(milliseconds: 700);

  /// The line about to run while paused.
  int? currentLine;
  List<DebugVariable> variables = const [];
  bool _stepMode = false;
  Completer<void>? _stepGate;

  /// Ejecutar hasta (F4): run freely and pause when this line comes.
  int? _runUntil;

  /// Each run gets a number, so a cancelled run that finishes late can't
  /// overwrite the state of the one that replaced it.
  int _generation = 0;

  /// Inputs typed automatically, as if the user wrote them: replaying a
  /// test in the console.
  final List<String> _presetInputs = [];

  /// [note] is shown first, in italics, to say where the inputs come from.
  Future<void> run(
    String source, {
    List<String> inputs = const [],
    String? note,
    bool stepByStep = false,
    int? untilLine,
  }) async {
    stop();
    final generation = ++_generation;
    stepping = stepByStep || untilLine != null;
    _stepMode = stepByStep;
    _runUntil = untilLine;
    autoPlay = false;
    currentLine = null;
    variables = const [];
    _presetInputs
      ..clear()
      ..addAll(inputs);
    segments.clear();
    runCount++;
    error = null;
    _outputChars = 0;
    _truncated = false;
    if (note != null) _append(SegmentKind.info, '$note\n\n');
    _stopSignal = Completer<void>();
    state = RunState.running;
    notifyListeners();

    Interpreter? interpreter;
    RunState end;
    JaguarError? failure;
    try {
      interpreter = Interpreter(
        parse(source),
        this,
        options: const RunOptions(maxSteps: 10000000),
        // Always installed: it costs nothing until a pause is asked for.
        onStep: _onStep,
      );
      _interpreter = interpreter;
      await interpreter.run();
      end = RunState.finished;
    } on JaguarError catch (e) {
      failure = e;
      end = RunState.failed;
    } on RunCancelled {
      end = RunState.stopped;
    } on Object catch (e) {
      // A bug in Jaguar, not in the student's program: still end the run.
      failure = JaguarError.runtime('Jaguar tuvo un problema interno: $e', line: currentLine ?? 1);
      end = RunState.failed;
    }
    if (generation != _generation) return;
    error = failure;
    state = end;
    if (stepping && interpreter != null) _snapshot(interpreter.finalVariables);
    currentLine = null;
    autoPlay = false;
    _stepGate = null;
    _interpreter = null;
    _pendingRead = null;
    _pendingKey = null;
    _notifyTimer?.cancel();
    notifyListeners();
  }

  FutureOr<void> _onStep(Stmt statement, int line) {
    if (_runUntil == line) {
      _runUntil = null;
      _stepMode = true;
    }
    if (!_stepMode) return null; // runs freely
    return _pause(statement, line);
  }

  Future<void> _pause(Stmt statement, int line) async {
    final interpreter = _interpreter;
    if (interpreter != null) _snapshot(interpreter.variables);
    currentLine = line;
    state = RunState.paused;
    _notifyTimer?.cancel();
    notifyListeners();
    final gate = _stepGate = Completer<void>();
    await Future.any([gate.future, _stopSignal.future, if (autoPlay) Future<void>.delayed(autoPlayDelay)]);
    if (_stopSignal.isCompleted) throw const RunCancelled();
    state = RunState.running;
  }

  void _snapshot(Map<String, Object?> values) {
    final previous = {for (final v in variables) v.name: v.value};
    variables = [
      for (final MapEntry(:key, :value) in values.entries)
        DebugVariable(key, debugValue(value), changed: previous.isNotEmpty && previous[key] != debugValue(value)),
    ];
  }

  void _openGate() {
    final gate = _stepGate;
    _stepGate = null;
    if (gate != null && !gate.isCompleted) gate.complete();
  }

  /// Runs the statement shown and pauses before the next one.
  void nextStep() {
    autoPlay = false;
    _openGate();
    notifyListeners();
  }

  /// Plays the steps by themselves, or pauses them.
  void togglePlay() {
    autoPlay = !autoPlay;
    if (autoPlay) _openGate();
    notifyListeners();
  }

  /// Pausar: a program running normally stops at the next statement and
  /// continues step by step.
  void pause() {
    if (!isRunning || _stepMode) return;
    stepping = true;
    _stepMode = true;
    notifyListeners();
  }

  /// Ejecutar hasta: runs on and pauses when [line] is about to run.
  void runToLine(int line) {
    _runUntil = line;
    stepping = true;
    continueToEnd();
  }

  /// Evaluar: the value of [text] with the variables of this moment.
  Future<String> evaluate(String text) async {
    final interpreter = _interpreter;
    if (interpreter == null || state != RunState.paused) return 'Solo se puede evaluar con el programa en pausa.';
    try {
      return debugValue(await interpreter.evaluateText(text));
    } on JaguarError catch (error) {
      return error.message;
    }
  }

  /// Leaves step mode and runs the rest of the program normally.
  void continueToEnd() {
    _stepMode = false;
    autoPlay = false;
    currentLine = null;
    _openGate();
    notifyListeners();
  }

  void stop() {
    if (!isRunning) return;
    _interpreter?.cancel();
    if (!_stopSignal.isCompleted) _stopSignal.complete();
    _pendingRead?.completeError(const RunCancelled());
    _pendingKey?.completeError(const RunCancelled());
    _pendingRead = null;
    _pendingKey = null;
  }

  /// Empties the console after a run.
  void clearOutput() {
    if (isRunning) return;
    segments.clear();
    error = null;
    stepping = false;
    variables = const [];
    state = RunState.idle;
    notifyListeners();
  }

  void submitInput(String text) {
    final pending = _pendingRead;
    if (pending == null) return;
    _pendingRead = null;
    _append(SegmentKind.input, '$text\n');
    state = RunState.running;
    notifyListeners();
    pending.complete(text);
  }

  void continueAfterKey() {
    final pending = _pendingKey;
    if (pending == null) return;
    _pendingKey = null;
    state = RunState.running;
    notifyListeners();
    pending.complete();
  }

  void _append(SegmentKind kind, String text) {
    if (_truncated) return;
    if (_outputChars + text.length > _maxOutputChars) {
      _truncated = true;
      segments.add(ConsoleSegment(SegmentKind.info, '\n… La salida es demasiado larga; se dejó de mostrar.\n'));
      return;
    }
    _outputChars += text.length;
    if (segments.isNotEmpty && segments.last.kind == kind) {
      segments.last.text += text;
    } else {
      segments.add(ConsoleSegment(kind, text));
    }
  }

  /// Programs can write thousands of times per second; repaint at most every
  /// few frames.
  void _scheduleNotify() {
    if (_notifyTimer?.isActive ?? false) return;
    _notifyTimer = Timer(const Duration(milliseconds: 50), notifyListeners);
  }

  // JaguarIO -----------------------------------------------------------------

  @override
  void write(String text) {
    _append(SegmentKind.output, text);
    _scheduleNotify();
  }

  @override
  Future<String?> read() {
    if (_presetInputs.isNotEmpty) {
      final text = _presetInputs.removeAt(0);
      _append(SegmentKind.input, '$text\n');
      _scheduleNotify();
      return Future.value(text);
    }
    _pendingRead = Completer<String?>();
    state = RunState.waitingInput;
    _notifyTimer?.cancel();
    notifyListeners();
    return _pendingRead!.future;
  }

  @override
  void clear() {
    segments.clear();
    _outputChars = 0;
    _scheduleNotify();
  }

  @override
  Future<void> waitForKey() {
    _pendingKey = Completer<void>();
    state = RunState.waitingKey;
    _notifyTimer?.cancel();
    notifyListeners();
    return _pendingKey!.future;
  }

  @override
  Future<void> sleep(Duration duration) async {
    await Future.any([Future<void>.delayed(duration), _stopSignal.future]);
    if (_stopSignal.isCompleted) throw const RunCancelled();
  }

  @override
  void dispose() {
    // A run cancelled here finishes later: it must not touch this session.
    _generation++;
    stop();
    _notifyTimer?.cancel();
    super.dispose();
  }
}
