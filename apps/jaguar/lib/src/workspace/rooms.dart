import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../challenges/challenges.dart';
import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../programs/examples.dart';
import '../programs/program_store.dart';
import '../settings.dart';
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
  });

  final Cloud? cloud;
  final Room room;
  final ValueChanged<Room> onRoom;
  final ViewSettings settings;
  final ProgramStore store;
  final ExerciseStore exercises;
  final RoomActions actions;

  static const _titles = {Room.home: 'Jaguar', Room.route: 'Ruta', Room.classes: 'Clases', Room.workshop: 'Taller'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: room == Room.home
            ? Row(
                children: [
                  Image.asset('assets/images/mascota.png', width: 36, height: 36),
                  const SizedBox(width: 10),
                  const Text('Jaguar'),
                ],
              )
            : Text(_titles[room]!),
        actions: [
          if (room == Room.home)
            IconButton(tooltip: 'Ajustes', icon: const Icon(Icons.settings_outlined), onPressed: actions.onOpenSettings),
          if (room == Room.workshop) ..._workshopActions(context),
          if (room == Room.classes && cloud != null) _classesAction(context, cloud!),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([settings, store, exercises, ?cloud]),
        builder: (context, _) => switch (room) {
          Room.home => _HomeRoom(settings: settings, store: store, exercises: exercises, actions: actions, onRoom: onRoom),
          Room.route => _RouteRoom(settings: settings, actions: actions),
          Room.classes => _ClassesRoom(cloud: cloud, exercises: exercises, actions: actions),
          Room.workshop => _WorkshopRoom(store: store, actions: actions),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: room.index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: theme.colorScheme.surfaceContainer,
        onDestinationSelected: (index) => onRoom(Room.values[index]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Ruta'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Clases'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Taller'),
        ],
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

/// A content column that stays readable on a wide phone or a small tablet.
class _Page extends StatelessWidget {
  const _Page({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: children),
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
    final done = settings.doneChallenges;
    final solved = challenges.where((c) => done.contains(c.id)).length;
    final next = challenges.where((c) => !done.contains(c.id)).firstOrNull;
    final name = exercises.studentName;
    final task = exercises.received.lastOrNull;
    final recent = store.programs.take(3).toList();

    return _Page(
      children: [
        Semantics(
          header: true,
          child: Text(name == null ? 'Hola' : 'Hola, $name', style: theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: 2),
        Text(
          'Esto es lo que sigue para ti.',
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (task != null) ...[
          _RoomCard(
            color: scheme.primaryContainer,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEL PROFE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(task.title, style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer)),
                  const SizedBox(height: 10),
                  FilledButton(onPressed: () => actions.onOpenExercise(task), child: const Text('Abrir ejercicio')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _RoomCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RUTA · TU SIGUIENTE PASO',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next == null ? 'Terminaste el nivel 1' : next.exercise.title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Nivel 1 · llevas $solved de ${challenges.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: solved / challenges.length, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 12),
                if (next != null)
                  FilledButton(
                    onPressed: () => actions.onOpenChallenge(next),
                    child: Text(solved == 0 ? 'Empezar' : 'Continuar'),
                  )
                else
                  OutlinedButton(onPressed: () => onRoom(Room.route), child: const Text('Ver la ruta')),
              ],
            ),
          ),
        ),
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
          for (final program in recent)
            _RoomCard(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                minVerticalPadding: 12,
                title: Text(program.name, style: monoLabel(theme)),
                trailing: Text(timeAgo(program.updatedAt), style: theme.textTheme.bodySmall),
                onTap: () => actions.onOpenProgram(program),
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
    );
  }
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
    final done = settings.doneChallenges;
    final solved = challenges.where((c) => done.contains(c.id)).length;
    final nextId = challenges.where((c) => !done.contains(c.id)).firstOrNull?.id;

    return _Page(
      children: [
        _RoomCard(
          margin: EdgeInsets.zero,
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
                          Text(
                            'NIVEL 1',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text('Lógica: pensar en pasos', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    ),
                    Text('$solved de ${challenges.length}', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: solved / challenges.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              for (final (index, challenge) in challenges.indexed)
                _ChallengeRow(
                  index: index,
                  challenge: challenge,
                  done: done.contains(challenge.id),
                  isNext: challenge.id == nextId,
                  onTap: () => actions.onOpenChallenge(challenge),
                ),
              const SizedBox(height: 6),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nada está bloqueado: puedes saltar a cualquier reto. Cada uno trae pruebas y pistas.',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.index,
    required this.challenge,
    required this.done,
    required this.isNext,
    required this.onTap,
  });

  final int index;
  final Challenge challenge;
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

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
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: done
                          ? Icon(Icons.check, color: Colors.green.shade700, semanticLabel: 'hecho')
                          : isNext
                          ? Icon(Icons.play_arrow, color: scheme.onPrimaryContainer, semanticLabel: 'siguiente')
                          : Text('${index + 1}', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            challenge.exercise.title.replaceFirst(RegExp(r'^Reto \d+ · '), ''),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isNext ? FontWeight.w500 : FontWeight.w400,
                              color: isNext ? scheme.onPrimaryContainer : null,
                            ),
                          ),
                          Text(
                            challenge.subject,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isNext ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isNext)
                      Text('Continuar', style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
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
        if (actions.onOpenTeacher case final openTeacher?) ...[
          _RoomCard(
            child: ListTile(
              minVerticalPadding: 14,
              leading: const Icon(Icons.school_outlined),
              title: const Text('Mis ejercicios'),
              subtitle: const Text('Crea ejercicios, compártelos y revisa lo que entregan.'),
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
          _RoomCard(
            child: ListTile(
              minVerticalPadding: 14,
              leading: const Icon(Icons.cloud_off_outlined),
              title: const Text('Clases en línea'),
              subtitle: const Text('Necesitan conexión a internet.'),
            ),
          ),
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
                'Aquí quedan tus programas, retos y tareas.',
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
    final shown = q.isEmpty ? all : [for (final p in all) if (normalize(p.name).contains(q)) p];
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
    final label = id == null ? 'Propio' : (challengeById(id) != null ? 'Reto' : 'Tarea');
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
