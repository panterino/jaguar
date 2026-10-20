import 'package:flutter/material.dart';

import '../console/console_session.dart';
import '../editor/completions.dart';
import '../editor/syntax_controller.dart';
import '../settings.dart';

/// The compact row of buttons under the menu bar.
class DesktopToolbar extends StatelessWidget {
  const DesktopToolbar({
    super.key,
    required this.sidebarVisible,
    required this.running,
    required this.onToggleSidebar,
    required this.onNew,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onRun,
    required this.viewSwitch,
    this.onPause,
    required this.onShare,
    required this.basic,
    required this.modeSwitch,
    this.onCheck,
    this.checking = false,
  });

  /// Básico: buttons with text and no panel toggle.
  final bool basic;
  final Widget modeSwitch;

  final bool sidebarVisible;
  final bool running;
  final VoidCallback onToggleSidebar;
  final VoidCallback onNew;
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onRun;

  /// Pseudocódigo | Diagrama | Ambos.
  final Widget viewSwitch;

  /// Pausar, while a program runs normally.
  final VoidCallback? onPause;
  final VoidCallback onShare;

  /// Shown while the program solves an exercise.
  final VoidCallback? onCheck;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            // On a narrow window the left tools scroll instead of overflowing.
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (basic) ...[
                      _LabeledTool(
                        icon: Icons.note_add_outlined,
                        label: 'Nuevo',
                        tooltip: 'Nuevo programa',
                        onPressed: onNew,
                      ),
                      _LabeledTool(
                        icon: Icons.folder_open_outlined,
                        label: 'Abrir',
                        tooltip: 'Abrir archivo (.psc). También abre archivos de otros programas de pseudocódigo',
                        onPressed: onOpenFile,
                      ),
                      _LabeledTool(
                        icon: Icons.save_alt,
                        label: 'Guardar',
                        tooltip: 'Guardar como .psc (${shortcutLabel('S')})',
                        onPressed: onSaveFile,
                      ),
                    ] else ...[
                      ToolbarIcon(
                        icon: sidebarVisible ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                        tooltip: '${sidebarVisible ? 'Ocultar' : 'Mostrar'} programas (${shortcutLabel('B')})',
                        onPressed: onToggleSidebar,
                      ),
                      const _ToolbarSeparator(),
                      ToolbarIcon(icon: Icons.note_add_outlined, tooltip: 'Nuevo programa', onPressed: onNew),
                      ToolbarIcon(
                        icon: Icons.folder_open_outlined,
                        tooltip: 'Abrir archivo .psc (${shortcutLabel('O')})',
                        onPressed: onOpenFile,
                      ),
                      ToolbarIcon(
                        icon: Icons.save_alt,
                        tooltip: 'Guardar como .psc (${shortcutLabel('S')})',
                        onPressed: onSaveFile,
                      ),
                    ],
                    const _ToolbarSeparator(),
                    Tooltip(
                      message: running ? 'Detener (Shift+F9)' : 'Ejecutar (${shortcutLabel('Enter')} o F9)',
                      child: FilledButton.icon(
                        onPressed: onRun,
                        icon: Icon(running ? Icons.stop : Icons.play_arrow, size: 18),
                        label: Text(running ? 'Detener' : 'Ejecutar'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          backgroundColor: running ? scheme.error : null,
                          foregroundColor: running ? scheme.onError : null,
                        ),
                      ),
                    ),
                    if (onPause != null) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Pausar y seguir paso a paso',
                        child: OutlinedButton.icon(
                          onPressed: onPause,
                          icon: const Icon(Icons.pause, size: 18),
                          label: const Text('Pausar'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                    if (onCheck != null) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: basic
                            ? 'Revisa tu programa con las pruebas del profesor'
                            : 'Revisa tu programa con las pruebas del profesor (${shortcutLabel('Enter', shift: true)})',
                        child: OutlinedButton.icon(
                          onPressed: checking ? null : onCheck,
                          icon: checking
                              ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.fact_check_outlined, size: 18),
                          label: const Text('Probar'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                    const _ToolbarSeparator(),
                    viewSwitch,
                  ],
                ),
              ),
            ),
            if (basic)
              _LabeledTool(
                icon: Icons.qr_code_2,
                label: 'Compartir',
                tooltip: 'Llévalo a otro dispositivo con un QR o un enlace',
                onPressed: onShare,
              )
            else
              ToolbarIcon(icon: Icons.qr_code_2, tooltip: 'Compartir con QR o enlace', onPressed: onShare),
            const SizedBox(width: 8),
            modeSwitch,
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class ToolbarIcon extends StatelessWidget {
  const ToolbarIcon({super.key, required this.icon, required this.tooltip, required this.onPressed, this.size = 20});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints.tightFor(width: size + 14, height: size + 14),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
    );
  }
}

