import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Jaguar yellow, from the 2019 brand and the mascot.
const jaguarYellow = Color(0xFFF4B723);

/// The mascot's eye blue.
const jaguarBlue = Color(0xFF00A8F0);

const monoFamily = 'JetBrainsMono';

/// JetBrains Mono draws `<-` as an arrow; students must see what they type.
const monoFeatures = [FontFeature.disable('calt'), FontFeature.disable('liga')];

const monoStyle = TextStyle(fontFamily: monoFamily, fontFeatures: monoFeatures);

/// The colors of the app: warm cream and brown, the mascot's yellow, a blue
/// for the teacher, a green for what is done and a violet for what is mine.
/// Fixed values rather than a seed, so the brand stays exactly the same.
ColorScheme _scheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(seedColor: jaguarYellow, brightness: brightness);
  return dark
      ? base.copyWith(
          surface: const Color(0xFF1A120B),
          surfaceContainerLowest: const Color(0xFF140D07),
          surfaceContainerLow: const Color(0xFF231810),
          surfaceContainer: const Color(0xFF2A1E14),
          surfaceContainerHigh: const Color(0xFF34271B),
          surfaceContainerHighest: const Color(0xFF3F3123),
          onSurface: const Color(0xFFF5E9DA),
          onSurfaceVariant: const Color(0xFFCDB9A3),
          outline: const Color(0xFF8F7B66),
          outlineVariant: const Color(0xFF4A3A2B),
          primary: jaguarYellow,
          onPrimary: const Color(0xFF2A1B0F),
          primaryContainer: const Color(0xFF4A3200),
          onPrimaryContainer: const Color(0xFFFFE3A3),
          secondary: const Color(0xFF6CC4FF),
          onSecondary: const Color(0xFF04263F),
          secondaryContainer: const Color(0xFF0B3B5A),
          onSecondaryContainer: const Color(0xFFCFE9FF),
          tertiary: const Color(0xFFB9A4FF),
          onTertiary: const Color(0xFF1E1240),
          tertiaryContainer: const Color(0xFF3A2D63),
          onTertiaryContainer: const Color(0xFFE6DEFF),
          error: const Color(0xFFFFB4AC),
          surfaceTint: Colors.transparent,
        )
      : base.copyWith(
          surface: const Color(0xFFFFF8F0),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFFFF1E1),
          surfaceContainer: const Color(0xFFF8EBDB),
          surfaceContainerHigh: const Color(0xFFF1E3D0),
          surfaceContainerHighest: const Color(0xFFEADBC8),
          onSurface: const Color(0xFF2A1B0F),
          onSurfaceVariant: const Color(0xFF65503D),
          outline: const Color(0xFF8A7560),
          outlineVariant: const Color(0xFFDCCBB5),
          primary: const Color(0xFF7A4B00),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFE3A3),
          onPrimaryContainer: const Color(0xFF3B2400),
          secondary: const Color(0xFF0B6BAF),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFD3E8F8),
          onSecondaryContainer: const Color(0xFF06304F),
          tertiary: const Color(0xFF5B3FB5),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE6DEFF),
          onTertiaryContainer: const Color(0xFF21005E),
          error: const Color(0xFFB3261E),
          surfaceTint: Colors.transparent,
        );
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = _scheme(brightness);
  final dark = brightness == Brightness.dark;
  final desktop = switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
    _ => false,
  };
  final base = ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
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
    // The bar has the color of the page: only its text and icons show.
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 52,
      centerTitle: false,
      foregroundColor: scheme.onSurface,
      iconTheme: IconThemeData(size: 24, color: scheme.onSurfaceVariant),
      actionsIconTheme: IconThemeData(size: 22, color: scheme.onSurfaceVariant),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: scheme.surface,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: desktop ? null : const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: desktop ? null : const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: scheme.outlineVariant, width: 2),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: const TextStyle(fontWeight: FontWeight.w800)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: dark ? const Color(0xFF7BC043) : const Color(0xFF3F8200),
      linearTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 10,
      borderRadius: BorderRadius.circular(5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: scheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
  // The title takes the family of the text theme, with the brand's weight.
  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    ),
  );
}

/// The identity of each place of the portal: its face, the edge under it and
/// the color of what is written on it.
class PlaceColors {
  const PlaceColors(this.face, this.edge, this.ink, {required this.soft});

  final Color face;
  final Color edge;
  final Color ink;

  /// A darker tone of the ink for secondary text on the face.
  final Color soft;

  static const _routeLight = PlaceColors(
    Color(0xFFF4B723),
    Color(0xFFA8730A),
    Color(0xFF2A1B0F),
    soft: Color(0xFF4A3200),
  );
  static const _routeDark = _routeLight;
  static const _workshopLight = PlaceColors(
    Color(0xFF5B3FB5),
    Color(0xFF3F2A87),
    Colors.white,
    soft: Color(0xFFE6DEFF),
  );
  static const _workshopDark = PlaceColors(
    Color(0xFFB9A4FF),
    Color(0xFF6C54C7),
    Color(0xFF1E1240),
    soft: Color(0xFF2E1D66),
  );
  static const _classesLight = PlaceColors(Color(0xFF0B6BAF), Color(0xFF064B7D), Colors.white, soft: Color(0xFFD3E8F8));
  static const _classesDark = PlaceColors(
    Color(0xFF6CC4FF),
    Color(0xFF2E8FCB),
    Color(0xFF04263F),
    soft: Color(0xFF06304F),
  );

  static bool _dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static PlaceColors route(BuildContext context) => _dark(context) ? _routeDark : _routeLight;
  static PlaceColors workshop(BuildContext context) => _dark(context) ? _workshopDark : _workshopLight;
  static PlaceColors classes(BuildContext context) => _dark(context) ? _classesDark : _classesLight;
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
