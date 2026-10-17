import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../cloud/account_dialog.dart';
import '../cloud/cloud.dart';
import '../cloud/community_screen.dart';

import 'exercise_editor_screen.dart';
import 'exercise_store.dart';
import 'project_screen.dart';

/// The teacher's exercise bank, reusable across groups and semesters.
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key, required this.store, required this.onTryAsStudent, this.cloud});

  final ExerciseStore store;
  final ValueChanged<Exercise> onTryAsStudent;

  /// To share exercises with other teachers; null offline.
  final Cloud? cloud;

  Future<void> _share(BuildContext context, Exercise exercise) async {
    final cloud = this.cloud!;
    if (!cloud.signedIn) {
      await showAccountDialog(context, cloud);
      if (!cloud.signedIn || !context.mounted) return;
    }
    final published = await showDialog<bool>(
      context: context,
      builder: (_) => PublishDialog(cloud: cloud, source: '', exercise: exercise.toJson()),
    );
    if (published == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compartido: otros profesores ya pueden asignarlo a sus clases.')));
    }
  }

  void _edit(BuildContext context, [Exercise? exercise]) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExerciseEditorScreen(store: store, exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ejercicios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo ejercicio'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final exercises = store.authored;
          if (exercises.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/mascota.png', width: 96, height: 96),
                    const SizedBox(height: 16),
                    Text('Crea tu primer ejercicio', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Escribe el enunciado y sus casos de prueba, y proyéctalo como QR. '
                      'Tus alumnos lo resuelven y Jaguar les dice si está bien.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final exercise in exercises)
                ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(exercise.title),
                  subtitle: Text(
                    '${exercise.cases.length} casos'
                    '${store.solutionFor(exercise.id) != null ? ' · con solución' : ''}',
                  ),
                  onTap: () => _edit(context, exercise),
                  trailing: MenuAnchor(
                    builder: (context, controller, _) => IconButton(
                      tooltip: 'Opciones',
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.qr_code_2),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => ProjectScreen(exercise: exercise)),
                        ),
                        child: const Text('Proyectar'),
                      ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.play_circle_outline),
                        onPressed: () => onTryAsStudent(exercise),
                        child: const Text('Probar como alumno'),
                      ),
                      if (cloud != null)
                        MenuItemButton(
                          leadingIcon: const Icon(Icons.public),
                          onPressed: () => _share(context, exercise),
                          child: const Text('Compartir en el banco'),
                        ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, exercise),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar "${exercise.title}"?'),
        content: const Text('Los alumnos que ya lo abrieron conservan su copia.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed ?? false) store.delete(exercise.id);
  }
}
