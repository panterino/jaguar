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
    return Scaffold(
      appBar: AppBar(
        // On a phone every place opens from the portal and goes back to it.
        leading: bottomNavigation && room != Room.home
            ? IconButton(
                tooltip: 'Volver al inicio',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => onRoom(Room.home),
              )
            : null,
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
    final steps = routeSteps;
    final solved = steps
        .where((s) => isStepDone(s, lessons: settings.doneLessons, challenges: settings.doneChallenges))
        .length;
    final next = nextStep(lessons: settings.doneLessons, challenges: settings.doneChallenges);
    final fresh = solved == 0 && next != null;
    final name = exercises.studentName;
    final task = exercises.received.lastOrNull;
    final programs = store.programs.length;

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

    final routeCard = _SectionCard(
      icon: Icons.flag,
      kind: 'APRENDER',
      title: 'Ruta',
      color: scheme.primaryContainer,
      onColor: scheme.onPrimaryContainer,
      description: '${steps.length} pasos: lecciones cortas y retos con pruebas, en orden.',
      status: next == null
          ? 'Terminaste la Ruta. Puedes repasar lo que quieras.'
          : fresh
          ? 'Empieza por: ${next.title}'
          : 'Sigues en: ${next.title} · llevas $solved de ${steps.length}',
      progress: fresh ? null : solved / steps.length,
      primaryLabel: next == null ? 'Repasar la Ruta' : (fresh ? 'Empezar' : 'Continuar'),
      onPrimary: next == null ? () => onRoom(Room.route) : () => actions.onOpenStep(next),
      secondaryLabel: next == null ? null : 'Ver la ruta',
      onSecondary: () => onRoom(Room.route),
      onOpen: () => onRoom(Room.route),
    );
    final workshopCard = _SectionCard(
      icon: Icons.folder_open,
      kind: 'PRACTICAR',
      title: 'Taller',
      description: 'Escribe tus propios programas, sin lecciones. Aquí quedan guardados.',
      status: programs == 0
          ? 'Aún no tienes programas.'
          : 'Tienes $programs ${programs == 1 ? 'programa' : 'programas'}.',
      primaryLabel: 'Nuevo programa',
      onPrimary: actions.onNew,
      secondaryLabel: programs == 0 ? null : 'Abrir el Taller',
      onSecondary: () => onRoom(Room.workshop),
      onOpen: () => onRoom(Room.workshop),
    );
    final classesCard = _SectionCard(
      icon: Icons.groups,
      kind: 'CON TU PROFE',
      title: 'Clases',
      description: 'Entra con el código de tu clase y recibe sus ejercicios. Si no tienes profe, no la necesitas.',
      primaryLabel: 'Abrir Clases',
      primaryTonal: true,
      onPrimary: () => onRoom(Room.classes),
      onOpen: () => onRoom(Room.classes),
    );

    return _Page(
      children: [
        Appear(
          child: _Hero(name: name, next: next, started: solved > 0),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Text('Elige qué quieres hacer', style: theme.textTheme.titleMedium),
        ),
        if (taskCard != null) ...[Appear(index: 1, child: taskCard), const SizedBox(height: 12)],
        Appear(index: 2, child: routeCard),
        const SizedBox(height: 12),
        Appear(index: 3, child: workshopCard),
        const SizedBox(height: 12),
        Appear(index: 4, child: classesCard),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: actions.onOpenGuide,
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Cómo funciona Jaguar Code'),
          ),
        ),
      ],
    );
  }
}

