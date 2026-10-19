import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart' show Notation;
import 'package:shared_preferences/shared_preferences.dart';

/// How much of the interface a person sees. Students start in [basic] and
/// move to [full] when they want to; nothing is lost when switching.
enum AppMode { basic, full }

/// What the code area shows: the code, its flowchart, or both side by
/// side (desktop).
enum EditorView { code, diagram, both }

/// How the workspace looks, remembered on the device.
class ViewSettings extends ChangeNotifier {
  ViewSettings(this._prefs);

  static const minFontSize = 10.0;
  static const maxFontSize = 28.0;

  final SharedPreferences _prefs;

  /// Null until the person answers the welcome question.
  AppMode? get chosenMode => switch (_prefs.getString('jaguar.view.mode')) {
    'basic' => AppMode.basic,
    'full' => AppMode.full,
    _ => null,
  };

  AppMode get mode => chosenMode ?? AppMode.basic;
  set mode(AppMode mode) => _set(() => _prefs.setString('jaguar.view.mode', mode.name));

  bool get isBasic => mode == AppMode.basic;

  /// Teacher tools (exercises, creating classes) show only to teachers: a
  /// student seeing them gets confused.
  bool get teacher => _prefs.getBool('jaguar.view.teacher') ?? false;
  set teacher(bool value) => _set(() => _prefs.setBool('jaguar.view.teacher', value));

  /// Challenges solved on this device.
  Set<String> get doneChallenges => {...?_prefs.getStringList('jaguar.retos.hechos')};
  void markChallengeDone(String id) {
    if (doneChallenges.contains(id)) return;
    _set(() => _prefs.setStringList('jaguar.retos.hechos', [...doneChallenges, id]));
  }

  /// Runs that finished without error in programs with loops or functions:
  /// a sign the student is ready for the full mode.
  int get fluentRuns => _prefs.getInt('jaguar.view.fluentRuns') ?? 0;
  set fluentRuns(int value) => _prefs.setInt('jaguar.view.fluentRuns', value);

  /// The suggestion to try the full mode shows only once.
  bool get fullModeSuggested => _prefs.getBool('jaguar.view.fullModeSuggested') ?? false;
  set fullModeSuggested(bool value) => _prefs.setBool('jaguar.view.fullModeSuggested', value);

  EditorView get editorView => EditorView.values.asNameMap()[_prefs.getString('jaguar.view.editor')] ?? EditorView.code;
  set editorView(EditorView view) => _set(() => _prefs.setString('jaguar.view.editor', view.name));

  /// How flowcharts write expressions: like PSeInt or like DFD.
  Notation get notation => _prefs.getString('jaguar.view.notation') == 'dfd' ? Notation.dfd : Notation.pseint;
  set notation(Notation value) => _set(() => _prefs.setString('jaguar.view.notation', value.name));

  ThemeMode get themeMode => ThemeMode.values.byName(_prefs.getString('jaguar.view.theme') ?? ThemeMode.system.name);
  set themeMode(ThemeMode mode) => _set(() => _prefs.setString('jaguar.view.theme', mode.name));

  double get fontSize => _prefs.getDouble('jaguar.view.fontSize') ?? 14;
  set fontSize(double size) =>
      _set(() => _prefs.setDouble('jaguar.view.fontSize', size.clamp(minFontSize, maxFontSize)));

  /// Desktop: the console below the editor (the default, as in code
  /// editors) or on its right.
  bool get consoleBelow => _prefs.getBool('jaguar.view.consoleBelow') ?? true;
  set consoleBelow(bool value) => _set(() => _prefs.setBool('jaguar.view.consoleBelow', value));

  /// Desktop: the keyword bar is for touch screens, hidden by default.
  bool get keywordBar => _prefs.getBool('jaguar.view.keywordBar') ?? false;
  set keywordBar(bool value) => _set(() => _prefs.setBool('jaguar.view.keywordBar', value));

  bool get sidebar => _prefs.getBool('jaguar.view.sidebar') ?? true;
  set sidebar(bool value) => _set(() => _prefs.setBool('jaguar.view.sidebar', value));

  double get sidebarWidth => _prefs.getDouble('jaguar.view.sidebarWidth') ?? 240;
  set sidebarWidth(double value) => _set(() => _prefs.setDouble('jaguar.view.sidebarWidth', value));

  /// Fraction of the editor area the code takes; the console gets the rest.
  double get split => _prefs.getDouble('jaguar.view.split') ?? 0.65;
  set split(double value) => _set(() => _prefs.setDouble('jaguar.view.split', value));

  void _set(void Function() write) {
    write();
    notifyListeners();
  }
}

/// Lab computers and laptops get a desktop layout (menu bar, side panel,
/// status bar); phones and tablets the touch layout.
bool useDesktopLayout(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final desktopPlatform = switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
    _ => false,
  };
  return desktopPlatform && width >= (kIsWeb ? 1000 : 720);
}

/// The native macOS app uses the system menu bar instead of drawing one.
bool get usePlatformMenus => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

/// Cmd on Apple platforms, Ctrl elsewhere.
bool get isApple => defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;

/// Shortcut text for tooltips and hints: "Ctrl+Enter" or "⇧⌘Enter".
String shortcutLabel(String key, {bool shift = false}) =>
    isApple ? '${shift ? '⇧' : ''}⌘$key' : 'Ctrl+${shift ? 'Shift+' : ''}$key';
