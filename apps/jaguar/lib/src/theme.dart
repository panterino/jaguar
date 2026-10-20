import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Jaguar yellow, from the 2019 brand and the mascot.
const jaguarYellow = Color(0xFFF4B723);

/// The mascot's eye blue.
const jaguarBlue = Color(0xFF00A8F0);

const monoFamily = 'JetBrainsMono';

/// JetBrains Mono draws `<-` as an arrow; students must see what they type.
const monoFeatures = [FontFeature.disable('calt'), FontFeature.disable('liga')];

const monoStyle = TextStyle(fontFamily: monoFamily, fontFeatures: monoFeatures);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: jaguarYellow,
    brightness: brightness,
    secondary: brightness == Brightness.light ? const Color(0xFF0077B6) : jaguarBlue,
  );
  final desktop = switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
    _ => false,
  };
  return ThemeData(
    colorScheme: scheme,
    // Menus sized for a mouse, like other desktop apps.
    menuButtonTheme: desktop
        ? MenuButtonThemeData(
            style: MenuItemButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontSize: 13),
            ),
          )
        : null,
    useMaterial3: true,
    // Compact controls with a mouse, comfortable ones for fingers.
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(backgroundColor: scheme.surfaceContainer, surfaceTintColor: Colors.transparent),
  );
}

/// Colors for syntax highlighting, tuned per brightness.
class SyntaxColors {
  const SyntaxColors({
    required this.keyword,
    required this.builtin,
    required this.string,
    required this.number,
    required this.comment,
    required this.operator,
    required this.type,
  });

  final Color keyword;
  final Color builtin;
  final Color string;
  final Color number;
  final Color comment;
  final Color operator;
  final Color type;

  static const _light = SyntaxColors(
    keyword: Color(0xFF8A4B00),
    builtin: Color(0xFF0060A0),
    string: Color(0xFF2E7D32),
    number: Color(0xFF9C27B0),
    comment: Color(0xFF6E6E6E),
    operator: Color(0xFFB0006A),
    type: Color(0xFF00796B),
  );

  static const _dark = SyntaxColors(
    keyword: Color(0xFFF4B723),
    builtin: Color(0xFF6CC4FF),
    string: Color(0xFF9CD67E),
    number: Color(0xFFD7A6F5),
    comment: Color(0xFF9A9A9A),
    operator: Color(0xFFFF8AB8),
    type: Color(0xFF6ED8C8),
  );

  static SyntaxColors of(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

/// How long an animation lasts: [duration], or a short fade when the person
/// turned animations off in the system settings.
Duration motion(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? const Duration(milliseconds: 150) : duration;
