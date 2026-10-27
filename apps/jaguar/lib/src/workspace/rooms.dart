import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../challenges/challenges.dart';
import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../lessons/lessons.dart';
import '../widgets/appear.dart';
import '../widgets/chunky.dart';
import '../widgets/mascota.dart';
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
        // On a phone every place opens from the portal and goes back to it.
        leading: bottomNavigation && room != Room.home
            ? IconButton(
                tooltip: 'Volver al inicio',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => onRoom(Room.home),
              )
            : null,
        title: room == Room.home && !_isWide(context)
            ? Text.rich(
                TextSpan(
                  text: 'Jaguar',
                  children: [
                    TextSpan(
                      text: ' Code',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? jaguarYellow : const Color(0xFF8A5A00),
                      ),
                    ),
                  ],
                ),
              )
            : Text(room == Room.home ? 'Inicio' : _titles[room]!),
        actions: [
          if (room == Room.home)
            IconButton(
              tooltip: 'Cómo funciona Jaguar Code',
              icon: const Icon(Icons.help_outline_rounded),
              onPressed: actions.onOpenGuide,
            ),
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
                cloud: cloud,
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

class _HomeRoom extends StatefulWidget {
  const _HomeRoom({
    required this.settings,
    required this.store,
    required this.exercises,
    required this.actions,
    required this.onRoom,
    this.cloud,
  });

  final Cloud? cloud;
  final ViewSettings settings;
  final ProgramStore store;
  final ExerciseStore exercises;
  final RoomActions actions;
  final ValueChanged<Room> onRoom;

  @override
  State<_HomeRoom> createState() => _HomeRoomState();
}

/// How many classes there are and how many tasks wait, for the Clases card.
class _ClassStatus {
  const _ClassStatus(this.classes, this.pending);

  final int classes;
  final int pending;
}

class _HomeRoomState extends State<_HomeRoom> {
  _ClassStatus? _status;
  String? _loadedFor;

  @override
  void initState() {
    super.initState();
    widget.cloud?.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.cloud?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final cloud = widget.cloud;
    final user = cloud?.user;
    if (cloud == null || user == null) {
      _loadedFor = null;
      if (_status != null && mounted) setState(() => _status = null);
      return;
    }
    _loadedFor = user.uid;
    try {
      final rooms = await cloud.backend.myClasses();
      var pending = 0;
      for (final room in rooms) {
        if (room.ownerId == user.uid) continue;
        for (final assignment in await cloud.backend.assignments(room.id)) {
          if (await cloud.backend.mySubmission(room.id, assignment.id) == null) pending++;
        }
      }
      if (mounted && _loadedFor == user.uid) setState(() => _status = _ClassStatus(rooms.length, pending));
    } on Object {
      // Without a connection the card says nothing about classes.
      if (mounted) setState(() => _status = null);
    }
  }

  ViewSettings get settings => widget.settings;
  ProgramStore get store => widget.store;
  ExerciseStore get exercises => widget.exercises;
  RoomActions get actions => widget.actions;
  ValueChanged<Room> get onRoom => widget.onRoom;

  @override
  Widget build(BuildContext context) {
    final steps = mainSteps;
    final flags = [
      for (final step in steps) isStepDone(step, lessons: settings.doneLessons, challenges: settings.doneChallenges),
    ];
    final solved = flags.where((d) => d).length;
    final next = nextMainStep(lessons: settings.doneLessons, challenges: settings.doneChallenges);
    final task = exercises.received.lastOrNull;
    final programs = store.programs.length;
    final teacher = settings.teacher;
    final status = _status;
    final nextIndex = next == null ? -1 : steps.indexWhere((s) => s.id == next.id);

    final route = _Place(
      room: Room.route,
      kicker: 'APRENDER',
      title: 'Ruta',
      phrase: next == null ? 'Repasa lo que quieras.' : 'Lecciones cortas y retos con pruebas.',
      state: next == null
          ? 'Terminaste los ${steps.length} pasos'
          : (solved == 0 ? 'Empieza aquí: ${next.title}' : 'Paso ${nextIndex + 1} de ${steps.length}: ${next.title}'),
      icon: Icons.flag_rounded,
    );
    final workshop = _Place(
      room: Room.workshop,
      kicker: 'PRACTICAR',
      title: 'Taller',
      phrase: programs == 0 ? 'Crea el primero, sin lecciones.' : 'Escribe y guarda tus propios programas.',
      state: programs == 1 ? '1 programa' : '$programs programas',
      icon: Icons.handyman_rounded,
    );
    final classes = _Place(
      room: Room.classes,
      kicker: teacher ? 'CON TU GRUPO' : 'CON TU PROFE',
      title: 'Clases',
      phrase: teacher ? 'Tus grupos y sus entregas.' : 'Los ejercicios de tu profe.',
      state: task != null
          ? 'Tarea nueva: ${task.title}'
          : switch (status) {
              null => teacher ? 'Tus clases' : 'Sin clase',
              _ClassStatus(classes: 0) => 'Sin clase',
              _ClassStatus(:final pending) when pending > 0 && !teacher =>
                pending == 1 ? '1 tarea por hacer' : '$pending tareas por hacer',
              _ClassStatus(:final classes) => classes == 1 ? '1 clase' : '$classes clases',
            },
      icon: Icons.school_rounded,
      badge: task != null || (status?.pending ?? 0) > 0 && !teacher,
      badgeCount: task != null ? 1 : (status?.pending ?? 1),
    );
    final primaryRoom = teacher ? Room.classes : (next != null ? Room.route : Room.workshop);
    final places = {Room.route: route, Room.workshop: workshop, Room.classes: classes};
    final primary = places[primaryRoom]!;
    final others = [
      for (final room in [Room.route, Room.workshop, Room.classes])
        if (room != primaryRoom) places[room]!,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final tier = h < 560 ? 0 : (h <= 740 ? 1 : 2);
        final gap = const [10.0, 12.0, 16.0][tier];
        final top = 0.0;
        final bottom = const [12.0, 16.0, 16.0][tier];
        final showTask = task != null && h >= 560;
        final taskHeight = showTask ? 56.0 + gap : 0.0;
        final hero = (0.17 * h).clamp(72.0, 132.0);
        final room = h - top - bottom - hero - 2 * gap - taskHeight;
        final primaryHeight = (0.55 * room).clamp(168.0, 420.0);
        final rowHeight = (room - primaryHeight).clamp(150.0, 320.0);
        final leftover = math.max(0.0, room - primaryHeight - rowHeight);
        final compact = scale > 1.15 || room < 360;
        final needsScroll = scale > 1.6 || h < 440;

        Widget place(_Place p, double height, {required bool wide, required int index}) => Appear(
          index: index,
          child: _PortalTile(
            place: p,
            wide: wide,
            height: height,
            tier: tier,
            compact: compact,
            strip: p.room == Room.route && next != null && scale < 1.5
                ? _RouteDots(done: flags, next: nextIndex, tier: tier)
                : null,
            onTap: () => onRoom(p.room),
          ),
        );

        final column = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: top),
            Appear(
              child: SizedBox(
                height: hero,
                child: _Hero(name: exercises.studentName, next: next, started: solved > 0, mascotHeight: hero * 0.9),
              ),
            ),
            SizedBox(height: gap),
            if (showTask) ...[
              Appear(
                index: 1,
                child: _TaskStrip(title: task.title, onTap: () => actions.onOpenExercise(task)),
              ),
              SizedBox(height: gap),
            ],
            place(primary, primaryHeight, wide: true, index: 1),
            SizedBox(height: gap),
            SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  Expanded(child: place(others[0], rowHeight, wide: false, index: 2)),
                  SizedBox(width: gap),
                  Expanded(child: place(others[1], rowHeight, wide: false, index: 3)),
                ],
              ),
            ),
            SizedBox(height: bottom),
          ],
        );

        final padded = Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tier == 2 ? 20 : 16),
              child: needsScroll
                  ? SingleChildScrollView(child: column)
                  : Column(children: [column, if (leftover > 0) const Spacer()]),
            ),
          ),
        );
        return padded;
      },
    );
  }
}

