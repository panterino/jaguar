import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings.dart';

/// One description of the menus, drawn as a menu bar inside the window (web,
/// Windows, Linux) or handed to the macOS system menu bar. Shortcuts are
/// registered from the same entries, so the menu always tells the truth.
class AppMenu {
  const AppMenu(this.label, this.entries);

  final String label;
  final List<AppMenuEntry> entries;
}

sealed class AppMenuEntry {
  const AppMenuEntry();
}

class AppMenuItem extends AppMenuEntry {
  const AppMenuItem(
    this.label, {
    this.onSelected,
    this.shortcut,
    this.extraShortcuts = const [],
    this.icon,
    this.checked,
    this.textFieldHandles = false,
  });

  final String label;
  final VoidCallback? onSelected;
  final SingleActivator? shortcut;

  /// Also trigger the item, but are not shown (F5 next to Ctrl+Enter).
  final List<SingleActivator> extraShortcuts;
  final IconData? icon;

  /// For options that are on or off; null for plain commands.
  final bool? checked;

  /// The shortcut is shown but the text field already handles it (copy,
  /// paste, undo), so it is not registered again.
  final bool textFieldHandles;
}

class AppSubmenu extends AppMenuEntry {
  const AppSubmenu(this.label, this.entries);

  final String label;
  final List<AppMenuEntry> entries;
}

class AppMenuDivider extends AppMenuEntry {
  const AppMenuDivider();
}

/// Ctrl on Windows, Linux and the web on a PC; Cmd on a Mac.
SingleActivator primary(LogicalKeyboardKey key, {bool shift = false, bool alt = false}) =>
    SingleActivator(key, control: !isApple, meta: isApple, shift: shift, alt: alt);

/// Shortcut bindings for every item that has one.
Map<ShortcutActivator, VoidCallback> menuShortcuts(List<AppMenu> menus) {
  final bindings = <ShortcutActivator, VoidCallback>{};
  void visit(List<AppMenuEntry> entries) {
    for (final entry in entries) {
      switch (entry) {
        case AppMenuItem(:final onSelected?, textFieldHandles: false):
          for (final activator in [?entry.shortcut, ...entry.extraShortcuts]) {
            bindings[activator] = onSelected;
          }
        case AppSubmenu(:final entries):
          visit(entries);
        case _:
          break;
      }
    }
  }

  for (final menu in menus) {
    visit(menu.entries);
  }
  return bindings;
}

/// The menu bar drawn by Flutter, for the web, Windows and Linux.
class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key, required this.menus, this.leading});

  final List<AppMenu> menus;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            ?leading,
            MenuBar(
              style: const MenuStyle(
                elevation: WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              children: [
                for (final menu in menus)
                  SubmenuButton(
                    style: _barButtonStyle,
                    menuChildren: _buildEntries(menu.entries),
                    child: Text(menu.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static final _barButtonStyle = ButtonStyle(
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
    minimumSize: const WidgetStatePropertyAll(Size(0, 30)),
    textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 13)),
  );

  List<Widget> _buildEntries(List<AppMenuEntry> entries) => [
    for (final entry in entries)
      switch (entry) {
        AppMenuItem() => MenuItemButton(
          onPressed: entry.onSelected,
          shortcut: entry.shortcut,
          leadingIcon: entry.checked != null
              ? Icon(entry.checked! ? Icons.check : null, size: 18)
              : Icon(entry.icon, size: 18),
          child: Text(entry.label),
        ),
        AppSubmenu() => SubmenuButton(
          leadingIcon: const Icon(null, size: 18),
          menuChildren: _buildEntries(entry.entries),
          child: Text(entry.label),
        ),
        AppMenuDivider() => const Divider(height: 8),
      },
  ];
}

/// The same menus in the macOS menu bar, with the standard app and window
/// menus around them.
List<PlatformMenuItem> platformMenus(List<AppMenu> menus, {required String appName, VoidCallback? onAbout}) {
  List<PlatformMenuItem> build(List<AppMenuEntry> entries) {
    final groups = <List<PlatformMenuItem>>[[]];
    for (final entry in entries) {
      switch (entry) {
        case AppMenuDivider():
          groups.add([]);
        case AppMenuItem():
          groups.last.add(
            PlatformMenuItem(
              label: entry.checked == true ? '✓ ${entry.label}' : entry.label,
              shortcut: entry.shortcut,
              onSelected: entry.onSelected,
            ),
          );
        case AppSubmenu():
          groups.last.add(PlatformMenu(label: entry.label, menus: build(entry.entries)));
      }
    }
    return [for (final group in groups.where((g) => g.isNotEmpty)) PlatformMenuItemGroup(members: group)];
  }

  PlatformMenuItem? provided(PlatformProvidedMenuItemType type) =>
      PlatformProvidedMenuItem.hasMenu(type) ? PlatformProvidedMenuItem(type: type) : null;

  // macOS rejects empty groups.
  List<PlatformMenuItem> groups(List<List<PlatformMenuItem?>> groups) => [
    for (final group in groups.map((g) => g.nonNulls.toList()))
      if (group.isNotEmpty) PlatformMenuItemGroup(members: group),
  ];

  return [
    PlatformMenu(
      label: appName,
      menus: groups([
        [
          if (onAbout != null)
            PlatformMenuItem(label: 'Acerca de $appName', onSelected: onAbout)
          else
            provided(PlatformProvidedMenuItemType.about),
        ],
        [provided(PlatformProvidedMenuItemType.servicesSubmenu)],
        [
          provided(PlatformProvidedMenuItemType.hide),
          provided(PlatformProvidedMenuItemType.hideOtherApplications),
          provided(PlatformProvidedMenuItemType.showAllApplications),
        ],
        [provided(PlatformProvidedMenuItemType.quit)],
      ]),
    ),
    for (final menu in menus) PlatformMenu(label: menu.label, menus: build(menu.entries)),
    PlatformMenu(
      label: 'Ventana',
      menus: groups([
        [
          provided(PlatformProvidedMenuItemType.minimizeWindow),
          provided(PlatformProvidedMenuItemType.zoomWindow),
          provided(PlatformProvidedMenuItemType.toggleFullScreen),
        ],
        [provided(PlatformProvidedMenuItemType.arrangeWindowsInFront)],
      ]),
    ),
  ];
}