class _LabeledTool extends StatelessWidget {
  const _LabeledTool({required this.icon, required this.label, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}

class _ToolbarSeparator extends StatelessWidget {
  const _ToolbarSeparator();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 20, child: VerticalDivider(width: 14));
}

/// One tab of [PanelTabs], with an optional count like "2/3".
typedef PanelTab = ({String label, String? badge, Color? badgeColor, bool selected, VoidCallback onTap});

/// Tabs on top of the panel next to the code: Consola and Pruebas.
class PanelTabs extends StatelessWidget {
  const PanelTabs({super.key, required this.tabs, this.actions = const []});

  final List<PanelTab> tabs;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: 34,
      padding: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            InkWell(
              onTap: tab.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: tab.selected ? scheme.surface : null,
                  border: Border(
                    bottom: BorderSide(color: tab.selected ? scheme.primary : Colors.transparent, width: 2),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text(
                      tab.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tab.selected ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (tab.badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: (tab.badgeColor ?? scheme.onSurfaceVariant).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tab.badge!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tab.badgeColor ?? scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

/// The strip at the bottom of the window: what the program is doing, where
/// the cursor is and how the code is read.
class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.session,
    required this.code,
    required this.onGoToLine,
    required this.onAskLine,
    this.diagnostics,
    this.basic = false,
  });

  /// Errors found while typing: "1 problema" next to the state.
  final Diagnostics? diagnostics;

  /// Básico: only what the program is doing and the line.
  final bool basic;
  final ConsoleSession session;
  final SyntaxController code;
  final ValueChanged<int> onGoToLine;
  final VoidCallback onAskLine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final error = session.state == RunState.failed ? session.error : null;
    final (icon, text, color) = switch (session.state) {
      RunState.idle => (Icons.circle_outlined, 'Listo', null),
      RunState.running => (Icons.play_circle_outline, 'Ejecutando…', scheme.primary),
      RunState.waitingInput => (Icons.keyboard_outlined, 'Esperando un dato en la consola', scheme.secondary),
      RunState.waitingKey => (Icons.keyboard_return, 'Esperando una tecla', scheme.secondary),
      RunState.paused => (
        Icons.pause_circle_outline,
        'Paso a paso: va en la línea ${session.currentLine}',
        scheme.primary,
      ),
      RunState.finished => (Icons.check_circle_outline, 'Programa terminado', Colors.green.shade600),
      RunState.stopped => (Icons.stop_circle_outlined, 'Programa detenido', null),
      RunState.failed => (Icons.error_outline, '${error!.title} en la línea ${error.line}', scheme.error),
    };

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        child: Row(
          children: [
            _StatusItem(
              onTap: error == null ? null : () => onGoToLine(error.line),
              tooltip: error == null ? null : 'Ir a la línea ${error.line}',
              child: Row(
                children: [
                  Icon(icon, size: 14, color: color ?? scheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Text(text, style: TextStyle(color: color)),
                ],
              ),
            ),
            if (diagnostics != null)
              ListenableBuilder(
                listenable: diagnostics!,
                builder: (context, _) {
                  final problem = diagnostics!.shownError;
                  if (problem == null) return const SizedBox.shrink();
                  return _StatusItem(
                    onTap: () => onGoToLine(problem.line),
                    tooltip: 'Línea ${problem.line}: ${problem.message}',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 14, color: scheme.error),
                        const SizedBox(width: 4),
                        Text('1 problema', style: TextStyle(color: scheme.error)),
                      ],
                    ),
                  );
                },
              ),
            const Spacer(),
            ListenableBuilder(
              listenable: code,
              builder: (context, _) {
                final (line, column) = code.cursorPosition;
                return _StatusItem(
                  onTap: onAskLine,
                  tooltip: 'Ir a una línea (${shortcutLabel('G')})',
                  child: Text(basic ? 'Línea $line' : 'Lín. $line, col. $column'),
                );
              },
            ),
            if (!basic) ...[
              const _StatusItem(tooltip: 'Tab inserta 4 espacios', child: Text('Espacios: 4')),
              const _StatusItem(
                tooltip: 'Perfil flexible: Definir es opcional y los arreglos empiezan en 1',
                child: Text('Perfil flexible'),
              ),
              const _StatusItem(
                tooltip: 'Tus programas se guardan solos en este dispositivo',
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 13),
                    SizedBox(width: 4),
                    Text('Guardado en este equipo'),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({required this.child, this.onTap, this.tooltip});

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget item = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(child: child),
      ),
    );
    if (tooltip != null) item = Tooltip(message: tooltip, child: item);
    return item;
  }
}
