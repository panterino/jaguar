import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../challenges/challenges.dart';
import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../lessons/lessons.dart';
import '../widgets/appear.dart';
import '../programs/examples.dart';
import '../programs/program_store.dart';
import '../settings.dart';
import '../theme.dart';
import 'classes_room.dart';
import 'programs_drawer.dart' show timeAgo;

/// The four places of the phone app. Each one answers a question: what is
/// next (Inicio), what do I learn (Ruta), what does my teacher ask (Clases)
/// and what have I made (Taller). The editor is the same in all of them.
enum Room { home, route, classes, workshop }

/// What the rooms ask the workspace to do.
class RoomActions {
  const RoomActions({
    required this.onOpenChallenge,
    required this.onOpenStep,
    required this.onOpenProgram,
    required this.onOpenSource,
    required this.onOpenExercise,
    required this.onDeleteProgram,
    required this.onNew,
    required this.onOpenFile,
    required this.onExportAll,
    required this.onOpenLink,
    required this.onOpenGuide,
    required this.onOpenSettings,
    this.onScan,
    this.onOpenAssignment,
    this.onOpenClass,
    this.onOpenTeacher,
  });

  final ValueChanged<Challenge> onOpenChallenge;

  /// A lesson or a challenge of the path.
  final ValueChanged<RouteStep> onOpenStep;
  final ValueChanged<SavedProgram> onOpenProgram;
  final ValueChanged<String> onOpenSource;
  final ValueChanged<Exercise> onOpenExercise;
  final ValueChanged<SavedProgram> onDeleteProgram;
  final VoidCallback onNew;
  final VoidCallback onOpenFile;
  final VoidCallback onExportAll;
  final VoidCallback onOpenLink;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenSettings;

  /// The camera; null where it does not exist.
  final VoidCallback? onScan;

  /// Online classes (null when Jaguar runs offline): a student opens a
  /// task; the class itself opens its page.
  final ValueChanged<Assignment>? onOpenAssignment;
  final ValueChanged<ClassRoom>? onOpenClass;

  /// Teachers only.
  final VoidCallback? onOpenTeacher;
}

/// The phone's main screen: one room at a time and a bar to move between
/// them. Opening a program, a challenge or a task leaves the rooms for the
/// editor; Atrás comes back.
class RoomsScaffold extends StatelessWidget {
  const RoomsScaffold({
    super.key,
    required this.room,
    required this.onRoom,
    required this.settings,
    required this.store,
    required this.exercises,
    required this.actions,
    this.cloud,
    this.bottomNavigation = true,
  });

  /// The bar at the bottom: phones. Wide screens use [RoomsRail].
  final bool bottomNavigation;
  final Cloud? cloud;
  final Room room;
  final ValueChanged<Room> onRoom;
  final ViewSettings settings;
  final ProgramStore store;
  final ExerciseStore exercises;
  final RoomActions actions;

  static const _titles = {
    Room.home: 'Jaguar Code',
    Room.route: 'Ruta',
    Room.classes: 'Clases',
    Room.workshop: 'Taller',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(room == Room.home ? (_isWide(context) ? 'Inicio' : 'Jaguar Code') : _titles[room]!),
        actions: [
          if (room == Room.home)
            IconButton(
              tooltip: 'Ajustes',
              icon: const Icon(Icons.settings_outlined),
              onPressed: actions.onOpenSettings,
            ),
          if (room == Room.workshop) ..._workshopActions(context),
          if (room == Room.classes && cloud != null) _classesAction(context, cloud!),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([settings, store, exercises, ?cloud]),
        builder: (context, _) => AnimatedSwitcher(
          duration: motion(context, const Duration(milliseconds: 260)),
          switchInCurve: Curves.easeOutCubic,
          // One room fades into the next, rising a little.
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(room),
            child: switch (room) {
              Room.home => _HomeRoom(
                settings: settings,
                store: store,
                exercises: exercises,
                actions: actions,
                onRoom: onRoom,
              ),
              Room.route => _RouteRoom(settings: settings, actions: actions),
              Room.classes => _ClassesRoom(cloud: cloud, exercises: exercises, actions: actions),
              Room.workshop => _WorkshopRoom(store: store, actions: actions),
            },
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigation
          ? NavigationBar(
              selectedIndex: room.index,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              backgroundColor: theme.colorScheme.surfaceContainer,
              onDestinationSelected: (index) => onRoom(Room.values[index]),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
                NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Ruta'),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: 'Clases',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: 'Taller',
                ),
              ],
            )
          : null,
    );
  }

  /// Students join with a code; teachers create the class.
  Widget _classesAction(BuildContext context, Cloud cloud) {
    final teacher = cloud.user?.isTeacher ?? false;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: teacher
          ? FilledButton.icon(
              onPressed: () => createClassFlow(context, cloud),
              icon: const Icon(Icons.add),
              label: const Text('Crear clase'),
            )
          : OutlinedButton.icon(
              onPressed: () => joinClassFlow(context, cloud, exercises),
              icon: const Icon(Icons.add),
              label: const Text('Unirme con código'),
            ),
    );
  }

  List<Widget> _workshopActions(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilledButton.icon(onPressed: actions.onNew, icon: const Icon(Icons.add), label: const Text('Nuevo')),
    ),
    PopupMenuButton<String>(
      tooltip: 'Más',
      onSelected: (value) {
        switch (value) {
          case 'open':
            actions.onOpenFile();
          case 'export':
            actions.onExportAll();
          case 'examples':
            _showExamples(context, actions.onOpenSource);
          case 'link':
            actions.onOpenLink();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'open', child: Text('Abrir archivo (.psc)')),
        const PopupMenuItem(value: 'examples', child: Text('Ejemplos')),
        const PopupMenuItem(value: 'link', child: Text('Abrir enlace')),
        if (!store.isEmpty) const PopupMenuItem(value: 'export', child: Text('Guardar todos mis programas')),
      ],
    ),
  ];
}

