import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/cloud/cloud.dart';
import 'src/exercises/exercise_store.dart';
import 'src/platform/browser_shortcuts.dart';
import 'src/programs/program_store.dart';
import 'src/settings.dart';
import 'src/share/share_codec.dart';
import 'src/theme.dart';
import 'src/workspace/workspace_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  keepBrowserShortcutsForApp();
  final prefs = await SharedPreferences.getInstance();
  final store = ProgramStore(prefs);
  final exercises = ExerciseStore(prefs);
  final settings = ViewSettings(prefs);
  // Classes and community, when Firebase is reachable; Jaguar works without.
  final cloud = await connectCloud(prefs);

  // On the web, a shared link carries a program or an exercise in the URL.
  var fromLink = false;
  switch (contentFromLink(Uri.base.toString())) {
    case SharedProgram(:final source):
      store.openSource(source);
      fromLink = true;
    case SharedExercise(:final exercise):
      exercises.saveReceived(exercise);
      store.openExercise(exercise);
      fromLink = true;
    case null:
      break;
  }

  runApp(JaguarApp(store: store, exercises: exercises, settings: settings, cloud: cloud, openEditor: fromLink));
}

class JaguarApp extends StatelessWidget {
  const JaguarApp({
    super.key,
    required this.store,
    required this.exercises,
    required this.settings,
    this.cloud,
    this.openEditor = false,
  });

  final ProgramStore store;
  final ExerciseStore exercises;
  final ViewSettings settings;
  final Cloud? cloud;

  /// Phones: start in the editor, not in the rooms (a link brought a program).
  final bool openEditor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Jaguar Code',
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX'), Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: settings.themeMode,
        builder: (context, child) => MaxWidth(child: child!),
        home: WorkspaceScreen(
          store: store,
          exercises: exercises,
          settings: settings,
          cloud: cloud,
          startInEditor: openEditor,
        ),
      ),
    );
  }
}

/// The widest the app gets. On an ultrawide monitor (21:9) everything
/// stretched across the whole screen; past this the app stays centered.
const maxAppWidth = 1600.0;

class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= maxAppWidth) return child;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: maxAppWidth,
          // Inside, the screens see the width they really have.
          child: MediaQuery(
            data: media.copyWith(size: Size(maxAppWidth, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
