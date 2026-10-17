import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cloud/cloud.dart';
import '../exercises/exercise_store.dart';
import '../programs/program_store.dart';
import 'programs_drawer.dart';

/// The desktop's always-visible list of programs, like a file explorer.
class ProgramsSidebar extends StatefulWidget {
  const ProgramsSidebar({
    super.key,
    required this.store,
    required this.exercises,
    required this.onSelect,
    required this.onNew,
    required this.onDuplicate,
    required this.onSaveFile,
    required this.onMakeExercise,
    required this.cloud,
    required this.onOpenCommunity,
    required this.onOpenClasses,
    required this.onAccount,
    required this.onOpenTeacher,
    required this.onChangeName,
  });

  final ProgramStore store;
  final ExerciseStore exercises;
  final ValueChanged<SavedProgram> onSelect;
  final VoidCallback onNew;
  final ValueChanged<SavedProgram> onDuplicate;
  final ValueChanged<SavedProgram> onSaveFile;
  final ValueChanged<SavedProgram> onMakeExercise;
  final Cloud? cloud;
  final VoidCallback onOpenCommunity;
  final VoidCallback onOpenClasses;
  final VoidCallback onAccount;
  final VoidCallback onOpenTeacher;
  final VoidCallback onChangeName;

  @override
  State<ProgramsSidebar> createState() => _ProgramsSidebarState();
}

class _ProgramsSidebarState extends State<ProgramsSidebar> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // On the web a right click over the list opens our menu, not the
    // browser's. The editor keeps the browser's (spell check, paste).
    return MouseRegion(
      onEnter: kIsWeb ? (_) => BrowserContextMenu.disableContextMenu() : null,
      onExit: kIsWeb ? (_) => BrowserContextMenu.enableContextMenu() : null,
      child: Material(
        color: scheme.surfaceContainerLow,
        child: ListenableBuilder(
          listenable: Listenable.merge([widget.store, widget.exercises, ?widget.cloud]),
          builder: (context, _) {
            final store = widget.store;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      _SectionHeader(
                        title: 'Mis programas',
                        trailing: _TinyButton(icon: Icons.add, tooltip: 'Nuevo programa', onPressed: widget.onNew),
                      ),
                      for (final program in store.programs)
                        _SidebarRow(
                          icon: program.exerciseId == null ? Icons.description_outlined : Icons.assignment_outlined,
                          label: program.name,
                          tooltip: 'Editado ${timeAgo(program.updatedAt)}',
                          selected: identical(program, store.current),
                          badge: _testsBadge(context, program),
                          onTap: () => widget.onSelect(program),
                          menu: [
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.copy_outlined, size: 18),
                              onPressed: () => widget.onDuplicate(program),
                              child: const Text('Duplicar'),
                            ),
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.save_alt, size: 18),
                              onPressed: () => widget.onSaveFile(program),
                              child: const Text('Guardar como .psc…'),
                            ),
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.auto_awesome, size: 18),
                              onPressed: () => widget.onMakeExercise(program),
                              child: const Text('Crear ejercicio con este programa…'),
                            ),
                            const Divider(height: 1),
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => confirmDeleteProgram(context, store, program, widget.onSelect),
                              child: const Text('Eliminar…'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 4),
                _SidebarRow(
                  icon: Icons.public,
                  label: 'Comunidad',
                  tooltip: 'Programas y ejercicios que comparten otras personas, y ejemplos',
                  onTap: widget.onOpenCommunity,
                ),
                if (widget.cloud != null)
                  _SidebarRow(
                    icon: Icons.groups_outlined,
                    label: 'Mis clases',
                    tooltip: 'Únete con el código de tu profesor, o crea una clase si eres profesor',
                    onTap: widget.onOpenClasses,
                  ),
                const Divider(height: 9),
                if (widget.cloud != null)
                  _SidebarRow(
                    icon: widget.cloud!.signedIn ? Icons.account_circle : Icons.login,
                    label: widget.cloud!.user?.alias ?? 'Entrar en línea',
                    tooltip: widget.cloud!.signedIn ? 'Tu cuenta' : 'Para clases y comunidad; no es obligatorio',
                    onTap: widget.onAccount,
                  ),
                _SidebarRow(
                  icon: Icons.badge_outlined,
                  label: widget.exercises.studentName ?? 'Escribe tu nombre',
                  tooltip: 'Aparece al mostrar un ejercicio al profesor',
                  onTap: widget.onChangeName,
                ),
                _SidebarRow(
                  icon: Icons.school_outlined,
                  label: 'Mis ejercicios',
                  tooltip: 'Profesor: ejercicios con pruebas que se generan solas',
                  onTap: widget.onOpenTeacher,
                ),
                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ✓ when the last Probar passed everything, "2/3" otherwise.
Widget? _testsBadge(BuildContext context, SavedProgram program) {
  final total = program.testsTotal;
  if (total == null) return null;
  final passed = program.testsPassed ?? 0;
  if (passed == total) {
    return Tooltip(
      message: 'Pasa todas sus pruebas',
      child: Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
    );
  }
  return Tooltip(
    message: 'Pasa $passed de $total pruebas',
    child: Text(
      '$passed/$total',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.error),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 4),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            Expanded(child: Text(title.toUpperCase(), style: style)),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A compact row with a hover state and, optionally, a "⋯" menu that also
/// opens with a right click.
class _SidebarRow extends StatefulWidget {
  const _SidebarRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tooltip,
    this.selected = false,
    this.menu,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? tooltip;
  final bool selected;
  final VoidCallback onTap;
  final List<Widget>? menu;

  /// Shown at the end of the row, except while the "⋯" button is.
  final Widget? badge;

  @override
  State<_SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends State<_SidebarRow> {
  final _menu = MenuController();
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = widget.selected ? scheme.onSecondaryContainer : scheme.onSurface;
    final menu = widget.menu;
    final showMenuButton = menu != null && (_hovered || _menu.isOpen);

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Material(
        color: widget.selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onSecondaryTapUp: menu == null ? null : (details) => _menu.open(position: details.localPosition),
          onHover: (hovered) => setState(() => _hovered = hovered),
          child: SizedBox(
            height: 30,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 2),
              child: Row(
                children: [
                  Icon(widget.icon, size: 17, color: foreground.withValues(alpha: 0.8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: widget.selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  if (!showMenuButton && widget.badge != null)
                    Padding(padding: const EdgeInsets.only(right: 6), child: widget.badge),
                  if (showMenuButton)
                    _TinyButton(
                      icon: Icons.more_horiz,
                      tooltip: 'Más acciones',
                      onPressed: () => _menu.isOpen ? _menu.close() : _menu.open(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (menu != null) {
      row = MenuAnchor(controller: _menu, menuChildren: menu, onClose: () => setState(() {}), child: row);
    }
    if (widget.tooltip != null) {
      row = Tooltip(message: widget.tooltip, waitDuration: const Duration(milliseconds: 600), child: row);
    }
    return row;
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 26, height: 26),
    );
  }
}