void _showExamples(BuildContext context, ValueChanged<String> onOpenSource) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final (title, source) in examples)
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(title),
              onTap: () {
                Navigator.pop(context);
                onOpenSource(source);
              },
            ),
        ],
      ),
    ),
  );
}

/// A small caps label over a group.
/// The fixed line under the top of each room: what it is for.
class _Phrase extends StatelessWidget {
  const _Phrase(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

/// Wide screens (a computer, a tablet) show the rooms with a rail at the side.
bool _isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;

/// A content column that stays readable on a wide phone or a computer.
class _Page extends StatelessWidget {
  const _Page({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _isWide(context) ? 920 : 640),
      child: ListView(padding: EdgeInsets.fromLTRB(16, _isWide(context) ? 28 : 16, 16, 24), children: children),
    ),
  );
}

class _HomeRoom extends StatelessWidget {
  const _HomeRoom({
    required this.settings,
    required this.store,
    required this.exercises,
    required this.actions,
    required this.onRoom,
  });

  final ViewSettings settings;
  final ProgramStore store;
  final ExerciseStore exercises;
  final RoomActions actions;
  final ValueChanged<Room> onRoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final doneLessons = settings.doneLessons;
    final doneChallenges = settings.doneChallenges;
    final steps = routeSteps;
    final solved = steps.where((s) => isStepDone(s, lessons: doneLessons, challenges: doneChallenges)).length;
    final next = nextStep(lessons: doneLessons, challenges: doneChallenges);
    final name = exercises.studentName;
    final task = exercises.received.lastOrNull;
    final recent = store.programs.take(3).toList();
    final wide = _isWide(context);
    final fresh = solved == 0 && next != null;