/// What the portal says about one place.
class _Place {
  const _Place({
    required this.room,
    required this.kicker,
    required this.title,
    required this.phrase,
    required this.state,
    required this.icon,
    this.badge = false,
    this.badgeCount = 1,
  });

  final Room room;
  final String kicker;
  final String title;
  final String phrase;
  final String state;
  final IconData icon;

  /// Something is waiting there (a task from the teacher).
  final bool badge;
  final int badgeCount;
}

PlaceColors _colorsOf(BuildContext context, Room room) => switch (room) {
  Room.route => PlaceColors.route(context),
  Room.workshop => PlaceColors.workshop(context),
  _ => PlaceColors.classes(context),
};

/// A place of the app as one big button with weight: it has its own color,
/// shape and icon, and the whole card is what you touch.
class _PortalTile extends StatelessWidget {
  const _PortalTile({
    required this.place,
    required this.wide,
    required this.height,
    required this.tier,
    required this.compact,
    required this.onTap,
    this.strip,
  });

  final _Place place;

  /// The main one: the full width and a strip of progress.
  final bool wide;
  final double height;
  final int tier;
  final bool compact;
  final Widget? strip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsOf(context, place.room);
    final pad = wide ? const [14.0, 16.0, 18.0][tier] : const [12.0, 14.0, 16.0][tier];
    final titleSize = wide ? const [28.0, 32.0, 36.0][tier] : const [20.0, 22.0, 24.0][tier];
    final stateSize = wide ? const [15.0, 16.0, 18.0][tier] : const [11.0, 12.0, 13.0][tier];
    final arrow = wide ? const [36.0, 40.0, 44.0][tier] : const [30.0, 32.0, 36.0][tier];
    final textStyle = TextStyle(color: colors.ink, height: 1.15);
    final arrowDot = Container(
      width: arrow,
      height: arrow,
      decoration: BoxDecoration(color: wide ? const Color(0xFF2A1B0F) : colors.ink, shape: BoxShape.circle),
      child: Icon(Icons.arrow_forward_rounded, size: arrow * 0.6, color: wide ? const Color(0xFFFFE08A) : colors.face),
    );