/// One of the places of the app, as a card at the portal: what it is, where
/// the person stands in it and the one thing to do first.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.kind,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onOpen,
    this.color,
    this.onColor,
    this.status,
    this.progress,
    this.primaryTonal = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String kind;
  final String title;
  final String description;
  final String? status;
  final double? progress;
  final Color? color;
  final Color? onColor;
  final String primaryLabel;
  final bool primaryTonal;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = (onColor ?? scheme.onSurfaceVariant);
    return _RoomCard(
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: onColor ?? scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kind,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(title, style: theme.textTheme.titleLarge?.copyWith(color: onColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
              if (status != null) ...[
                const SizedBox(height: 6),
                Text(
                  status!,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: onColor),
                ),
              ],
              if (progress != null) ...[const SizedBox(height: 10), _Bar(value: progress!)],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (primaryTonal)
                    FilledButton.tonal(onPressed: onPrimary, child: Text(primaryLabel))
                  else
                    FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                  if (secondaryLabel != null) TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                ],
              ),
            ],
          ),
        ),
      ),
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
    final next = nextStep(lessons: settings.doneLessons, challenges: settings.doneChallenges);
    final banners = [scheme.primaryContainer, scheme.tertiaryContainer, scheme.secondaryContainer];
    return _Page(
      children: [
        const _Phrase('Tu camino, de arriba hacia abajo. Toca un paso para entrar; puedes saltar a cualquiera.'),
        for (final (g, group) in routeGroups.indexed)
          Appear(
            index: g,
            child: _PathGroup(
              group: group,
              banner: banners[g % banners.length],
              doneLessons: settings.doneLessons,
              doneChallenges: settings.doneChallenges,
              nextId: next?.id,
              onOpen: actions.onOpenStep,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Nada está bloqueado: puedes saltar a cualquier lección o reto. Cada reto trae pruebas y pistas.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// A unit of the path: a banner that says what it is for and, under it, the
/// steps as round nodes along a winding road, as in a board game.
class _PathGroup extends StatelessWidget {
  const _PathGroup({
    required this.group,
    required this.banner,
    required this.doneLessons,
    required this.doneChallenges,
    required this.nextId,
    required this.onOpen,
  });

  final RouteGroup group;
  final Color banner;
  final Set<String> doneLessons;
  final Set<String> doneChallenges;
  final String? nextId;
  final ValueChanged<RouteStep> onOpen;

  static const _rowHeight = 136.0;
  static const _nodeTop = 34.0;
  static const _nodeSize = 68.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final steps = group.steps;
    final done = [for (final s in steps) isStepDone(s, lessons: doneLessons, challenges: doneChallenges)];
    final count = done.where((d) => d).length;
    final complete = count == steps.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: complete ? _pathGreen(context) : banner,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: complete ? Colors.white : scheme.onSurface,
                        ),
                      ),
                      Text(
                        group.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: complete ? Colors.white : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$count de ${steps.length}',
                  style: theme.textTheme.labelLarge?.copyWith(color: complete ? Colors.white : scheme.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final amplitude = math.min(width * 0.26, 96.0);
              final centers = [
                for (var i = 0; i < steps.length; i++)
                  Offset(width / 2 + amplitude * math.sin(i * 1.25), i * _rowHeight + _nodeTop + _nodeSize / 2),
              ];
              return SizedBox(
                height: steps.length * _rowHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RoadPainter(
                          centers: centers,
                          done: done,
                          doneColor: _pathGreen(context),
                          todoColor: scheme.outlineVariant,
                        ),
                      ),
                    ),
                    for (final (i, step) in steps.indexed)
                      Positioned(
                        left: centers[i].dx - 80,
                        top: i * _rowHeight,
                        width: 160,
                        height: _rowHeight,
                        child: _PathNode(
                          key: ValueKey('paso-${step.id}'),
                          step: step,
                          done: done[i],
                          isNext: step.id == nextId,
                          size: _nodeSize,
                          top: _nodeTop,
                          onTap: () => onOpen(step),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Color _pathGreen(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF7BC043) : const Color(0xFF3F8200);

Color _pathGreenEdge(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF4F8A24) : const Color(0xFF2D6100);

/// The road between the nodes: a thick line that is green where it has been
/// walked.
class _RoadPainter extends CustomPainter {
  const _RoadPainter({required this.centers, required this.done, required this.doneColor, required this.todoColor});

  final List<Offset> centers;
  final List<bool> done;
  final Color doneColor;
  final Color todoColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i + 1 < centers.length; i++) {
      final a = centers[i];
      final b = centers[i + 1];
      final mid = (a.dy + b.dy) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, mid, b.dx, mid, b.dx, b.dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = done[i] ? doneColor : todoColor,
      );
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) =>
      old.centers != centers || old.done != done || old.doneColor != doneColor || old.todoColor != todoColor;
}

/// A step on the road: a round button with weight, its name under it and,
/// on the one that follows, a bubble that says what to do.
class _PathNode extends StatelessWidget {
  const _PathNode({
    super.key,
    required this.step,
    required this.done,
    required this.isNext,
    required this.size,
    required this.top,
    required this.onTap,
  });

  final RouteStep step;
  final bool done;
  final bool isNext;
  final double size;
  final double top;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lesson = step is LessonStep;
    final face = done ? _pathGreen(context) : (isNext ? scheme.primary : scheme.surfaceContainerHigh);
    final edge = done
        ? _pathGreenEdge(context)
        : (isNext ? Color.lerp(scheme.primary, Colors.black, 0.35)! : scheme.outlineVariant);
    final onFace = done || isNext ? scheme.onPrimary : scheme.onSurfaceVariant;
    final icon = done ? Icons.check : (step is LessonStep ? (step as LessonStep).lesson.icon : Icons.flag);
    final state = done ? 'hecho' : (isNext ? 'sigue' : 'pendiente');
    return Semantics(
      button: true,
      label: '${lesson ? 'Lección' : 'Reto'}: ${step.title}, $state',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (isNext)
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                  child: Text(
                    'EMPEZAR',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: face,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 5))],
                ),
                child: Icon(icon, size: 32, color: onFace),
              ),
            ),
            Positioned(
              top: top + size + 10,
              left: 0,
              right: 0,
              child: Center(
                // A label with its own ground, so the road passes behind it.
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    step.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
  const _RoomCard({this.color, this.margin = EdgeInsets.zero, required this.child});

  final Color? color;
  final EdgeInsetsGeometry margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: color ?? scheme.surfaceContainerLow,
      margin: margin,
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