    final nextCard = _RoomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              next == null ? 'RUTA COMPLETA' : (fresh ? 'EMPIEZA AQUÍ' : 'SIGUE DONDE TE QUEDASTE'),
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(next == null ? '¡Terminaste el nivel 1!' : next.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              next == null
                  ? 'Hiciste todas las lecciones y los retos. Ahora escribe tus propios programas.'
                  : fresh
                  ? (next is LessonStep
                        ? 'Una lección corta: 5 preguntas, unos 2 minutos. Luego escribes tu primer programa.'
                        : 'Un reto con pruebas que te dicen si va bien.')
                  : '${next is LessonStep ? 'Lección' : 'Reto'} · llevas $solved de ${steps.length} pasos',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            _Bar(value: solved / steps.length),
            const SizedBox(height: 12),
            if (next != null)
              FilledButton(
                onPressed: () => actions.onOpenStep(next),
                child: Text(solved == 0 ? 'Empezar' : 'Continuar'),
              )
            else ...[
              FilledButton(onPressed: actions.onNew, child: const Text('Abrir un programa nuevo')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => onRoom(Room.route), child: const Text('Repasar la Ruta')),
            ],
          ],
        ),
      ),
    );

    final taskCard = task == null
        ? null
        : _RoomCard(
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEL PROFE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(task.title, style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSecondaryContainer)),
                  const SizedBox(height: 10),
                  FilledButton(onPressed: () => actions.onOpenExercise(task), child: const Text('Abrir ejercicio')),
                ],
              ),
            ),
          );

    return _Page(
      children: [
        Appear(
          child: _Hero(name: name, next: next, started: solved > 0),
        ),
        const SizedBox(height: 16),
        if (wide && taskCard != null)
          Appear(
            index: 1,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: nextCard),
                  const SizedBox(width: 16),
                  Expanded(child: taskCard),
                ],
              ),
            ),
          )
        else ...[
          if (taskCard != null) ...[Appear(index: 1, child: taskCard), const SizedBox(height: 12)],
          Appear(index: taskCard != null ? 2 : 1, child: nextCard),
        ],
        if (fresh) ...[
          const SizedBox(height: 8),
          Wrap(
            children: [
              TextButton(onPressed: actions.onOpenGuide, child: const Text('Cómo funciona Jaguar Code')),
              TextButton(onPressed: actions.onNew, child: const Text('Ya programo: abrir un programa en blanco')),
            ],
          ),
        ] else ...[
          const SizedBox(height: 20),
          const _Label('Taller · recientes'),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aún no tienes programas.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  TextButton(onPressed: actions.onNew, child: const Text('Nuevo programa')),
                ],
              ),
            )
          else
            for (final (i, program) in recent.indexed)
              Appear(
                index: 3 + i,
                child: _RoomCard(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    minVerticalPadding: 12,
                    title: Text(program.name, style: monoLabel(theme)),
                    trailing: Text(timeAgo(program.updatedAt), style: theme.textTheme.bodySmall),
                    onTap: () => actions.onOpenProgram(program),
                  ),
                ),
              ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: actions.onOpenGuide,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Guía: cómo funciona todo'),
            ),
          ),
        ],
      ],
    );
  }
}

/// The top of Inicio: the mascot says something. Touch it and it jumps and
/// says another thing.
class _Hero extends StatefulWidget {
  const _Hero({required this.name, required this.next, required this.started});

  final String? name;
  final RouteStep? next;
  final bool started;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _jump = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  int _phrase = 0;

  static const _more = [
    'Los errores no muerden.',
    '¿Ya hiciste tu prueba de escritorio?',
    'Un paso a la vez.',
    'Pista: léelo en voz alta.',
  ];

  String get _greeting {
    final name = widget.name;
    if (_phrase == 0) {
      if (!widget.started) {
        return name == null ? '¡Hola! Soy Jaguar. ¿Empezamos?' : '¡Hola, $name! ¿Empezamos?';
      }
      return name == null ? '¡Qué bueno verte! ¿Seguimos?' : '¡Qué bueno verte, $name! ¿Seguimos?';
    }
    return _more[(_phrase - 1) % _more.length];
  }

  @override
  void dispose() {
    _jump.dispose();
    super.dispose();
  }