    final content = wide
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!compact)
                Text(
                  place.kicker,
                  style: textStyle.copyWith(
                    color: colors.soft,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              Text(
                place.title,
                style: textStyle.copyWith(fontSize: titleSize, fontWeight: FontWeight.w900),
              ),
              if (!compact)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    place.phrase,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(color: colors.soft, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      place.state,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(fontSize: stateSize, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  arrowDot,
                ],
              ),
              if (strip != null) ...[const SizedBox(height: 10), strip!],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (place.badge)
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Text(
                        '${place.badgeCount}',
                        style: const TextStyle(color: Color(0xFF2A1B0F), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Icon(place.icon, size: const [40.0, 48.0, 56.0][tier], color: colors.ink),
                ],
              ),
              const Spacer(),
              Text(
                place.title,
                style: textStyle.copyWith(fontSize: titleSize, fontWeight: FontWeight.w900),
              ),
              if (!compact)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      place.phrase,
                      maxLines: tier == 2 ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(
                        color: colors.soft,
                        fontSize: const [12.0, 13.0, 14.0][tier],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 26),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.ink.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        place.state,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.copyWith(fontSize: stateSize, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  arrowDot,
                ],
              ),
            ],
          );

    return SizedBox(
      height: height,
      child: Chunky(
        onTap: onTap,
        fill: colors.face,
        edge: colors.edge,
        radius: 24,
        padding: EdgeInsets.zero,
        minHeight: height - 4,
        clip: Clip.antiAlias,
        semanticsLabel: '${place.title}. ${place.state}. Toca para abrir',
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: _Ornament(room: place.room, ink: colors.ink, big: wide),
              ),
              Padding(padding: EdgeInsets.all(pad), child: content),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shapes at the back of a tile: each place has its own, so they tell
/// apart without the color.
class _Ornament extends StatelessWidget {
  const _Ornament({required this.room, required this.ink, required this.big});

  final Room room;
  final Color ink;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget shape(double size, double alpha, {bool ring = false, bool square = false, double turns = 0}) {
      final color = (room == Room.route ? (dark ? ink : Colors.white) : ink).withValues(alpha: alpha);
      return Transform.rotate(
        angle: turns,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: square ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: square ? BorderRadius.circular(size / 4) : null,
            color: ring ? null : color,
            border: ring ? Border.all(color: color, width: size / 8) : null,
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: switch (room) {
        Room.route => Stack(
          children: [
            Positioned(right: -30, top: -40, child: shape(big ? 170 : 120, 0.22)),
            Positioned(right: 4, top: -8, child: shape(big ? 110 : 80, 0.30)),
            Positioned(
              right: 30,
              top: big ? 22 : 16,
              child: Icon(Icons.flag_rounded, size: big ? 56 : 40, color: ink),
            ),
          ],
        ),
        Room.workshop => Stack(
          children: [
            Positioned(right: -14, top: -14, child: shape(big ? 130 : 96, 0.16, square: true, turns: 0.21)),
            Positioned(right: 40, top: 60, child: shape(big ? 80 : 56, 0.12, square: true, turns: -0.14)),
          ],
        ),
        _ => Stack(
          children: [
            Positioned(right: -26, top: -26, child: shape(big ? 150 : 112, 0.18, ring: true)),
            Positioned(right: 56, top: 70, child: shape(28, 0.22)),
          ],
        ),
      },
    );
  }
}

/// One dot per step of the path: done, the one that follows (it pulses) and
/// those left. Sixteen dots anticipate the road without showing it.
class _RouteDots extends StatefulWidget {
  const _RouteDots({required this.done, required this.next, required this.tier});

  final List<bool> done;
  final int next;
  final int tier;

  @override
  State<_RouteDots> createState() => _RouteDotsState();
}

class _RouteDotsState extends State<_RouteDots> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _pulsed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulsed) {
      _pulsed = true;
      // A few beats to say where to touch, not a loop that never rests.
      _pulse.repeat(reverse: true, count: 6);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF2A1B0F);
    final dot = const [8.0, 9.0, 11.0][widget.tier];
    final nextDot = const [13.0, 14.0, 17.0][widget.tier];
    return ExcludeSemantics(
      child: SizedBox(
        height: nextDot * 1.4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final (i, done) in widget.done.indexed)
              if (i == widget.next)
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Transform.scale(
                    scale: MediaQuery.disableAnimationsOf(context)
                        ? 1.15
                        : 1 + 0.3 * Curves.easeInOut.transform(_pulse.value),
                    child: Container(
                      width: nextDot,
                      height: nextDot,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: ink, width: 3),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? ink : null,
                    border: done ? null : Border.all(color: const Color(0xFF6B4A00), width: 2),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// A task from the teacher, waiting: one touch opens it.
class _TaskStrip extends StatelessWidget {
  const _TaskStrip({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = PlaceColors.classes(context);
    return SizedBox(
      height: 56,
      child: Chunky(
        onTap: onTap,
        fill: colors.face,
        edge: colors.edge,
        radius: 18,
        minHeight: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tarea de tu profe: $title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.ink, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: colors.ink),
          ],
        ),
      ),
    );
  }
}

/// The top of Inicio: the mascot says something. Touch it and it jumps and
/// says another thing.
class _Hero extends StatefulWidget {
  const _Hero({required this.name, required this.next, required this.started, this.mascotHeight = 97});

  final double mascotHeight;
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

  /// Her mood: proud when the path is done, otherwise a different face each
  /// time she is touched.
  MascotPose get _pose {
    if (widget.next == null) return MascotPose.orgulloso;
    if (_phrase == 0) return MascotPose.hola;
    const moods = [MascotPose.guino, MascotPose.idea, MascotPose.estudiando, MascotPose.yHoy, MascotPose.programando];
    return moods[(_phrase - 1) % moods.length];
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
                child: Mascota(pose: _pose, size: widget.mascotHeight),
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
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.15,
                      child: Text(
                        _greeting,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
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

TextStyle? monoLabel(ThemeData theme) => theme.textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono');

class _RouteRoom extends StatefulWidget {
  const _RouteRoom({required this.settings, required this.actions});

  final ViewSettings settings;
  final RoomActions actions;

  @override
  State<_RouteRoom> createState() => _RouteRoomState();
}

class _RouteRoomState extends State<_RouteRoom> {
  final _scroll = ScrollController();
  final _away = ValueNotifier<bool>(false);

  // Heights of the pieces of the road, to know where each one starts without
  // building them all (the road can have many units).
  static const _phraseHeight = 64.0;
  static const _tabsHeight = 56.0;
  static const _levelHeaderHeight = 176.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateAway);
    // On entering, the road opens where the person is.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = _targetOffset();
      if (target > 0) _scroll.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _away.dispose();
    super.dispose();
  }

  bool get _manyLevels => routeLevels.length > 1;

  RouteStep? get _next => nextStep(lessons: widget.settings.doneLessons, challenges: widget.settings.doneChallenges);

  /// Where the level number [level] starts.
  double _levelOffset(int level) {
    var offset = _phraseHeight + (_manyLevels ? _tabsHeight : 0);
    for (var i = 0; i < level; i++) {
      offset += _levelHeaderHeight + routeLevels[i].groups.fold<double>(0, (sum, g) => sum + _PathGroup.heightFor(g));
    }
    return offset;
  }

  /// The scroll offset that shows the next step a third of the way down.
  double _targetOffset() {
    final next = _next;
    if (next == null) return 0;
    var level = 0;
    var offset = 0.0;
    for (final (l, lv) in routeLevels.indexed) {
      var inLevel = _levelOffset(l) + _levelHeaderHeight;
      for (final group in lv.groups) {
        final i = group.steps.indexWhere((s) => s.id == next.id);
        if (i >= 0) {
          level = l;
          offset = inLevel + _PathGroup.bannerHeight + i * _PathGroup.rowHeight;
          break;
        }
        inLevel += _PathGroup.heightFor(group);
      }
      if (offset > 0) break;
    }
    if (level == 0 && offset == 0) return 0;
    final viewport = _scroll.hasClients ? _scroll.position.viewportDimension : 600.0;
    return math.max(0, offset - viewport * 0.3);
  }

  void _updateAway() {
    if (!_scroll.hasClients) return;
    final far = (_scroll.offset - _targetOffset()).abs() > _scroll.position.viewportDimension * 0.9;
    if (far != _away.value) _away.value = far;
  }

  void _goTo(double offset) {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final to = math.max(0.0, math.min(offset, math.max(max, offset)));
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(to);
    } else {
      _scroll.animateTo(to, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = widget.settings;
    final next = _next;
    final banners = [scheme.primaryContainer, scheme.tertiaryContainer, scheme.secondaryContainer];
    final levelColors = [PlaceColors.route(context), PlaceColors.workshop(context), PlaceColors.classes(context)];
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(16, _isWide(context) ? 12 : 0, 16, 96),
              children: [
                SizedBox(
                  height: _phraseHeight,
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.15,
                    child: const _Phrase(
                      'Tu camino, de arriba hacia abajo. Toca un paso para entrar; puedes saltar a cualquiera.',
                    ),
                  ),
                ),
                if (_manyLevels)
                  SizedBox(
                    height: _tabsHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final (l, level) in routeLevels.indexed)
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: ActionChip(
                              label: Text('Nivel ${level.number} · ${level.title}'),
                              onPressed: () => _goTo(_levelOffset(l)),
                            ),
                          ),
                      ],
                    ),
                  ),
                for (final (l, level) in routeLevels.indexed) ...[
                  SizedBox(
                    height: _levelHeaderHeight,
                    child: _LevelHeader(
                      number: level.number,
                      level: level,
                      colors: levelColors[l % levelColors.length],
                      done: level.steps
                          .where(
                            (st) => isStepDone(st, lessons: settings.doneLessons, challenges: settings.doneChallenges),
                          )
                          .length,
                    ),
                  ),
                  for (final (g, group) in level.groups.indexed)
                    Appear(
                      index: g,
                      child: SizedBox(
                        height: _PathGroup.heightFor(group),
                        child: _PathGroup(
                          group: group,
                          banner: banners[g % banners.length],
                          doneLessons: settings.doneLessons,
                          doneChallenges: settings.doneChallenges,
                          nextId: next?.id,
                          onOpen: widget.actions.onOpenStep,
                        ),
                      ),
                    ),
                ],
                Text(
                  'Nada está bloqueado: puedes saltar a cualquier lección o reto. Cada reto trae pruebas y pistas.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        if (next != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: _away,
                builder: (context, away, _) => AnimatedSlide(
                  duration: motion(context, const Duration(milliseconds: 220)),
                  offset: away ? Offset.zero : const Offset(0, 2),
                  child: AnimatedOpacity(
                    duration: motion(context, const Duration(milliseconds: 220)),
                    opacity: away ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !away,
                      child: FilledButton.icon(
                        onPressed: () => _goTo(_targetOffset()),
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text('Ir a mi paso'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The big banner of a level: its number, its name, what it is about and how
/// far along the person is.
class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.number, required this.level, required this.colors, required this.done});

  final int number;
  final RouteLevel level;
  final PlaceColors colors;
  final int done;

  @override
  Widget build(BuildContext context) {
    final total = level.steps.length;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.face,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: colors.edge, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  level.optional ? 'NIVEL $number · OPCIONAL' : 'NIVEL $number',
                  style: TextStyle(color: colors.soft, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    level.title,
                    style: TextStyle(color: colors.ink, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                ),
                Text(
                  level.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.soft, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : done / total,
                          minHeight: 10,
                          color: colors.ink,
                          backgroundColor: colors.ink.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$done de $total',
                      style: TextStyle(color: colors.ink, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A unit of the path: a banner that says what it is for and, under it, the
/// steps as round nodes along a winding road, as in a board game. The last
/// node is a cup that lights up when the unit is done.
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

  static const rowHeight = 152.0;
  static const bannerHeight = 112.0;
  static const _nodeTop = 34.0;
  static const _nodeSize = 68.0;

  /// The room a unit takes: its banner, one row per step and one for the cup.
  static double heightFor(RouteGroup group) => bannerHeight + (group.steps.length + 1) * rowHeight + 20;

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
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.15,
            child: Container(
              width: double.infinity,
              height: bannerHeight - 8,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: complete ? Colors.white : scheme.onSurface,
                          ),
                        ),
                        Text(
                          group.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final amplitude = math.min(width * 0.26, 96.0);
                final nodes = steps.length + 1;
                final centers = [
                  for (var i = 0; i < nodes; i++)
                    Offset(width / 2 + amplitude * math.sin(i * 1.25), i * rowHeight + _nodeTop + _nodeSize / 2),
                ];
                return Stack(
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
                        top: i * rowHeight,
                        width: 160,
                        height: rowHeight,
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
                    Positioned(
                      left: centers.last.dx - 80,
                      top: steps.length * rowHeight,
                      width: 160,
                      height: rowHeight,
                      child: _CupNode(complete: complete, size: _nodeSize, top: _nodeTop, steps: steps.length),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The cup at the end of a unit: grey until its steps are done, gold after.
class _CupNode extends StatelessWidget {
  const _CupNode({required this.complete, required this.size, required this.top, required this.steps});

  final bool complete;
  final double size;
  final double top;
  final int steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gold = PlaceColors.route(context);
    return Semantics(
      button: true,
      label: complete ? 'Unidad completa' : 'Copa de la unidad: termina sus $steps pasos',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: complete
            ? null
            : () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Termina los $steps pasos de esta unidad para ganar la copa.'))),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: complete ? gold.face : scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: complete ? gold.edge : scheme.outlineVariant, offset: const Offset(0, 5)),
                  ],
                ),
                child: Icon(Icons.emoji_events_rounded, size: 34, color: complete ? gold.ink : scheme.outline),
              ),
            ),
            Positioned(
              top: top + size + 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    complete ? 'Unidad completa' : 'Copa de la unidad',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: complete ? FontWeight.w800 : FontWeight.w600,
                      color: complete ? null : scheme.onSurfaceVariant,
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
              const Mascota(pose: MascotPose.dormido, size: 96),
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
  const _RoomCard({this.margin = EdgeInsets.zero, required this.child});

  final EdgeInsetsGeometry margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(margin: margin, child: child);
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