  void _talk() {
    setState(() => _phrase++);
    if (!MediaQuery.disableAnimationsOf(context)) _jump.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _talk,
            child: Semantics(
              button: true,
              label: 'La mascota de Jaguar. Tócala para que te diga algo',
              excludeSemantics: true,
              child: AnimatedBuilder(
                animation: _jump,
                builder: (context, child) {
                  final t = _jump.value;
                  final lift = -math.sin(t * math.pi) * 26;
                  final squash = 1 + 0.08 * math.sin(t * math.pi * 2) * (1 - t);
                  return Transform.translate(
                    offset: Offset(0, lift),
                    child: Transform.scale(scaleY: squash, alignment: Alignment.bottomCenter, child: child),
                  );
                },
                child: Image.asset('assets/images/mascota.png', width: 84, height: 97),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AnimatedSwitcher(
                duration: motion(context, const Duration(milliseconds: 280)),
                layoutBuilder: (current, previous) =>
                    Stack(alignment: Alignment.bottomLeft, children: [...previous, ?current]),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  alignment: Alignment.bottomLeft,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Align(
                  key: ValueKey(_phrase),
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: const Radius.circular(4)),
                      border: Border.all(color: scheme.outlineVariant, width: 2),
                    ),
                    child: Text(_greeting, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A progress bar that fills when it appears and when the value grows.
class _Bar extends StatelessWidget {
  const _Bar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value),
    duration: motion(context, const Duration(milliseconds: 700)),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) =>
        LinearProgressIndicator(value: v, minHeight: 10, borderRadius: BorderRadius.circular(5)),
  );
}

TextStyle? monoLabel(ThemeData theme) => theme.textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono');

class _RouteRoom extends StatelessWidget {
  const _RouteRoom({required this.settings, required this.actions});

  final ViewSettings settings;
  final RoomActions actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final doneLessons = settings.doneLessons;
    final doneChallenges = settings.doneChallenges;
    final next = nextStep(lessons: doneLessons, challenges: doneChallenges);
    final wide = _isWide(context);

    final cards = <Widget>[
      for (final (g, group) in routeGroups.indexed)
        Appear(
          index: g,
          child: _GroupCard(
            group: group,
            doneLessons: doneLessons,
            doneChallenges: doneChallenges,
            nextId: next?.id,
            onOpen: actions.onOpenStep,
          ),
        ),
    ];

    return _Page(
      children: [
        const _Phrase('Lecciones cortas y retos con pruebas, en orden. Puedes saltar a cualquiera.'),
        if (wide)
          LayoutBuilder(
            builder: (context, constraints) {
              final half = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [for (final card in cards) SizedBox(width: half, child: card)],
              );
            },
          )
        else
          for (final card in cards) Padding(padding: const EdgeInsets.only(bottom: 14), child: card),
        const SizedBox(height: 4),
        Text(
          'Nada está bloqueado: puedes saltar a cualquier lección o reto. Cada reto trae pruebas y pistas.',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.doneLessons,
    required this.doneChallenges,
    required this.nextId,
    required this.onOpen,
  });

  final RouteGroup group;
  final Set<String> doneLessons;
  final Set<String> doneChallenges;
  final String? nextId;
  final ValueChanged<RouteStep> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = group.steps.where((s) => isStepDone(s, lessons: doneLessons, challenges: doneChallenges)).length;
    return _RoomCard(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.title, style: theme.textTheme.titleMedium),
                      Text(
                        group.description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text('$done de ${group.steps.length}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Bar(value: done / group.steps.length),
          ),
          const SizedBox(height: 6),
          for (final step in group.steps)
            switch (step) {
              LessonStep() => _LessonRow(
                lesson: step.lesson,
                done: doneLessons.contains(step.id),
                isNext: step.id == nextId,
                onTap: () => onOpen(step),
              ),
              ChallengeStep() => _ChallengeRow(
                challenge: step.challenge,
                done: doneChallenges.contains(step.id),
                isNext: step.id == nextId,
                onTap: () => onOpen(step),
              ),
            },
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

/// One row of the path: a badge, the name and what it is.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.isNext,
    required this.onTap,
    this.trailing,
  });

  final Widget badge;
  final String title;
  final String subtitle;
  final bool isNext;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: isNext,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Material(
          color: isNext ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 30, child: Center(child: badge)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                              color: isNext ? scheme.onPrimaryContainer : null,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isNext ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isNext)
                      Text(
                        trailing ?? 'Continuar',
                        style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.done, required this.isNext, required this.onTap});

  final Lesson lesson;
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _StepRow(
      badge: Hero(
        tag: 'leccion-${lesson.id}',
        child: Material(
          color: Colors.transparent,
          child: done
              ? Icon(Icons.check_circle, color: Colors.green.shade700, semanticLabel: 'hecha')
              : Icon(lesson.icon, color: isNext ? scheme.onPrimaryContainer : scheme.primary),
        ),
      ),
      title: lesson.title,
      subtitle: 'Lección · ${lesson.summary}',
      isNext: isNext,
      onTap: onTap,
      trailing: 'Empezar',
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge, required this.done, required this.isNext, required this.onTap});

  final Challenge challenge;
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final index = challenges.indexOf(challenge);
    return _StepRow(
      badge: done
          ? Icon(Icons.check, color: Colors.green.shade700, semanticLabel: 'hecho')
          : Icon(
              Icons.flag_outlined,
              color: isNext ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              semanticLabel: 'reto',
            ),
      title: challenge.exercise.title.replaceFirst(RegExp(r'^Reto \d+ · '), ''),
      subtitle: 'Reto ${index + 1} · ${challenge.subject}',
      isNext: isNext,
      onTap: onTap,
    );
  }
}

class _ClassesRoom extends StatelessWidget {
  const _ClassesRoom({required this.cloud, required this.exercises, required this.actions});

  final Cloud? cloud;
  final ExerciseStore exercises;
  final RoomActions actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final received = exercises.received.reversed.toList();
    return _Page(
      children: [
        const _Phrase(
          'Lo que te comparte tu profe: clases en línea y ejercicios. Si no tienes profe, no necesitas esta sala.',
        ),
        if (actions.onOpenTeacher case final openTeacher?) ...[
          _RoomCard(
            child: ListTile(
              minVerticalPadding: 14,
              leading: const Icon(Icons.school_outlined),
              title: const Text('Mis ejercicios'),
              subtitle: const Text('Crea ejercicios que se revisan solos y mira lo que entrega tu grupo.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: openTeacher,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (cloud case final cloud?)
          ClassesList(
            cloud: cloud,
            onOpenAssignment: (assignment) => actions.onOpenAssignment?.call(assignment),
            onOpenClass: (room) => actions.onOpenClass?.call(room),
          )
        else
          const _Phrase('Las clases en línea necesitan internet. Lo demás de esta sala funciona sin conexión.'),
        const SizedBox(height: 20),
        const _Label('Ejercicios del profe'),
        if (received.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              'Cuando tu profe te comparta un ejercicio con un QR o un enlace, aparece aquí.',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          )
        else
          for (final exercise in received)
            _RoomCard(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                minVerticalPadding: 12,
                title: Text(exercise.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => actions.onOpenExercise(exercise),
              ),
            ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (actions.onScan case final scan?)
              OutlinedButton.icon(
                onPressed: scan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear QR'),
              ),
            OutlinedButton.icon(
              onPressed: actions.onOpenLink,
              icon: const Icon(Icons.link),
              label: const Text('Abrir enlace'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Lo que haces aquí es para tu clase. Tu avance en la Ruta va por separado y nadie más lo ve.',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkshopRoom extends StatefulWidget {
  const _WorkshopRoom({required this.store, required this.actions});

  final ProgramStore store;
  final RoomActions actions;

  @override
  State<_WorkshopRoom> createState() => _WorkshopRoomState();
}

class _WorkshopRoomState extends State<_WorkshopRoom> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final all = widget.store.programs;
    if (all.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_outlined, size: 48, color: scheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text('Tu taller está vacío', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Tus programas: abre, busca, borra o crea uno en blanco.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.actions.onNew,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo programa'),
              ),
            ],
          ),
        ),
      );
    }
    final q = normalize(_query.trim());
    final shown = q.isEmpty
        ? all
        : [
            for (final p in all)
              if (normalize(p.name).contains(q)) p,
          ];
    return _Page(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar en tu taller',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: scheme.surfaceContainerHigh,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Ningún programa se llama así.',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        for (final program in shown)
          _RoomCard(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              minVerticalPadding: 10,
              title: Text(program.name, style: monoLabel(theme)),
              subtitle: Text(_subtitle(program)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Kind(program: program),
                  IconButton(
                    tooltip: 'Eliminar "${program.name}"',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => widget.actions.onDeleteProgram(program),
                  ),
                ],
              ),
              onTap: () => widget.actions.onOpenProgram(program),
            ),
          ),
      ],
    );
  }

  String _subtitle(SavedProgram program) {
    final tests = program.testsTotal;
    final ago = timeAgo(program.updatedAt);
    return tests == null ? ago : '$ago · ${program.testsPassed} de $tests pruebas';
  }
}

/// Where a program in the workshop came from.
class _Kind extends StatelessWidget {
  const _Kind({required this.program});

  final SavedProgram program;

  @override
  Widget build(BuildContext context) {
    final id = program.exerciseId;
    final label = id == null ? 'Mío' : (challengeById(id) != null ? 'Reto' : 'Tarea');
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (label) {
      'Reto' => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      'Tarea' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// A flat card with a light outline, as the rooms draw all their groups.
class _RoomCard extends StatelessWidget {
  const _RoomCard({this.color, this.margin = EdgeInsets.zero, this.clipBehavior = Clip.none, required this.child});

  final Color? color;
  final EdgeInsetsGeometry margin;
  final Clip clipBehavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: color ?? scheme.surfaceContainerLow,
      margin: margin,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color == null ? scheme.outlineVariant : Colors.transparent),
      ),
      child: child,
    );
  }
}

/// The rooms as a rail at the left, for a computer or a tablet: always there,
/// like the activity bar of a code editor.
class RoomsRail extends StatelessWidget {
  const RoomsRail({super.key, required this.room, required this.onRoom});

  final Room room;
  final ValueChanged<Room> onRoom;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return NavigationRail(
      selectedIndex: room.index,
      onDestinationSelected: (index) => onRoom(Room.values[index]),
      labelType: NavigationRailLabelType.all,
      backgroundColor: scheme.surfaceContainer,
      minWidth: 76,
      leading: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 14),
        child: Image.asset('assets/images/mascota.png', width: 36, height: 36, excludeFromSemantics: true),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        NavigationRailDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: Text('Ruta')),
        NavigationRailDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: Text('Clases'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Taller'),
        ),
      ],
    );
  }
}
